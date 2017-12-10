public class InputNeuron extends Neuron{
  
  private float wert;
  
  // getter
  @Override
  public float getWert(){
    return wert;
  }
  
  // setter
  @Override
  public void setWert(float input){
    wert = input;
  }
}