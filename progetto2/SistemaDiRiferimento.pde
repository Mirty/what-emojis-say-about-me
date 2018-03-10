class SistemaDiRiferimento {
  // proprietà
  Punto origine;
  int lunghezza_ascissa;
  int lunghezza_ordinata;
  int lunghezza_intervallo_ascissa;
  int lunghezza_intervallo_ordinata;
  Etichetta [] etichette_anni;
  
  // costruttori
  SistemaDiRiferimento (Punto origine, int lunghezza_ascissa, int lunghezza_ordinata) {
    this.origine = origine;
    this.lunghezza_ascissa = lunghezza_ascissa;
    this.lunghezza_ordinata = lunghezza_ordinata;
    
    lunghezza_intervallo_ascissa = 150;
    lunghezza_intervallo_ordinata = 50;
    
    etichette_anni = new Etichetta [anni_considerati.length];
  }
  
  // metodi e funzioni
  void draw () {
    // disegno la griglia di sfondo
    stroke (colore_griglia);
    fill (colore_generale);
    // per le ascisse -> verticali
    int lunghezza_intervallino_ascissa = 50;
    for (int i = origine.x + lunghezza_intervallino_ascissa; i < origine.x + lunghezza_ascissa; i += lunghezza_intervallino_ascissa) {
       line (i, origine.y, i, origine.y - lunghezza_ordinata);
    }
    int lunghezza_intervallino_ordinata = 25;
    float max_sentimento = getMaxAnnualSentimentScore ();
    for (int i = origine.y - lunghezza_intervallino_ordinata; i > origine.y - lunghezza_ordinata; i -= lunghezza_intervallino_ordinata) {
       line (origine.x, i, origine.x + lunghezza_ascissa, i);
       String testo = "" + nf(map (i, origine.y, origine.y - lunghezza_ordinata, 0, max_sentimento), 4, 3);
       if (MODE == 2) text (testo, origine.x - textWidth (testo) - 10, i + 5);
    }
    
    stroke (colore_generale);
    // disegno l'ascissa e l'ordinata
    line (origine.x, origine.y, origine.x + lunghezza_ascissa, origine.y);
    if (MODE == 2) line (origine.x, origine.y, origine.x, origine.y - lunghezza_ordinata);
    // disegno una griglia per l'ascissa -> quindi linee verticali
    int counter = 0;
    for (int i = origine.x + lunghezza_intervallo_ascissa; i < origine.x + lunghezza_ascissa; i += lunghezza_intervallo_ascissa) {
       line (i, origine.y, i, origine.y - lunghezza_ordinata);
       String testo = "" + anni_considerati[counter];
       etichette_anni [counter] = new Etichetta (testo, new Punto (int(i - textWidth(testo)/2), origine.y + 20));
       etichette_anni [counter].draw ();
       counter++;
    }
    if (MODE == 2) {
      // disegno una griglia per l'ordinata -> quindi linee orizzontali
      for (int i = origine.y - lunghezza_intervallo_ordinata; i > origine.y - lunghezza_ordinata; i -= lunghezza_intervallo_ordinata) {
         line (origine.x, i, origine.x + lunghezza_ascissa, i);
      }
    }
    
  }
  
  
  
}