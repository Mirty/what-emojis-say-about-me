import java.util.SortedSet;
import java.util.TreeSet;

HashMap <String, FloatDict> dati;
HashMap <String, FloatDict> emoji_sentiment;
ArrayList <String> emoji_decise;
color colore_sfondo = #303A52;
color colore_generale = #FC85AE;
color colore_positivita = #FC85AE;
color colore_neutralita = #9E579D;
color colore_negativita = #574B90;
int NUMERO_TABELLE = 68; 
Table [] tabelle; 
int margine = 60;


void setup () {
  size (1280, 680, P2D);
  pixelDensity (2);
  background (colore_sfondo);

  getData ();
  drawData ();
  
  noLoop ();
}


void drawData () {
  SortedSet <String> keys = new TreeSet <String> (dati.keySet ());
  int x_iniziale = margine + 40;
  int x = x_iniziale;
  int y = margine - 15;
  String mese_old = "", anno_old = "";
  int diametro = 10;
  int x_distanza = (width - (margine+40) * 2 - 31 * diametro)/29;
  int y_distanza = 12;
  // disegno
  fill (colore_generale);
  textSize (12);
  float max_sentiment = max (getAllSentiments ());
  float highest_sentiment_of_the_month;
  float positivita_mese = 0, neutralita_mese = 0, negativita_mese = 0;
  float r_positivita_mese = 0, r_neutralita_mese = 0, r_negativita_mese = 0;
  noStroke ();
  for (String data : keys) { 
    String anno = data.substring(0, 4); 
    String mese = data.substring(5, 7);
    String giorno = data.substring(8, 10);
    if (! mese.equals(mese_old)) {
      // disegno la linea del mese precedente in base all'umore predominante
      highest_sentiment_of_the_month = max(positivita_mese, neutralita_mese, negativita_mese);
      if (highest_sentiment_of_the_month != 0) {
        color colore_mese = #FFFFFF;
        float opacita_mese = 0; 
        if (highest_sentiment_of_the_month == positivita_mese) {
          colore_mese = colore_positivita;
          opacita_mese = map (r_positivita_mese, 0, positivita_mese, 0, 255);
        } else {
          if (highest_sentiment_of_the_month == neutralita_mese) {
            colore_mese = colore_neutralita;
            opacita_mese = map (r_neutralita_mese, 0, neutralita_mese, 0, 255);
          } else {
            colore_mese = colore_negativita;
            opacita_mese = map (r_negativita_mese, 0, negativita_mese, 0, 255);
          }
        }
        stroke (colore_mese, opacita_mese);
        line (margine + 10, y - 10, margine + 10, y + 5);
        noStroke ();
      }
      y += y_distanza;
      mese_old = mese;
      positivita_mese = 0;
      neutralita_mese = 0;
      negativita_mese = 0;
      r_positivita_mese = 0;
      r_neutralita_mese = 0;
      r_negativita_mese = 0;
    }
    x = x_iniziale + (diametro + x_distanza) * int(giorno);
    if (! anno.equals (anno_old)) {
      anno_old = anno;
      fill (colore_generale);
      text (anno, margine / 2, y + 5);
    }
    //text (giorno + "/" + mese + "/" + anno, x, y);
    float positivita = dati.get(data).get("positivo");
    float neutralita = dati.get(data).get("neutrale");
    float negativita = dati.get(data).get("negativo");

    positivita_mese += positivita;
    neutralita_mese += neutralita;
    negativita_mese += negativita;

    float diametro_positivita = map (positivita, 0, max_sentiment, 0, diametro);
    float r_positivita = 0;
    if (dati.get(data).hasKey("r_positivo")) r_positivita = dati.get(data).get("r_positivo");
    r_positivita_mese += r_positivita;
    float opacita_positivita = map (r_positivita, 0, positivita, 20, 255);
    fill (colore_positivita, opacita_positivita);
    ellipse (x, y, diametro_positivita, diametro_positivita);

    float diametro_neutralita = map (neutralita, 0, max_sentiment, 0, diametro);
    float r_neutralita = 0;
    if (dati.get(data).hasKey("r_neutrale")) r_neutralita = dati.get(data).get("r_neutrale");
    r_neutralita_mese += r_neutralita;
    float opacita_neutralita = map (r_neutralita, 0, neutralita, 20, 255);
    fill (colore_neutralita, opacita_neutralita);
    ellipse (x + 5, y, diametro_neutralita, diametro_neutralita);

    float diametro_negativita = map (negativita, 0, max_sentiment, 0, diametro);
    float r_negativita = 0;
    if (dati.get(data).hasKey("r_negativo")) r_negativita = dati.get(data).get("r_negativo");
    r_negativita_mese += r_negativita;
    float opacita_negativita = map (r_negativita, 0, negativita, 20, 255);
    fill (colore_negativita, opacita_negativita);
    ellipse (x + 10, y, diametro_negativita, diametro_negativita);
  }
  // disegno la linea dell'ultimo mese precedente in base all'umore predominante
  highest_sentiment_of_the_month = max(positivita_mese, neutralita_mese, negativita_mese);
  if (highest_sentiment_of_the_month != 0) {
    color colore_mese = #FFFFFF;
    float opacita_mese = 0; 
    if (highest_sentiment_of_the_month == positivita_mese) {
      colore_mese = colore_positivita;
      opacita_mese = map (r_positivita_mese, 0, positivita_mese, 0, 255);
    } else {
      if (highest_sentiment_of_the_month == neutralita_mese) {
        colore_mese = colore_neutralita;
        opacita_mese = map (r_neutralita_mese, 0, neutralita_mese, 0, 255);
      } else {
        colore_mese = colore_negativita;
        opacita_mese = map (r_negativita_mese, 0, negativita_mese, 0, 255);
      }
    }
    stroke (colore_mese, opacita_mese);
    line (margine + 10, y - 10, margine + 10, y + 5);
    noStroke ();
  }
}


float [] getAllSentiments () {
  float [] da_restituire = new float [dati.size() * 3];
  int counter = 0;
  for (String data : dati.keySet()) { 
    float positivita = dati.get(data).get("positivo");
    float neutralita = dati.get(data).get("neutrale");
    float negativita = dati.get(data).get("negativo");
    da_restituire [counter] = positivita;
    da_restituire [counter + 1] = neutralita;
    da_restituire [counter + 2] = negativita;
    counter += 3;
  }
  return da_restituire;
}


void getData () {
  /**
   Metodo che viene richiamata inizialmente per prendere i dati dai miei file csv.
   Associa a ogni anno il numero di emoji che sono state usate.
   */
  getPaperData (); // prendo i dati del paper
  int colonna_data = 0, colonna_messaggio = 1;

  tabelle = new Table [NUMERO_TABELLE];
  dati = new HashMap <String, FloatDict> ();

  for (int i = 0; i < tabelle.length; i++) {
    tabelle[i] = loadTable ("../before_Processing/my_csv/" + (i+1) + ".csv", "header");

    for (int j = 0; j < tabelle[i].getRowCount(); j++) {
      // data
      String data = tabelle[i].getString(j, colonna_data);
      if (! dati.containsKey (data)) dati.put(data, new FloatDict ());
      // valori delle emoji
      String messaggio = tabelle[i].getString(j, colonna_messaggio);
      String [] emojis = split(messaggio, ' '); // salvo le emoji del messaggio in un array
      for (int k = 0; k < emojis.length; k++) {
        String emoji = emojis[k]; 
        if (emoji_sentiment.containsKey(emoji)) {
          FloatDict valori = emoji_sentiment.get(emoji);
          float positivita = valori.get("positivo");
          float neutralita = valori.get("neutrale");
          float negativita = valori.get("negativo");
          dati.get(data).add("positivo", positivita);
          dati.get(data).add("neutrale", neutralita);
          dati.get(data).add("negativo", negativita);
          // salvo l'eventuale sentimento predominante
          if (emoji_decise.contains(emoji)) {
            float max_sentiment = max (positivita, neutralita, negativita);
            if (max_sentiment == positivita) dati.get(data).add("r_positivo", positivita);
            else {
              if (max_sentiment == neutralita) dati.get(data).add("r_neutrale", neutralita);
              else dati.get(data).add("r_negativo", negativita);
            }
          }
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