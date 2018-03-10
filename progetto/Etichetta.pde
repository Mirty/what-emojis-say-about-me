int DIMENSIONE_ETICHETTA = 50;

class Etichetta {
  // proprietà
  Point posizione;
  String label;
  PImage image;
  
  // costruttori
  Etichetta (Point posizione, String label) {
    this.posizione = posizione;
    this.label = label;
    image = null;
  }
  
  Etichetta (Point posizione, String label, PImage image) {
    this.posizione = posizione;
    this.image = image;
    this.label = label;
  }
  
  Etichetta () {
    // mi serve giusto per inizializzarla in funzioni_utili.getClosestEtichetta()
  }
  
  // metodi e funzioni
  void disegna (int textSize) {
    if (image == null) {
      fill (textColor);
      if (textSize <= 10) textSize = 10;
      textSize (textSize);
      text (label, posizione.x, posizione.y);
    }
    else {
      imageMode(CENTER);
      image(image, posizione.x, posizione.y, DIMENSIONE_ETICHETTA, DIMENSIONE_ETICHETTA);
    }
  }
  
  boolean isMouseOver () {
    return isBetween (mouseX, posizione.x - ERRORE, posizione.x + ERRORE) && isBetween (mouseY, posizione.y - ERRORE, posizione.y + ERRORE);
  }
}