public class WorkingNeuron extends Neuron{
  
  float wert;
  Connection[] inputC;
  
  WorkingNeuron(Connection[] iC){
    inputC = iC;
  }
  
  // getter
  @Override
  public float getWert(){
    for(Connection c : inputC){
      wert += c.getWert();
    }
    wert = AktivierungsFunktion.sigmoid(wert); 
    return wert;
  }
  // setter
  @Override
  public void setWert(float input){
    
    wert = input;
  }
}