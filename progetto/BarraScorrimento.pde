float lunghezza_asse;
float lunghezza_singolo_intervallo;

class BarraScorrimento {
  // proprietà
  float posX_cerchio, posY_cerchio, altezza, larghezza; // posizioni e dimensioni
  Point min_pos, max_pos; // posizione massime e minime raggiungibili dalla barra
  boolean scorrimento_orizzontale; 
  Point [] divisori;

  // costruttori
  BarraScorrimento (float min_x, float max_x, float min_y, float max_y, boolean scorrimento_orizzontale) {
    min_pos = new Point (min_x, min_y);
    max_pos = new Point (max_x, max_y);
    lunghezza_asse = dist (min_pos.x, min_pos.y, max_pos.x, max_pos.y);
    lunghezza_singolo_intervallo = lunghezza_asse / (NUM_INTERVALLI + 1);
    this.scorrimento_orizzontale = scorrimento_orizzontale;

    if (scorrimento_orizzontale) {
      altezza = 10;
      larghezza = 30;
    } else {
      larghezza = 10;
      altezza = 30;
    }

    divisori = new Point [NUM_INTERVALLI];
    initializePoints ();
  }

  // metodi e funzioni
  void initializePoints () {
    // funzione che divide l'asse in x punti e fa mettere la barra inizialmente nella posizione (1,1)
    for (int i = 0; i < NUM_INTERVALLI; i++) {
      float x, y;
      if (scorrimento_orizzontale) {
        x = min_pos.x + lunghezza_singolo_intervallo * (i+1);
        y = min_pos.y;
      } else {
        x = min_pos.x;
        y = max_pos.y - lunghezza_singolo_intervallo * (i+1); // per farla iniziare da giù (y più grande)
      }
      divisori [i] = new Point (x, y);
      // posizione iniziale delle barre
      if (i == 4) {
        posX_cerchio = x;
        posY_cerchio = y;
      }
    }
  }

  void disegna () {
    // barra
    fill (textColor);
    rectMode(CENTER);
    rect (posX_cerchio, posY_cerchio, larghezza, altezza, 5);
  }


  void detectMouseInteraction () {
    // determino la nuova posizione della barra tenendo conto dei divisori
    if (mousePressed) {
      if (scorrimento_orizzontale) {
        if (isBetween (mouseY, posY_cerchio - ERRORE, posY_cerchio + ERRORE) 
          && isBetween (mouseX, min_pos.x + ERRORE, max_pos.x - ERRORE)) {
          Point new_point = new Point (mouseX, posY_cerchio);
          posX_cerchio = getClosestPoint(divisori, new_point).x;
        }
      } else {
        if (isBetween (mouseX, posX_cerchio - ERRORE, posX_cerchio + ERRORE) 
          && isBetween (mouseY, min_pos.y + ERRORE, max_pos.y - ERRORE)) {
          Point new_point = new Point (posX_cerchio, mouseY);
          posY_cerchio = getClosestPoint(divisori, new_point).y;
        }
      }
    }
  }
}