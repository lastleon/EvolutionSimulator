class weighted_Bias {
  float weight;
  NEURON N;
  weighted_Bias(int w,NEURON n){
    weight = w;
    N = n;
  } 
  float getBias(){
    return weight*N.getWert();
  }
}