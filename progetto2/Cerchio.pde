class Cerchio {
  // proprietà
  Punto origine;
  float diametro;
  color colore;
  float sentimentalita;
  
  // costruttori
  Cerchio (Punto origine, float diametro, color colore, float sentimentalita) {
    this.origine = origine;
    this.diametro = diametro;
    this.colore = colore;
    this.sentimentalita = sentimentalita;
  }
  
  // metodi e funzioni
  void draw () {
    fill (colore);
    ellipse (origine.x, origine.y, diametro, diametro);
  }
  
  boolean isMouseOver () {
    return dist(mouseX, mouseY, origine.x, origine.y) < diametro/2;
  }
  
  void whenMouseOver (int anno) {
    // scrivo la percentuale
    float somma = sum (getSentimentScores (anno));
    int percentuale = int (map(sentimentalita, 0, somma, 0, 100));
    
    fill (255);
    ellipse (origine.x, origine.y, 40, 40);
    fill (colore_bordo);
    textSize (13);
    String testo = percentuale + "%";
    text (testo, origine.x - textWidth (testo)/2, origine.y + 5);
    
    textSize (12);
    
  }
}