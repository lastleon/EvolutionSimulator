public class NeuralNetwork{
  
  private InputNeuron[] inputSchicht;
  private Connection[][] connections1;
  private WorkingNeuron[] hiddenSchicht1;
  private Connection[][] connections2;
  private WorkingNeuron[] outputSchicht;
  
  // wird für aller erste Generation verwendet, gewichte sind random zwischen 0.01 und 
  NeuralNetwork(int iS, int hS1){ // inputSchicht, hiddenSchicht1
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
    int outputNeuronen = 7; // Grund in NN_Planung.txt ersichtlich
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
    
    private int iSLaenge = 9; // Grund in NN_Planung.txt ersichtlich
    
    NeuralNetwork(int hS1){ // hiddenSchicht1
    
    // Input Neuronen werden erstellt
    inputSchicht = new InputNeuron[iSLaenge];
    for(int i=0; i<iSLaenge; i++){
      inputSchicht[i] = new InputNeuron();
    }
    
    // random-gewichtete connections werden erstellt
    connections1 = new Connection[hS1][iSLaenge];
    for(int i=0; i<hS1; i++){
      for(int i2=0; i2<iSLaenge; i2++){
        connections1[i][i2] = new Connection(inputSchicht[i2], random(0.01,2));
      }
    }
    
    // Hidden Neuronen (1 Schicht) werden erstellt
    hiddenSchicht1 = new WorkingNeuron[hS1];
    for(int i=0; i<hS1; i++){
      hiddenSchicht1[i] = new WorkingNeuron(connections1[i]);
    }
    
    // random-gewichtete connection wird erstellt // outputNeuronen werden manuell spezifiziert
    int outputNeuronen = 6; // Grund in NN_Planung.txt ersichtlich
    
    connections2 = new Connection[outputNeuronen][hS1];
    for(int i=0; i<outputNeuronen; i++){
      for(int i2=0; i2<hS1; i2++){
        connections2[i][i2] = new Connection(hiddenSchicht1[i2], random(0,1));
      }
    }
    // Output Neuronen werden erstellt
    outputSchicht = new WorkingNeuron[outputNeuronen];
    for(int i=0; i<outputNeuronen; i++){
      outputSchicht[i] = new WorkingNeuron(connections2[i]);
    }    
  }
  
  //// getter
  // InputNeuronen, setzt voraus dass so viele Neuronen generiert wurden, wie es hier Werte gibt
  public InputNeuron getInputNGeschwindigkeit(){
    return inputSchicht[0];
  }
  public InputNeuron getInputNFellRot(){
    return inputSchicht[1];
  }
  public InputNeuron getInputNFellGruen(){
    return inputSchicht[2];
  }
  public InputNeuron getInputNFellBlau(){
    return inputSchicht[3];
  }
  public InputNeuron getInputNEnergie(){
    return inputSchicht[4];
  }
  public InputNeuron getInputNFeldart(){
    return inputSchicht[5];
  }
  public InputNeuron getInputNMemory(){
    return inputSchicht[6];
  }
  public InputNeuron getInputNBias(){
    return inputSchicht[7];
  }
  public InputNeuron getInputNRichtung(){
    return inputSchicht[8];
  }
  // OutputNeuronen
  public float getGeschwindigkeit(Lebewesen lw){
    //println(outputSchicht[0].getWert() * lw.getMaxGeschwindigkeit());
    return outputSchicht[0].getWert() * lw.getMaxGeschwindigkeit();
  }
  public float getRotation(){
    return outputSchicht[1].getWert() * 360;
  }
  public float getMemory(){
    return outputSchicht[2].getWert();
  }
  public int getFellRot(){
    return (int)(outputSchicht[3].getWert() * 255);
  }
  public int getFellGruen(){
    return (int)(outputSchicht[4].getWert() * 255);
  }
  public int getFellBlau(){
    return (int)(outputSchicht[5].getWert() * 255);
  }
  
  
  
}