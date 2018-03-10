boolean contains (String[] lista, String s) {
  for (int i = 0; i < lista.length; i++) 
    if (lista[i].equals(s))
      return true;
  return false;
}


float getMedian (int [] values) {
  float median = 0;
  /*
    Per calcolare la mediana di n dati:
   - si ordinano gli n dati in ordine crescente (o decrescente);
   - se il numero di dati è dispari la mediana corrisponde al valore centrale, 
   ovvero al valore che occupa la posizione (n+1)/2.
   - se il numero n di dati è pari, la mediana è stimata utilizzando i due valori 
   che occupano le posizione (n/2) e ((n/2)+1) 
   (generalmente si sceglie la loro media aritmetica se il carattere è quantitativo).
   */
  int [] ordered_values = sort (values);
  int n = ordered_values.length;
  if (n % 2 == 1) median = ordered_values [(n+1)/2 - 1];
  else median = (ordered_values [n/2 - 1] + ordered_values [n/2])/2;
  return median;
}


float getAvg (int [] array) {
  float sum = 0; 
  for (int i = 0; i < array.length; i++) sum += array[i];
  return sum/(array.length);
}


float sum (float [] array) {
  float sum = 0;
  for (int i = 0; i < array.length; i++) {
    sum += array[i];
  }
  return sum;
}


boolean isNear (int value1, int value2, int error) {
  return max (value1, value2) ==  min (value1, value2) + error || min (value1, value2) == max (value1, value2);
}