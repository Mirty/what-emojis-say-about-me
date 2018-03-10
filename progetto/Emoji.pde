class Emoji {
  // proprietà
  PImage immagine;
  Point posizione;
  float dimensione;
  String simbolo;
  
  // costruttori
  Emoji (String simbolo, String nome_immagine, Point posizione, float dimensione) {
    this.simbolo = simbolo;
    this.immagine = loadImage(nome_immagine);
    this.posizione = posizione;
    this.dimensione = dimensione;
  }
  
  // metodi e funzioni
  void disegna () {
    imageMode (CENTER);
    image (immagine, posizione.x, posizione.y, dimensione, dimensione);
  }
  
  boolean isMouseOver () {
    /* 
      Funzione che restituisce true solo se il mouse sta sopra la figura, 
      con un certo margine di errore concesso all'utente.
     */
    float raggio = dimensione/2;
    return isBetween (mouseX, posizione.x - raggio, posizione.x + raggio) 
    && isBetween (mouseY, posizione.y - raggio, posizione.y + raggio);
  }
  
  void whenMouseOver (int numero_di_utilizzi) {
    /*
      Funzione che mostra in una finestrella 
      quante volte quell'emoji è stata usata in quel periodo di tempo.
      Prende in input il numero di volte che è stata usata.
    */
    // voglio che le informazioni compaiano in alto a destra rispetto all'emoji
    float h = 30;
    float emoji_width = 30;
    String testo = "";
    if (numero_di_utilizzi != 1)
      testo = "   used " + numero_di_utilizzi + " times";
    else
      testo = "   used once";
    // rettangolo contenitore
    stroke (86, 198, 80); // colore spunte di telegram
    fill (235, 255, 213); // colore della nuvoletta di Telegram
    float t_w = textWidth(testo);
    rectMode (CORNER);
    rect (mouseX - t_w - emoji_width, mouseY - h , t_w + emoji_width, h, 8, 7, 1, 7);
    // testo
    stroke (textColor);
    fill (textColor);
    textSize (15);
    text (testo, mouseX - t_w - 10, mouseY - 10);
    // immagine
    image (immagine, mouseX - t_w - 15, mouseY - 15, 20, 20);
  }
}