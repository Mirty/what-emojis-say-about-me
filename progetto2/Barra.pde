class Barra {
  // proprieta
  Punto iniziale;
  Punto finale;
  color colore;
  float sentimentalita;
  
  // costruttori
  Barra (Punto iniziale, Punto finale, color colore, float sentimentalita) {
    this.iniziale = iniziale;
    this.finale = finale;
    this.colore = colore;
    this.sentimentalita = sentimentalita;
  }
  
  Barra (Punto iniziale, int larghezza, int altezza, color colore, float sentimentalita) {
    this.iniziale = iniziale;
    this.finale = new Punto (iniziale.x + larghezza, iniziale.y + altezza);
    this.colore = colore;
    this.sentimentalita = sentimentalita;
  }
  
  // metodi e funzioni
  void draw () {
    fill (colore); 
    rect (iniziale.x, iniziale.y, finale.x - iniziale.x, finale.y - iniziale.y, 5, 5, 0, 0);
  }
  
  boolean isMouseOver () {
    return isBetween (mouseX, iniziale.x, finale.x) && isBetween (mouseY, iniziale.y, finale.y);
  }
  
  void whenMouseOver () {
    textSize (13);
    
    // disegno la linea che indica di preciso l'altezza e scrivo il testo
    stroke (colore);
    line (margine, finale.y, width - margine, finale.y);
    fill (255);
    rect (sistema.origine.x, finale.y - 25, textWidth (sentimentalita + "") + 10, 25, 5, 5, 0, 0);
    fill (colore_bordo);
    text (sentimentalita, sistema.origine.x, finale.y - 7); 
    
    textSize (12); // ripristino
  }
}