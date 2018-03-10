class Punto {
  // proprietà
  int x, y;
  
  // costruttori
  Punto (int x, int y)  {
    this.x = x;
    this.y = y;
  }
  
  // metodi e funzioni
  boolean isNearTo (Punto punto) {
    /** 
      Funzione che mi restituisce true solo quando il punto passato come parametro 
      è vicino al punto stesso (this)
    */
    return isBetween (punto.x, this.x - ERRORE, this.x + ERRORE) && isBetween (punto.y, this.y - ERRORE, this.y + ERRORE);
  }
}