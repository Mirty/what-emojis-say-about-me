class Etichetta {
  // proprietà
  String testo;
  Punto posizione;
  
  // costruttori
  Etichetta (String testo, Punto posizione) {
    this.testo = testo;
    this.posizione = posizione;
  }
  
  // metodi e funzioni
  void draw () {
    text (testo, posizione.x, posizione.y);
  }
  
  boolean isMouseOver () {
    return isBetween (mouseX, posizione.x - ERRORE, posizione.x + textWidth (testo) + ERRORE)
      && isBetween (mouseY, posizione.y - ERRORE, posizione.y + ERRORE);
  }
}