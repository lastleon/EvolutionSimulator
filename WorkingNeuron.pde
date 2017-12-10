public class WorkingNeuron extends Neuron{
  
  float wert;
  
  WorkingNeuron(Connection[] inputC){
    for(Connection c : inputC){
      wert += c.getWert();
    }
    wert = AktivierungsFunktion.Sigmoid(wert);
  }
  
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