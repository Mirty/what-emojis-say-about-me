int NUMERO_TABELLE = 68; 
Table [] tabelle; // le tabelle che contengono i messaggi
HashMap <String, IntDict> dati; // chat -> {emoji -> num}
IntDict used_emojis; // contiene tutte le emoji usate
HashMap <String, FloatDict> emoji_sentiment;
ArrayList <String> emoji_decise;
int margine = 60;
int chat_non_visualizzate = 0;

color colore_sfondo = #303841;
color colore_positivo = #00ADB5;
color colore_neutrale = #EEEEEE;
color colore_negativo = #FF5722;


void setup () {
  getData ();
  getPaperData ();

  background (colore_sfondo);
  size (1280, 670, P2D);
  pixelDensity (2);
  drawData ();

  noLoop();
}


void drawData () {
  int counter_x = margine;
  int max_altezza_barra = height - margine * 2;
  float somma_positivita, somma_neutralita, somma_negativita;
  float max_sentimental_sum = sum(getMaxSentimentalSum ()); 
  noStroke ();
  int chat_da_visualizzare = 0;
  for (int i = NUMERO_TABELLE; i > chat_non_visualizzate; i --) {
    String chat = i + "";
    if (dati.containsKey(chat)) chat_da_visualizzare ++;
  }
  int larghezza_barra = 25; //(width - margine * 2)/chat_da_visualizzare;
  textSize (9);

  for (int i = NUMERO_TABELLE; i > chat_non_visualizzate; i --) {
    String chat = i + "";
    if (dati.containsKey(chat)) {
      somma_positivita = 0; 
      somma_neutralita = 0;
      somma_negativita = 0;
      int emoji_usate = 0;
      for (String emoji : emoji_sentiment.keySet()) {
        int usata = 0;
        if (contains(dati.get(chat).keyArray(), emoji)) usata = dati.get(chat).get(emoji);
        emoji_usate += usata;
        FloatDict sentiment_of_emoji = emoji_sentiment.get (emoji);
        float positivita = sentiment_of_emoji.get ("positivo") * usata;
        float neutralita = sentiment_of_emoji.get ("neutrale") * usata;
        float negativita = sentiment_of_emoji.get ("negativo") * usata;
        somma_positivita += positivita;
        somma_neutralita += neutralita;
        somma_negativita += negativita;
      }
      // negativita
      float y = height - margine;
      float altezza_negativita = map (somma_negativita, 0, max_sentimental_sum, 0, max_altezza_barra);
      fill (colore_negativo);
      rect (counter_x, y, larghezza_barra, - altezza_negativita);
      // neutralita
      y -= altezza_negativita;
      float altezza_neutralita = map (somma_neutralita, 0, max_sentimental_sum, 0, max_altezza_barra);
      fill (colore_neutrale);
      rect (counter_x, y, larghezza_barra, - altezza_neutralita);
      // positivita
      y -= altezza_neutralita;
      float altezza_positivita = map (somma_positivita, 0, max_sentimental_sum, 0, max_altezza_barra);
      fill (colore_positivo);
      rect (counter_x, y, larghezza_barra, - altezza_positivita);
      y -= altezza_positivita;
      // emoji usate
      fill (colore_neutrale);
      text (emoji_usate, counter_x, y - 10);
      noStroke ();
      counter_x += larghezza_barra;
    }
  }
}


float [] getMaxSentimentalSum () {
  float max_pos = 0, max_neu = 0, max_neg = 0;
  float somma_positivita, somma_neutralita, somma_negativita;
  for (int i = NUMERO_TABELLE; i > chat_non_visualizzate; i --) {
    String chat = i + "";
    if (dati.containsKey(chat)) {
      somma_positivita = 0; 
      somma_neutralita = 0;
      somma_negativita = 0;
      for (String emoji : emoji_sentiment.keySet()) {
        int usata = 0;
        if (contains(dati.get(chat).keyArray(), emoji)) usata = dati.get(chat).get(emoji);
        FloatDict sentiment_of_emoji = emoji_sentiment.get (emoji);
        float positivita = sentiment_of_emoji.get ("positivo") * usata;
        float neutralita = sentiment_of_emoji.get ("neutrale") * usata;
        float negativita = sentiment_of_emoji.get ("negativo") * usata;
        somma_positivita += positivita;
        somma_neutralita += neutralita;
        somma_negativita += negativita;
      }
      if (somma_positivita > max_pos) max_pos = somma_positivita;
      if (somma_neutralita > max_neu) max_neu = somma_neutralita;
      if (somma_negativita > max_neg) max_neg = somma_negativita;
    }
  }
  float [] da_restituire = {max_pos, max_neu, max_neg};
  return da_restituire;
}


void getData () {
  /**
   Metodo che viene richiamata inizialmente per prendere i dati dai miei file csv.
   Associa a ogni anno il numero di emoji che sono state usate.
   */
  int colonna_messaggio = 1;
  tabelle = new Table [NUMERO_TABELLE];
  dati = new HashMap <String, IntDict> ();
  used_emojis = new IntDict ();

  for (int i = 0; i < tabelle.length; i++) {
    tabelle[i] = loadTable ("../before_Processing/my_csv/" + (i+1) + ".csv", "header");
    String chat = i+1 + "";
    for (int j = 0; j < tabelle[i].getRowCount(); j++) {
      String messaggio = tabelle[i].getString(j, colonna_messaggio);
      String [] emojis = split(messaggio, ' '); // salvo le emoji del messaggio in un array
      for (int k = 0; k < emojis.length; k++) {
        String emoji = emojis[k]; 
        if (! emoji.equals("")) {
          if (! dati.containsKey (chat)) dati.put(chat, new IntDict ());
          dati.get(chat).increment(emoji);
          used_emojis.increment(emoji);
        }
      }
    }
  }
}


void getPaperData () {
  /**
   Metodo che prende i dati della tabella risultante dal paper.
   Associa a ogni emoji un valore di positività, neutralità e negatività;
   */
  Table tabella = loadTable ("emoji_ranking.csv", "header");
  int colonna_emoji = 0;
  int colonna_negativita = 1;
  int colonna_neutralita = 2;
  int colonna_positivita = 3;
  int scala = 1000;

  emoji_sentiment = new HashMap <String, FloatDict> ();
  emoji_decise = new ArrayList <String> ();

  for (int i = 0; i < tabella.getRowCount(); i++) {
    String emoji = tabella.getString (i, colonna_emoji);
    float valore_negativo = tabella.getFloat (i, colonna_negativita) / scala;
    float valore_neutro = tabella.getFloat (i, colonna_neutralita) / scala;
    float valore_positivo = tabella.getFloat (i, colonna_positivita) / scala;
    FloatDict dict = new FloatDict ();
    dict.set ("positivo", valore_positivo);
    dict.set ("neutrale", valore_neutro);
    dict.set ("negativo", valore_negativo);
    emoji_sentiment.put(emoji, dict);

    // salvo le emoji che hanno un sentimento predominante
    float max_sentiment = max (valore_negativo, valore_neutro, valore_positivo);
    float somma = valore_negativo + valore_neutro + valore_positivo;
    if (max_sentiment > somma - max_sentiment) emoji_decise.add(emoji);
  }
}


void draw () {
}