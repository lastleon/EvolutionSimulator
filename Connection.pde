class Connection{
  // kommt noch
  private Neuron inputN;
  private float weight;
  
  Connection(Neuron n, float w){
    inputN = n;
    weight = w;
  }
  
  // getter
  public float getWert(){
    return inputN.getWert()*weight;
  }
  // setter
  public void setWeight(float w){
    weight = w;
  }
}