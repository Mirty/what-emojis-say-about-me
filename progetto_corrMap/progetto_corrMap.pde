import java.util.Collections;
import java.util.List;

int NUMERO_TABELLE = 68; 
Table [] tabelle; // le tabelle che contengono i messaggi
HashMap <String, IntDict> dati; // chat -> {emoji -> num}
IntDict used_emojis; // contiene tutte le emoji usate
IntDict most_used_emojis; // contiene solo le n emoji più usate
int margine = 60;
int n = 25;
int chat_non_visualizzate = 0;
float media, media_intermedia;
int least_used_emoji, most_used_emoji;

color colore_iniziale = #FEFF92;
color colore_medio = #CFF800;
color colore_pre_finale = #0FEFBD;
color colore_finale = #7899DC;
color colore_massimo = #D02E77;


void setup () {
  getData ();

  background (255);
  size (1280, 690, P2D);
  pixelDensity (2);
  drawData ();

  noLoop();
}


void drawData () {
  int counter = 0;
  int scostamento = 23;

  // disegno in ordinata tutte le n emoji più usate
  //line (margine, margine, margine, height - margine);
  used_emojis.sortValuesReverse();
  int dimensione_emoji = 18;
  for (String emoji : most_used_emojis.keyArray()) {
    String nome_immagine = "images/"+ emoji +".png";
    File f = new File(dataPath(nome_immagine));
    if (f.exists()) {
      PImage immagine = loadImage(nome_immagine);
      image (immagine, margine - dimensione_emoji - 5, margine + counter * scostamento + 2, dimensione_emoji, dimensione_emoji);
      counter ++;
    }
  } 

  // disegno la correlation map e in ascissa tutti i nomi delle chat
  int counter_x = 0;
  counter = 0;
  int larghezza_cella = 25;
  most_used_emoji = getMaxUsedEmojiInChat (); 
  least_used_emoji = getMinUsedEmojiInChat ();
  int [] uso_delle_emoji = getSingleUseOfEmojis ();
  media = getAvg (uso_delle_emoji);
  int [] array = subset_greater_than (uso_delle_emoji, (int) media);
  media_intermedia = getAvg (array);
  println (least_used_emoji, media, most_used_emoji);
  noStroke ();

  for (int i = NUMERO_TABELLE; i > chat_non_visualizzate; i --) {
    String chat = i + "";
    if (dati.containsKey(chat)) {
      // correlation map
      textSize (5);
      int counter_y = 0;
      int somma = 0;
      for (String emoji : most_used_emojis.keyArray()) {
        int usata = 0;
        if (contains(dati.get(chat).keyArray(), emoji)) usata = dati.get(chat).get(emoji);
        somma += usata;
        color colore = getColor (usata);
        fill (colore);
        rect (margine + 20 + counter_x * scostamento - 10, margine + counter_y * scostamento, larghezza_cella, larghezza_cella);
        fill (0);
        //text (usata, margine + 10 + counter_x * scostamento, margine + counter_y * scostamento + 10);
        counter_y ++;
      }
      counter_x ++;

      // ascissa
      color riempimento = getColor (somma);
      fill (riempimento);
      rect (margine + 10 + counter * scostamento, height - margine + 10, larghezza_cella, larghezza_cella);
      textSize (7);
      pushMatrix ();
      translate (margine + 15 +  counter * scostamento, height - margine + 10);
      rotate (radians(30));
      fill (0);
      text (somma, 0, 10);
      popMatrix ();
      counter ++;
    }
  }
}


color getColor (int value) {
  color riempimento;
  if (value < media) {
    float norma = norm (value, least_used_emoji, media); 
    riempimento = lerpColor (colore_iniziale, colore_medio, norma);
  } else {
    if (value < media_intermedia) {
      float norma = norm (value, media, media_intermedia);
      riempimento = lerpColor (colore_medio, colore_pre_finale, norma);
    } else {
      if (value < most_used_emoji) {
        float norma = norm (value, media_intermedia, most_used_emoji);
        riempimento = lerpColor (colore_pre_finale, colore_finale, norma);
      }
      else {
        float norma = norm (value, most_used_emoji, most_used_emoji*3);
        riempimento = lerpColor (colore_finale, colore_massimo, norma);
      }
    }
  }
  return riempimento;
}


int [] getSingleUseOfEmojis () {
  int [] da_restituire;
  ArrayList <Integer> valori = new ArrayList <Integer> ();
  for (int i = NUMERO_TABELLE; i > chat_non_visualizzate; i --) {
    String chat = i + "";
    for (String emoji : most_used_emojis.keyArray()) {
      if (dati.containsKey(chat) && contains (dati.get(chat).keyArray(), emoji)) valori.add (dati.get(chat).get(emoji));
      //else valori.add (0);
    }
  }
  da_restituire = new int [valori.size()];
  for (int i = 0; i < valori.size (); i ++) {
    da_restituire [i] = valori.get(i);
  }
  return da_restituire;
}


int [] subset_greater_than (int [] values, int x) {
  int [] da_restituire;
  ArrayList <Integer> valori = new ArrayList <Integer> ();
  for (int value : values) {
    if (value > x) valori.add(value);
  }
  da_restituire = new int [valori.size()];
  for (int i = 0; i < valori.size (); i ++) {
    da_restituire [i] = valori.get(i);
  }
  return da_restituire;
}


int getMaxUsedEmojiInChat () {
  int max = 0;
  for (String chat : dati.keySet()) max = max (max, max (dati.get(chat).valueArray()));
  return max;
}


int getMinUsedEmojiInChat () {
  int min = max (used_emojis.valueArray());
  for (String chat : dati.keySet()) min = min (min, min (dati.get(chat).valueArray()));
  return min;
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
  most_used_emojis = new IntDict ();
  used_emojis.sortValuesReverse();
  for (String emoji : used_emojis.keyArray()) {
    if (most_used_emojis.size () < n) most_used_emojis.add(emoji, used_emojis.get(emoji));
    else break;
  }
}


void draw () {}