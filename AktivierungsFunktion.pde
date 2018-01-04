public static class AktivierungsFunktion{  
  //range 0,1
  static float sigmoid(float x){
    return 1/(1+exp(-x));
  }
  //range -infinity,+infinity
  static float identity(float x){
    return x;
  }
  //range -1,1
  static float tanh(float x){
    return (2/(1+exp(-2*x)))-1;
  }
  //range 0,infinity
  static float relu(float x){
    return max(0,x);
  }
}