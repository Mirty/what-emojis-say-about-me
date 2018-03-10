int ERRORE = 20;
boolean mouseClicked = false;

boolean isBetween (float value, float extr1, float extr2) {
  return value >= min (extr1, extr2) && value <= max (extr1, extr2);
}

boolean contains (int[] lista, int n) {
  for (int i = 0; i < lista.length; i++) 
    if (lista[i] == n) return true;
  return false;
}

boolean contains (String[] lista, String s) {
  for (int i = 0; i < lista.length; i++) 
    if (lista[i].equals(s))
      return true;
  return false;
}

int sum (int [] array) {
  int sum = 0;
  for (int i = 0; i < array.length; i++) {
    sum += array[i];
  }
  return sum;
}

float sum (float [] array) {
  float sum = 0;
  for (int i = 0; i < array.length; i++) {
    sum += array[i];
  }
  return sum;
}

void mousePressed () {
  if (modeSwitch.isNearTo(new Punto (mouseX, mouseY))) {
    if (MODE == 1) MODE = 2;
    else MODE = 1;
    
    println (MODE);
  }
}