class Connection{
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
  public float getWeight(){
    return weight;
  }
  // setter
  public void setWeight(float w){
    weight = w;
  }
}