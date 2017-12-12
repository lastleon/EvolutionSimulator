public static class AktivierungsFunktion{  
  //range 0,1
  static float Sigmoid(float x){
    return exp(x)/(1+exp(x));
  }
  //range -infinity,+infinity
  static float Identity(float x){
    return x;
  }
  //range -1,1
  static float tanh(float x){
    return (2/(1+exp(-2*x)))-1;
  }
}