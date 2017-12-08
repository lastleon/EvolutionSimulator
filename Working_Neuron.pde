class working_Neuron{
  float wert1;
  float wert2;
  NEURON N;
  weighted_Bias[] biases;
  working_Neuron(weighted_Bias[] b){
    biases = b;
    for (weighted_Bias w : b){
      wert1 += w.getBias();
    
    }
    N = new NEURON(wert2 = map(wert1,0,biases.length,0,1));
  }
  
}