class Neuron{
  
  private float input;
  private float weight;
  
  Neuron(float i){
    input = i;
  }
  // getter
  public float getOutput(){
    return input*weight;
  }
  // setter
  public void setWeight(float w){
    weight = w;
  }
}