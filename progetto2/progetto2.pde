SistemaDiRiferimento sistema;
int NUMERO_TABELLE = 68; 
int MODE = 1; // 1 -> cerchio, 2 -> barre
Table [] tabelle; // le tabelle che contengono i messaggi
HashMap <Integer, HashMap <Integer, IntDict>> dati; // anno -> {mese -> {emoji -> num}}
HashMap <String, FloatDict> emoji_sentiment;  // emoji -> {+ -> x, 0 -> y, - -> z}
ArrayList <String> emoji_decise; // emoji che hanno un sentimento predominante
int [] anni_considerati = {2015, 2016, 2017}; // sono gli unici anni di cui possiedo i messaggi per intero
Barra [] barra_negativa, barra_neutra, barra_positiva; // mode 2
Cerchio [] cerchio_negativo, cerchio_neutro, cerchio_positivo; // mode 1
Punto modeSwitch = null;
Punto modalita;
int margine = 100;
color colore_sfondo = color (255);
color colore_positivo = #4E3188;
color colore_neutro = #24BABC;
color colore_negativo = #EAEF9B; 
color colore_generale = color (140);
color colore_griglia = color (201);
color colore_bordo = #22213D;


void setup () {
  size (800, 500, P2D); 
  pixelDensity (2);
  textSize (12);

  cerchio_positivo = new Cerchio [anni_considerati.length];
  cerchio_neutro = new Cerchio [anni_considerati.length];
  cerchio_negativo = new Cerchio [anni_considerati.length];
  barra_negativa = new Barra [anni_considerati.length];
  barra_neutra = new Barra [anni_considerati.length];
  barra_positiva = new Barra [anni_considerati.length];
  surface.setTitle ("Quanto sono positive, neutre o negative le emoji che ho inviato nel 2015 e nel 2016?");

  sistema = new SistemaDiRiferimento (new Punto (margine, height - margine), width - 2*margine, height - 2*margine);
  
  getMyData ();
  getPaperData ();
}


void draw () {
  background (colore_sfondo);
  sistema.draw ();
  drawData ();
  checkMousePosition ();
  drawModeSwitch ();
}


void drawModeSwitch () {
  /**
    Metodo che viene richiamata dentro draw ()
    e che disegna l'interrutore per il cambio della visualizzazione, da barre a cerchi e viceversa
  */
  // disegno l'ellisse di sfondo
  int larghezza = 50;
  int altezza = 20;
  int margine = 20;
  if (modeSwitch == null) modeSwitch = new Punto (width - larghezza/2 - margine, margine + altezza/2);
  if (modeSwitch.isNearTo(new Punto (mouseX, mouseY))) cursor (HAND);
  noStroke ();
  fill (colore_bordo);
  rectMode (CENTER);
  rect (modeSwitch.x, modeSwitch.y, larghezza, altezza, 50);

  // disegno l'ellisse che indica la modalità
  if (MODE == 1) modalita = new Punto (modeSwitch.x - larghezza/4, modeSwitch.y);
  else modalita = new Punto (modeSwitch.x + larghezza/4, modeSwitch.y);
  fill (255);
  ellipse (modalita.x, modalita.y, altezza, altezza);
  
  // disegno le sigle per le modalità O/I
  fill (colore_bordo);
  text ("I", modeSwitch.x + larghezza/4 - textWidth ("I")/2, modeSwitch.y + 5);
  text ("O", modeSwitch.x - larghezza/4 - textWidth ("O")/2, modeSwitch.y + 5);

  rectMode (CORNER);
}


void getMyData () {
  /**
   Metodo che viene richiamata inizialmente per prendere i dati dai miei file csv.
   Associa a ogni anno il numero di emoji che sono state usate.
   */
  int colonna_data = 0, colonna_messaggio = 1;

  tabelle = new Table [NUMERO_TABELLE];
  dati = new HashMap <Integer, HashMap <Integer, IntDict>> ();

  for (int i = 0; i < tabelle.length; i++) {
    tabelle[i] = loadTable ("../before_Processing/my_csv/" + (i+1) + ".csv", "header");

    for (int j = 0; j < tabelle[i].getRowCount(); j++) {
      String data = tabelle[i].getString(j, colonna_data);
      int anno = int(data.substring (0, 4));
      int mese = int(data.substring(5, 7));

      // vado avanti solo se l'anno del messaggio mi interessa
      if (contains (anni_considerati, anno)) {
        String messaggio = tabelle[i].getString(j, colonna_messaggio);

        if (! dati.containsKey (anno)) dati.put(anno, new HashMap <Integer, IntDict> ());
        if (! dati.get(anno).containsKey (mese)) dati.get(anno).put(mese, new IntDict ());

        String [] emojis = split(messaggio, ' '); // salvo le emoji del messaggio in un array
        for (int k = 0; k < emojis.length; k++) {
          String emoji = emojis[k]; 
          dati.get(anno).get(mese).increment(emoji);
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


void drawData () {
  /**
   Metodo che disegna a video i dati
   */
  int min_altezza = 0;
  int max_altezza = sistema.lunghezza_ordinata;
  int larghezza_rettangolo = 25;
  int counter = 0;
  float max_sentimento = getMaxAnnualSentimentScore();
  noStroke ();

  for (int i = sistema.origine.x + sistema.lunghezza_intervallo_ascissa; i < sistema.origine.x + sistema.lunghezza_ascissa; i += sistema.lunghezza_intervallo_ascissa) {
    int anno = anni_considerati[counter];

    float positivita = getSentimentScores (anno) [0];
    float neutralita = getSentimentScores (anno) [1];
    float negativita = getSentimentScores (anno) [2];
    float somma = positivita + neutralita + negativita;
    float altezza = map (somma, 0, max_sentimento, min_altezza, max_altezza);
    float mapped_positivita = map (positivita, 0, somma, min_altezza, altezza);
    float mapped_neutralita = map (neutralita, 0, somma, min_altezza, altezza);
    float mapped_negativita = map (negativita, 0, somma, min_altezza, altezza);

    if (MODE == 1) {
      cerchio_negativo [counter] = new Cerchio (new Punto(i, int(sistema.origine.y - mapped_negativita/2)), mapped_negativita, colore_negativo, negativita );
      cerchio_negativo [counter].draw ();
      cerchio_neutro [counter] = new Cerchio (new Punto(i, int(sistema.origine.y - mapped_negativita - mapped_neutralita/2)), mapped_neutralita, colore_neutro, neutralita);
      cerchio_neutro [counter].draw ();
      cerchio_positivo [counter] = new Cerchio (new Punto(i, int(sistema.origine.y - mapped_negativita - mapped_neutralita - mapped_positivita/2)), mapped_positivita, colore_positivo, positivita);
      cerchio_positivo [counter].draw ();
    } else {
      barra_negativa [counter] = new Barra (new Punto (i - larghezza_rettangolo/2 * 3, sistema.origine.y), larghezza_rettangolo, int (- mapped_negativita), colore_negativo, negativita);
      barra_negativa [counter].draw ();
      barra_neutra [counter] = new Barra (new Punto (i - larghezza_rettangolo/2 * (1), sistema.origine.y), larghezza_rettangolo, int (- mapped_neutralita), colore_neutro, neutralita);
      barra_neutra [counter].draw ();
      barra_positiva [counter] = new Barra (new Punto(i - larghezza_rettangolo/2 * (-1), sistema.origine.y), larghezza_rettangolo, int (- mapped_positivita), colore_positivo, positivita);
      barra_positiva [counter].draw ();
    }
    counter ++;
  }
}


void checkMousePosition () {
  /**
    Funzione che modifica la visualizzazione a seconda dell'elemento che il mouse punta in quel momento.
  */
  boolean isMouseOverSomethingInteresting = false;

  // verifico quando il mouse sta sopra gli anni
  for (int i = 0; i < sistema.etichette_anni.length; i++) {
    if (sistema.etichette_anni [i].isMouseOver ()) {
      isMouseOverSomethingInteresting = true;
      drawInteractiveCircle (i);
    }
  }

  // verifico quando il mouse sta sopra le barre o i cerchi
  for (int i = 0; i < anni_considerati.length; i++) {
    int anno = anni_considerati [i];
    if (MODE == 1) {
      if (cerchio_negativo[i].isMouseOver()) {
        cerchio_negativo[i].whenMouseOver(anno);
        isMouseOverSomethingInteresting = true;
        break;
      }
      if (cerchio_neutro[i].isMouseOver()) {
        cerchio_neutro[i].whenMouseOver(anno);
        isMouseOverSomethingInteresting = true;
        break;
      }
      if (cerchio_positivo[i].isMouseOver()) {
        cerchio_positivo[i].whenMouseOver(anno);
        isMouseOverSomethingInteresting = true;
        break;
      }
    } else {
      if (barra_negativa[i].isMouseOver()) {
        barra_negativa[i].whenMouseOver();
        isMouseOverSomethingInteresting = true;
        break;
      }
      if (barra_neutra[i].isMouseOver()) {
        barra_neutra[i].whenMouseOver();
        isMouseOverSomethingInteresting = true;
        break;
      }
      if (barra_positiva[i].isMouseOver()) {
        barra_positiva[i].whenMouseOver();
        isMouseOverSomethingInteresting = true;
        break;
      }
    }
  } 

  if (isMouseOverSomethingInteresting) cursor (CROSS);
  else cursor (ARROW);
}


void drawInteractiveCircle (int iesimo_anno) {
  int origine_x = sistema.origine.x + sistema.lunghezza_intervallo_ascissa + sistema.lunghezza_intervallo_ascissa * iesimo_anno;
  int origine_y = 250;
  int diametro = 300;

  String [] mesi = {"JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"};

  // rendo lo sfondo meno visibile
  fill (255, 210);
  rect (0, 0, width, height);

  // disegno l'ellisse
  fill (255);
  stroke (colore_griglia);
  ellipse (origine_x, origine_y, diametro, diametro);

  textSize (13); // per i mesi

  // sentimentalità dei vari mesi
  noStroke();
  int larghezza_rettangolo = 10;
  int altezza_iniziale = 30;
  int spazietto_tra_barre = 5;
  int massima_altezza_totale = diametro/2 - altezza_iniziale - 2 * spazietto_tra_barre;
  int anno = anni_considerati[iesimo_anno];
  float x = - larghezza_rettangolo/2;
  int rounded_corner_value = 3;

  for (int i = 0; i < 12; i ++) {
    pushMatrix (); // mi alzo di livello

    translate (origine_x, origine_y);
    rotate (radians(15 * (i+1) + (15*i)));

    // disegno pallini per aiutare ad individuare il mese
    fill (colore_griglia);
    ellipse (0, 0, 5, 5);
    for (int j = - diametro/2 + 30; j > - diametro/2; j -= 10) {
      ellipse (x + larghezza_rettangolo/2, j, 2, 2);
    }
    
    int mese = i+1;

    // salvo il sentiment score delle emoji usate durante l'i mese dell'iesimo_anno
    float [] sentimentScoreOfThisMonth = getSentimentScores (anno, mese);
    float positivita = sentimentScoreOfThisMonth [0];
    float neutralita = sentimentScoreOfThisMonth [1];
    float negativita = sentimentScoreOfThisMonth [2];

    // mappo i sentimenti dell'anno per trovare l'altezza delle singole barre sentimentali
    float sentimentOfThisMonth = sum (sentimentScoreOfThisMonth);
    float massima_altezza = map (sentimentOfThisMonth, 0, getMaxMonthlySentimentScore (anno), 0, massima_altezza_totale);
    float altezza_positivita = map (positivita, 0, sentimentOfThisMonth, 0, massima_altezza);
    float altezza_neutralita = map (neutralita, 0, sentimentOfThisMonth, 0, massima_altezza);
    float altezza_negativita = map (negativita, 0, sentimentOfThisMonth, 0, massima_altezza);

    // mappo gli alpha delle emozioni -> quanto è stato forte ed unico quel sentimento?
    float [] potenze_sentimento = getPowerOfSentimentsScores (anno, mese);
    float unicita_sentimento_positivo = potenze_sentimento [0];
    float unicita_sentimento_neutrale = potenze_sentimento [1];
    float unicita_sentimento_negativo = potenze_sentimento [2];
    float alpha_positivita = map (unicita_sentimento_positivo, 0, positivita, 10, 255);
    float alpha_neutralita = map (unicita_sentimento_neutrale, 0, neutralita, 10, 255);
    float alpha_negativita = map (unicita_sentimento_negativo, 0, negativita, 10, 255);

    // disegno i cubetti sentimentali
    float y = - altezza_iniziale;
    fill (colore_negativo, alpha_negativita);
    rect (x, y, larghezza_rettangolo, - altezza_negativita, 0, 0, rounded_corner_value, rounded_corner_value);
    y -= altezza_negativita + spazietto_tra_barre;
    fill (colore_neutro, alpha_neutralita);
    rect (x, y, larghezza_rettangolo, - altezza_neutralita);
    y -= altezza_neutralita + spazietto_tra_barre;
    fill (colore_positivo, alpha_positivita);
    rect (x, y, larghezza_rettangolo, - altezza_positivita, rounded_corner_value, rounded_corner_value, 0, 0);

    // scrivo il nome dei mesi
    fill (colore_generale);
    String testo = mesi [i];
    if (i > 2 && i < 9) { // il testo si leggerebbe all'incontrario altrimenti...
      pushMatrix ();
      rotate (radians(180));
      text (testo, x - textWidth (testo)/4, diametro/2 + 20);
      popMatrix ();
    } else text (testo, x - textWidth (testo)/4, - diametro/2 - 10);

    popMatrix (); // torno al livello originale
  }
  textSize (12);
}


float [] getSentimentScores (int anno) {
  /**
   Funzione che restituisce, in base all'anno passato come parametro,
   i vari di positivita, neutralita e negativita come array di float. 
   */
  // in relazione all'anno considerato...
  float positivita = 0, neutralita = 0, negativita = 0;
  IntDict emoji_usate = new IntDict ();

  for (int t_mese : dati.get(anno).keySet()) {
    for (String emoji : dati.get(anno).get(t_mese).keys()) {
      int usate = dati.get(anno).get(t_mese).get(emoji);
      emoji_usate.add (emoji, usate);
    }
  }

  for (String emoji : emoji_usate.keys()) {
    if (emoji_sentiment.containsKey(emoji)) {
      int usata = emoji_usate.get(emoji);
      positivita += emoji_sentiment.get(emoji).get("positivo") * usata;
      neutralita += emoji_sentiment.get(emoji).get("neutrale") * usata;
      negativita += emoji_sentiment.get(emoji).get("negativo") * usata;
    }
  }

  float [] da_restituire = {positivita, neutralita, negativita};
  return da_restituire;
}


float [] getSentimentScores (int anno, int mese) {
  /**
   Funzione che restituisce, in base all'anno e al mese passati come parametro,
   i vari di positivita, neutralita e negativita come array di float. 
   */
  // in relazione all'anno considerato...
  float positivita = 0, neutralita = 0, negativita = 0;
  IntDict emoji_usate = new IntDict ();

  for (String emoji : dati.get(anno).get(mese).keys()) {
    int usate = dati.get(anno).get(mese).get(emoji);
    emoji_usate.add (emoji, usate);
  }

  for (String emoji : emoji_usate.keys()) {
    if (emoji_sentiment.containsKey(emoji)) {
      int usata = emoji_usate.get(emoji);
      positivita += emoji_sentiment.get(emoji).get("positivo") * usata;
      neutralita += emoji_sentiment.get(emoji).get("neutrale") * usata;
      negativita += emoji_sentiment.get(emoji).get("negativo") * usata;
    }
  }

  float [] da_restituire = {positivita, neutralita, negativita};
  return da_restituire;
}


float getMaxAnnualSentimentScore () {
  /**
   Funzione che restituisce il punteggio massimo di "sentimento"
   tra tutti gli anni analizzati.
   */
  float [] annualSentiment = new float [anni_considerati.length];
  for (int i = 0; i < anni_considerati.length; i++) {
    int anno = anni_considerati[i];
    annualSentiment [i] = sum (getSentimentScores (anno));
  }
  return max (annualSentiment);
}


float getMaxMonthlySentimentScore (int anno) {
  /**
   Funzione che restituisce il punteggio massimo di "sentimento" mensile
   dell'anno analizzato.
   */
  float [] monthlySentiment = new float [12];
  for (int i = 0; i < monthlySentiment.length; i++) {
    monthlySentiment [i] = sum (getSentimentScores (anno, i+1));
  }
  return max (monthlySentiment);
}


float [] getPowerOfSentimentsScores (int anno, int mese) {
  /**
   Funzione che restituisce la positivita, neutralità e negativita reale e voluta dei sentimenti.
   Ad esempio, in quel mese di quell'anno quanto ho usato emoji per la maggior parte solo positive, solo negative o solo neutrali?
   */
  float positivita = 0, neutralita = 0, negativita = 0;

  for (String emoji : dati.get(anno).get(mese).keys()) {
    if (emoji_sentiment.containsKey (emoji)) {
      int usata = dati.get(anno).get(mese).get(emoji); 
      float sentimento_positivo = emoji_sentiment.get(emoji).get("positivo") * usata;
      float sentimento_neutrale = emoji_sentiment.get(emoji).get("neutrale") * usata;
      float sentimento_negativo = emoji_sentiment.get(emoji).get("negativo") * usata;

      // se l'emoji ha un sentimento predominante...  
      if (emoji_decise.contains(emoji)) {
        float max_sentiment_score = max (sentimento_positivo, sentimento_neutrale, sentimento_negativo);

        if (max_sentiment_score == sentimento_positivo) positivita += sentimento_positivo;
        else if (max_sentiment_score == sentimento_neutrale) neutralita += sentimento_neutrale;
        else negativita += sentimento_negativo;
      }
    }
  }

  float [] da_restituire = {positivita, neutralita, negativita};
  return da_restituire;
}