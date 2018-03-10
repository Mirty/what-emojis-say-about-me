Table [] tabelle; // le tabelle che contengono i messaggi
int NUMERO_TABELLE = 68; 
int colonna_data = 0, colonna_messaggio = 1;
SistemaDiRiferimento sistema;
HashMap <String, HashMap <String, IntDict>> dati; // anno -> stagione -> emoji, n° volte
String selected_year, selected_season;
IntDict representedData; // dati che devono essere visualizzati
ArrayList <Emoji> emojis; // emoji che devono essere visualizzate
color bgColor, textColor;
int bordo = 60;
int max_represented_data = 0; // lo cambio appena entro in setVisibleEmojis ()
PrintWriter output = createWriter("data/emojis.txt"); // file in cui memorizzo le eventuali emoji mancanti.


void setup () {
  // grafica
  size (850, 600, P2D); 
  pixelDensity (2);
  PFont myFont = createFont("SF Pro Display", 32);
  textFont(myFont);
  bgColor = color (240);
  textColor = color (70);
  surface.setTitle ("Che emoji ho usato su Telegram dal 2014 al 2017?");

  // operazioni sui dati
  sistema = new SistemaDiRiferimento ();
  getData (); // prendo i dati dai file csv
  selected_year = "totale";
  selected_season = "totale";
  setRepresentedData ();
}


void draw () {
  background (bgColor);
  //surface.setTitle (int(frameRate) + " fps, " + frameCount + " frames");

  sistema.disegna (); // disegno il sistema di riferimento
  drawNuvolettaSelezione (); // disegno la "nuvoletta" di sfondo
  drawData (); // disegno le emoji
  checkMousePosition (); // controllo se il mouse è sopra un'emoji o sulle barre
  rectMode (CORNER);
}


void checkMousePosition () {
  /**
   Funzione che viene richiamata costantemente dentro draw () 
   per settare l'apparenza del mouse in base a cosa l'utente punta:
   - emoji : croce
   - stagione / anno : manina
   - else : freccia
   */
  boolean is_mouse_over_emoji = false; 
  for (Emoji emoji : reverse(emojis)) 
    if (emoji.isMouseOver()) {
      is_mouse_over_emoji = true;
      emoji.whenMouseOver(representedData.get(emoji.simbolo));
      break; // per evitare che nello stesso frame vengano evidenziate più emoji
    }

  if (is_mouse_over_emoji) cursor (CROSS);
  else {
    // controllo che sia sulle due barre
    if (sistema.isMouseOver()) cursor (HAND);
    else cursor (ARROW);
  }
}


void setVisibleEmojis () {
  /**
   Funzione che viene richiamata da dentro setRepresentedData (), 
   quindi inizialmente e ogni volta che l'utente fa click.
   Serve per stabilire quelle che saranno le emoji visualizzabili. 
   Popolo di volta in volta un arraylist di Emoji.
   Mi sarebbe piaciuto stampare dei semplici caratteri che rappresentassero l'emoji,
   ma venivano rappresentati come quadratini vuoti. 
   Allora ho optato per l'associazione emoji in stringa -> emoji in immagine.
   Il procedimento è spiegato nel data cleaning note. 
   */
  emojis = new ArrayList <Emoji> (); 

  reverse (representedData.valueArray()); // dall'emoji più usata a quella meno usata, per posizionare prima le emoji più grandi
  // si entrerà nell'if una sola volta, all'inizio, dato che al primo giro è selezionato "tutte, tutti"...
  if (max_represented_data < max(representedData.valueArray())) max_represented_data = max(representedData.valueArray());
  for (String emoji : representedData.keyArray()) {
    int counter = representedData.get(emoji); // quante volte è stata usata quell'emoji
    float dimensione = map (counter, 0, max_represented_data, 5, 400);
    String nome_immagine = "images/"+ emoji +".png";
    File f = new File(dataPath(nome_immagine));

    // controllo che l'immagine dell'emoji esista, prima di caricare un'emoji non rappresentabile
    if (f.exists()) {
      int frame = 30;
      // cerco una posizione che non intersechi le emoji precedenti
      boolean can_be_created = false;
      while (! can_be_created) {
        float pos_x = random (150 + dimensione/2 + frame, width - bordo - frame - dimensione/2);
        float pos_y = random (bordo + frame + dimensione/2, 470 - dimensione/2 - frame);
        Emoji new_possible_emoji = new Emoji (emoji, nome_immagine, new Point (pos_x, pos_y), dimensione);
        boolean intersection = false;
        for (Emoji temp : emojis) {
          if (intersects (temp, new_possible_emoji)) {
            intersection = true;
            break;
          }
        }
        if (! intersection ) {
          can_be_created = true;
          emojis.add(new_possible_emoji);
          //println ("Aggiunta in " + pos_x + ", " + pos_y);
        }
      }
    } else {
      output.println (emoji); // non accade
    }
  }
}


void drawData () {
  /**
   Funzione che viene richiamata costantemente in draw ().
   Disegna tutte le emoji dell'anno e della stagione selezionati. 
   */
  for (Emoji emoji : emojis) {
    emoji.disegna();
  }
}


void setRepresentedData () {
  /**
   Funzione che viene richiamata ogniqualvolta l'utente fa click.
   Definisce qualli dati devono essere visualizzati in base ad anno selezionato e stagione.
   Si basa sulla modifica dei dati effettuata dalla funzione updateSelectedData ().
   I primi valori invece li imposto io di default:
   selected_year -> tutti
   selected_season -> tutte
   */
  representedData = new IntDict();
  if (selected_year.equals("totale")) {
    for (String anno : dati.keySet()) {
      if (selected_season.equals("totale")) {
        for (String stagione : dati.get(anno).keySet()) {
          for (String emoji : dati.get(anno).get(stagione).keys()) {
            int counter = dati.get(anno).get(stagione).get(emoji);
            representedData.add(emoji, counter);
          }
        }
      } else {
        for (String emoji : dati.get(anno).get(selected_season).keys()) {
          int counter = dati.get(anno).get(selected_season).get(emoji);
          representedData.add(emoji, counter);
        }
      }
    }
  } else if (selected_season.equals("totale")) {
    for (String stagione : dati.get(selected_year).keySet()) {
      for (String emoji : dati.get(selected_year).get(stagione).keys()) {
        int counter = dati.get(selected_year).get(stagione).get(emoji);
        representedData.add(emoji, counter);
      }
    }
  } else
    representedData = dati.get(selected_year).get(selected_season);

  // creo gli elementi visibili in base ai dati che devo visualizzare
  setVisibleEmojis ();
}


String getStagione (String mese) {
  /**
    Funzione che, dato un mese dell'anno, mi restituisce la stagione.
  */
  String stagione = "";
      switch (mese) {
      case "12" :
      case "01" :
      case "02" :
        stagione = "inverno";
        break;
      case "03" :
      case "04" :
      case "05" :
        stagione = "primavera";
        break;
      case "06" :
      case "07" :
      case "08" :
        stagione = "estate";
        break;
      case "09" :
      case "10" :
      case "11" :
        stagione = "autunno";
        break;
      default :
        stagione = "errore"; // debug
      }
   return stagione;
}


void getData () {
  /**
   Funzione che viene richiamata inizialmente per prendere i dati dai file csv.
   Associa a ogni data tutte le emoji inviate il quella giornata.
   */
  tabelle = new Table [NUMERO_TABELLE];
  ArrayList <String> anni = new ArrayList <String> ();
  ArrayList <String> stagioni = new ArrayList <String> ();
  dati = new HashMap <String, HashMap <String, IntDict>> ();

  for (int i = 0; i < tabelle.length; i++) {
    tabelle[i] = loadTable ("../before_Processing/my_csv/" + (i+1) + ".csv", "header");

    for (int j = 0; j < tabelle[i].getRowCount(); j++) {
      String data = tabelle[i].getString(j, colonna_data);
      String messaggio = tabelle[i].getString(j, colonna_messaggio);

      // formato data = aaaa-mm-gg
      String anno = data.substring(0, 4); // per comodità tengo stringhe, e non int
      String mese = data.substring(5, 7);
      String stagione = getStagione (mese);
      
      // creo la struttura dell'hashmap
      // {
      //   2017 {
      //          inverno {
      //                 emoji1 -> num_emoji_1

      if (! dati.containsKey(anno)) 
        dati.put(anno, new HashMap <String, IntDict> ());
      if (! dati.get(anno).containsKey(stagione)) {
        dati.get(anno).put(stagione, new IntDict ());
      }
      if (! anni.contains(anno)) anni.add(anno);
      if (! stagioni.contains(stagione)) stagioni.add(stagione);

      String [] emojis = split(messaggio, ' ');
      for (int k = 0; k < emojis.length; k++) {
        String emoji = emojis[k]; 
        dati.get(anno).get(stagione).increment(emoji); // considero anche le emoji che compaiono più volte
      }
    }
  }
  
  for (String anno : anni) {
    for (String stagione : stagioni) {
      if (! dati.get(anno).containsKey(stagione)) dati.get(anno).put(stagione, new IntDict ());
    }
  }
}


boolean updateSelectedData () {
  /**
   Funzione che aggiorna le variabili in base alla selezione fatta dall'utente.
   Viene richiamata ogni volta che l'utente clicca sulla finestra.
   */

  // salvo la posizione della barra degli anni sullo schermo
  float anni_posX = 135;
  float anni_posY_partenza = 140;
  float anni_distY = 70;

  // salvo la posizione della barra delle stagioni sullo schermo
  float stagioni_posY = 500;
  float stagioni_posX_partenza = 560;
  float stagioni_distX = 70; 

  String new_selected_year = selected_year; // il valore attuale
  // ordinata -> anni
  if (isBetween (mouseX, anni_posX - ERRORE, anni_posX + ERRORE) 
    && isBetween (mouseY, anni_posY_partenza - ERRORE, anni_posY_partenza + anni_distY * 4 + ERRORE)) {
    // il nuovo valore calcolato
    new_selected_year = getClosestEtichetta(sistema.etichette_ordinata, new Point (mouseX - 15, mouseY)).label.toLowerCase();
  }

  String new_selected_season = selected_season; // il valore attuale
  // ascissa -> stagioni
  if (isBetween (mouseX, stagioni_posX_partenza - stagioni_distX * 4 - ERRORE, stagioni_posX_partenza + ERRORE) &&
    isBetween (mouseY, stagioni_posY - ERRORE, stagioni_posY + ERRORE)) {
    // il nuovo valore calcolato
    new_selected_season = getClosestEtichetta(sistema.etichette_ascissa, new Point (mouseX, mouseY + 40)).label.toLowerCase();
  }

  // restituisco : è cambiato qualcosa dalla selezione precedente?
  // lo faccio per motivi di velocità : 
  // se l'utente riclicca 100 volte sulla stessa etichetta,
  // senza effettivamente cambiare la selezione,
  // che senso ha riaggiornare tutto? Sarebbe uno spreco di tempo e risorse.
  // Aggiorno solo se effettivamente qualcosa è cambiato rispetto a prima.
  boolean cambiamento = ! new_selected_year.equals(selected_year) || ! new_selected_season.equals(selected_season);
  selected_season = new_selected_season;
  selected_year = new_selected_year;
  return cambiamento;
}


void drawNuvolettaSelezione () {
  /**
   Funzione che disegna una sorta di nuvoletta dietro le emoji, 
   per far capire che le emoji che stanno venendo visualizzate sono relative 
   a un certo anno e a una certa stagione.
   */
  Point min = new Point (150, bordo);
  Point max = new Point (width - bordo, 470);
  fill (255);
  noStroke ();

  // nuvoletta
  rectMode (CORNERS);
  rect (min.x, min.y, max.x, max.y, 20);

  int larghezza_triangolo = 20;

  // triangolino ascissa
  float min_pos_y_ascissa = max.y;
  Point stagione_puntata = new Point (sistema.barra_scorrimento_ascisse.posX_cerchio, sistema.barra_scorrimento_ascisse.posY_cerchio - 10);
  Point p1 = new Point (stagione_puntata.x - larghezza_triangolo, min_pos_y_ascissa);
  Point p2 = new Point (stagione_puntata.x + larghezza_triangolo, min_pos_y_ascissa);
  Point p3 = stagione_puntata;
  triangle (p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);

  // triangolino ordinata
  float min_pos_x_ordinata = min.x;
  Point anno_puntato = new Point (sistema.barra_scorrimento_ordinate.posX_cerchio + 10, sistema.barra_scorrimento_ordinate.posY_cerchio);
  p1 = new Point (min_pos_x_ordinata, anno_puntato.y - larghezza_triangolo);
  p2 = new Point (min_pos_x_ordinata, anno_puntato.y + larghezza_triangolo);
  p3 = anno_puntato;
  triangle (p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);
}