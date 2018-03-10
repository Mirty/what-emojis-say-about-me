class SistemaDiRiferimento {
  // proprietà
  Etichetta [] etichette_ascissa;
  Etichetta [] etichette_ordinata;
  BarraScorrimento barra_scorrimento_ascisse, barra_scorrimento_ordinate;
  float raggio_ascissa, ascissa_x, ascissa_y;
  float raggio_ordinata, ordinata_x, ordinata_y;
  Etichetta stagioni, anni;
  
  // costruttori
  SistemaDiRiferimento () {
    raggio_ascissa = 200;
    ascissa_x = width/2 - raggio_ascissa;
    ascissa_y = height - 100;
    barra_scorrimento_ascisse = new  BarraScorrimento (ascissa_x,  ascissa_x + raggio_ascissa * 2, ascissa_y, ascissa_y, true);
    
    setLabels ();
    raggio_ordinata = 200;
    ordinata_x = 120;
    ordinata_y = height/2 - raggio_ordinata - 25;
    barra_scorrimento_ordinate = new  BarraScorrimento (ordinata_x, ordinata_x,  ordinata_y,  ordinata_y  + raggio_ordinata * 2, false);
  }
  
  // metodi e funzioni
  void setLabels () {
    etichette_ascissa = new Etichetta [NUM_INTERVALLI];
    etichette_ordinata = new Etichetta [NUM_INTERVALLI];
    float lunghezza_asse = dist (ascissa_x, ascissa_y,  ascissa_x + raggio_ascissa * 2, ascissa_y);
    float lunghezza_singolo_intervallo = lunghezza_asse / (NUM_INTERVALLI + 1);
    
    // ordinata -> anni
    float posX = ordinata_x + 60;
    Point pos_anni = new Point (posX - 5, ordinata_y + lunghezza_singolo_intervallo * 2 + 15);
    etichette_ordinata[0] = new Etichetta (pos_anni, "Total"); // Totale
    Point pos_2014 = new Point (posX, ordinata_y + lunghezza_singolo_intervallo * 6 + 15);
    etichette_ordinata[1] = new Etichetta (pos_2014, "2014"); // 2014
    Point pos_2015 = new Point (posX, ordinata_y + lunghezza_singolo_intervallo * 5 + 15);
    etichette_ordinata[2] = new Etichetta (pos_2015, "2015"); // 2015
    Point pos_2016 = new Point (posX, ordinata_y + lunghezza_singolo_intervallo * 4 + 15);
    etichette_ordinata[3] = new Etichetta (pos_2016, "2016"); // 2016
    Point pos_2017 = new Point (posX, ordinata_y + lunghezza_singolo_intervallo * 3 + 15);
    etichette_ordinata[4] = new Etichetta (pos_2017, "2017"); // 2017
    
    // ascisse -> stagioni
    float posY = ascissa_y + 40;
    Point pos_inverno = new Point (ascissa_x + lunghezza_singolo_intervallo, posY);
    etichette_ascissa[0] = new Etichetta (pos_inverno, "inverno", loadImage ("stagioni/inverno.png")); // inverno
    Point pos_primavera = new Point (ascissa_x + lunghezza_singolo_intervallo * 2, posY);
    etichette_ascissa[1] = new Etichetta (pos_primavera, "primavera", loadImage ("stagioni/primavera.png")); // primavera
    Point pos_estate = new Point (ascissa_x + lunghezza_singolo_intervallo * 3, posY);
    etichette_ascissa[2] = new Etichetta (pos_estate, "estate", loadImage ("stagioni/estate.png")); // estate
    Point pos_autunno = new Point (ascissa_x + lunghezza_singolo_intervallo * 4, posY);
    etichette_ascissa[3] = new Etichetta (pos_autunno, "autunno", loadImage ("stagioni/autunno.png")); // autunno
    Point pos_tutte = new Point (ascissa_x + lunghezza_singolo_intervallo * 5 - 25, posY);
    etichette_ascissa[4] = new Etichetta (pos_tutte, "Total"); // totale
    
    stagioni = new Etichetta (new Point (width/2 - textWidth("Seasons"), posY + 50), "Seasons");
    anni = new Etichetta (new Point (posX - 45, height/2), "Years");
  }
  
  void disegna () {
    fill (textColor);
    draw_ascisse ();
    barra_scorrimento_ascisse.disegna ();
    draw_ordinate ();
    barra_scorrimento_ordinate.disegna ();
    for (int i = 0; i < etichette_ordinata.length; i++) {
      etichette_ascissa[i].disegna (17);
      etichette_ordinata[i].disegna (17);
    }
    // disegno l'indicatore per i due assi
    stagioni.disegna (15);
    anni.disegna (15);
  }      
  
  void draw_ascisse () {
    stroke (textColor);
    line (ascissa_x + lunghezza_singolo_intervallo, ascissa_y, ascissa_x + raggio_ascissa * 2 - lunghezza_singolo_intervallo, ascissa_y);
    for (int i = int(ascissa_x + lunghezza_singolo_intervallo) ; i < ascissa_x + raggio_ascissa * 2 - lunghezza_singolo_intervallo; i += lunghezza_singolo_intervallo) {
      ellipse (i, ascissa_y, 7, 7);
    }
  }
  
  void draw_ordinate () {
    stroke (textColor);
    line (ordinata_x, ordinata_y + lunghezza_singolo_intervallo, ordinata_x, ordinata_y  + raggio_ordinata * 2 - lunghezza_singolo_intervallo);
    for (int i = int(ordinata_y + lunghezza_singolo_intervallo) ; i < ordinata_y + raggio_ascissa * 2 - lunghezza_singolo_intervallo; i += lunghezza_singolo_intervallo) {
      ellipse (ordinata_x, i, 7, 7);
    }
  }
  
  boolean isMouseOver () {
    // è sulla ascissa || è sull'ordinata?
    return (isBetween (mouseX, ascissa_x + lunghezza_singolo_intervallo - ERRORE, ascissa_x + raggio_ascissa * 2 - lunghezza_singolo_intervallo + ERRORE) 
                && isBetween (mouseY, ascissa_y - ERRORE, ascissa_y + ERRORE))  ||
           (isBetween (mouseX, ordinata_x - ERRORE, ordinata_x + ERRORE) 
                && isBetween (mouseY, ordinata_y + lunghezza_singolo_intervallo - ERRORE, ordinata_y  + raggio_ordinata * 2 - lunghezza_singolo_intervallo + ERRORE));
  }
}