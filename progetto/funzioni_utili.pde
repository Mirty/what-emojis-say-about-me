int NUM_INTERVALLI = 5;
int ERRORE = 30;


boolean isBetween (float value, float extr1, float extr2) {
  return value >= min (extr1, extr2) && value <= max (extr1, extr2);
}


boolean contains (String[] lista, String s) {
  for (int i = 0; i < lista.length; i++) 
    if (lista[i].equals(s))
      return true;
  return false;
}


ArrayList<Emoji> reverse(ArrayList<Emoji> lista) {
    ArrayList<Emoji> da_restituire = new ArrayList<Emoji> ();
    for(int i = lista.size() - 1; i >= 0; i--) {
        da_restituire.add(lista.get(i));
    }
    return da_restituire;
}


Point getClosestPoint (Point [] points, Point point) {
  float min_dist = MAX_FLOAT;
  Point closestPoint = new Point ();

  for (int i = 0; i < points.length; i ++) {
    float dist = dist (points[i].x, points[i].y, point.x, point.y);
    if (dist  < min_dist) {
      min_dist = dist; 
      closestPoint = points[i];
    }
  }
  return closestPoint;
}


Etichetta getClosestEtichetta (Etichetta [] etichette, Point point) {
  Point [] points = new Point [etichette.length];

  for (int i = 0; i < etichette.length; i++) {
    points [i] = etichette [i].posizione;
  }

  Point closestPoint = getClosestPoint (points, point);
  Etichetta da_ritornare = new Etichetta ();

  for (int i = 0; i < points.length; i++) {
    if (closestPoint == points[i]) {
      da_ritornare = etichette[i];
      break;
    }
  }

  return da_ritornare;
}


void printData () {
  for (String anno : dati.keySet()) {
    for (String mese : dati.get(anno).keySet()) {
      for (String emoji : dati.get(anno).get(mese).keyArray()) {
        int counter =  dati.get(anno).get(mese).get(emoji);
        println (anno + " " + mese + " " + emoji + " " + counter);
      }
    }
  }
}


int sum (int [] array) {
  int sum = 0;
  for (int i = 0; i < array.length; i++) {
    sum += array[i];
  }
  return sum;
}


boolean intersects(Emoji a, Emoji b) {
  // Funzione che verifica se c'è un'intersezione tra 2 emoji.
  // Restituisce vero quando la somma dei raggi è maggiore della loro distanza.
  return dist(a.posizione.x, a.posizione.y, b.posizione.x, b.posizione.y) - 5 < a.dimensione/2 + b.dimensione/2;
}


void mousePressed() {
  cursor (WAIT);
  // aggiorno la visualizzazione delle barre (se necessario)
  sistema.barra_scorrimento_ascisse.detectMouseInteraction ();
  sistema.barra_scorrimento_ordinate.detectMouseInteraction ();
  // aggiorno le variabili che tengono conto della selezione dell'utente
  boolean update = updateSelectedData (); 
  // aggiorno i dati che l'utente vuole visualizzare se c'è stato un effettivo cambiamento di selezione
  if (update) {
    setRepresentedData ();
    println (selected_season, selected_year);
  }
  cursor (ARROW);
}