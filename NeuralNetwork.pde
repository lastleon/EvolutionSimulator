public class NeuralNetwork{
  
  InputNeuron[] inputSchicht;
  Connection[][] connections1;
  Connection[][] connections2;
  WorkingNeuron[] hiddenSchicht1;
  WorkingNeuron[] outputSchicht;
  
  NeuralNetwork(int iS, int hS1){
    // Input Neuronen werden erstellt
    inputSchicht = new InputNeuron[iS];
    for(int i=0; i<iS; i++){
      inputSchicht[i] = new InputNeuron();
    }
    
    // random-gewichtete connection werden erstellt
    connections1 = new Connection[hS1][iS];
    for(int i=0; i<hS1; i++){
      for(int i2=0; i2<iS; i2++){
        connections1[i][i2] = new Connection(inputSchicht[i2], random(0.01,2));
      }
    }
    
    // Hidden Neuronen (1 Schicht) werden erstellt
    hiddenSchicht1 = new WorkingNeuron[hS1];
    for(int i=0; i<hS1; i++){
      hiddenSchicht1[i] = new WorkingNeuron(connections1[i]);
    }
    
    // random-gewichtete connection wird erstellt // outputNeuronen werden manuell spezifiziert
    int outputNeuronen = 5;
    connections2 = new Connection[outputNeuronen][hS1];
    for(int i=0; i<outputNeuronen; i++){
      for(int i2=0; i2<hS1; i2++){
        connections2[i][i2] = new Connection(hiddenSchicht1[i2], random(0.01,2));
      }
    }
    // Output Neuronen werden erstellt
    outputSchicht = new WorkingNeuron[outputNeuronen];
    for(int i=0; i<outputNeuronen; i++){
      outputSchicht[i] = new WorkingNeuron(connections2[i]);
    }
    
  }
  // getter 
  public float getGeschwindigkeit(){
    return outputSchicht[0].getWert();
  }
  
  
}