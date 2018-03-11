public class NeuralNetwork {

  // erklärt in Video
  
  Matrix inputLayer;
  Matrix outputLayer;
  
  Matrix[] weights;
  Matrix[] hiddenLayer;


  int iLLength = 9;
  int oLLength = 7;
  int hLAmount;

  // Konstruktor bei 1. Generation an Kreaturen, Weights zufällig
  NeuralNetwork(int hLLength, int hLAmount) {
    
    this.hLAmount = hLAmount;
    
    weights = new Matrix[hLAmount+1];
    hiddenLayer = new Matrix[hLAmount];
    
    // InputSchicht wird erstellt
    inputLayer = new Matrix(iLLength, 1);
    
    // weights werden erstellt
    for(int i=0; i<hLAmount+1; i++){
      if(i==0){
        weights[i] = new Matrix(hLLength, iLLength);
        weights[i].setRandom(-1/sqrt(iLLength), 1/sqrt(iLLength));
      } else if(i==hLAmount){
        weights[i] = new Matrix(oLLength, hLLength);
        weights[i].setRandom(-1/sqrt(oLLength), 1/sqrt(oLLength));
      } else {
        weights[i] = new Matrix(hLLength, hLLength);
        weights[i].setRandom(-1/sqrt(hLLength), 1/sqrt(hLLength));
      }
    }
    
    // HiddenSchichten werden erstellt
    for(int i=0; i<hLAmount; i++){
      hiddenLayer[i] = new Matrix(hLLength, 1);      
    }
    
    // OutputSchicht wird erstellt
    outputLayer = new Matrix(oLLength, 1);
  }

  // bei weiteren Generationen an Kreaturen
  NeuralNetwork(int hLLength, Matrix[] w) {
    
    hLAmount = w.length-1;
    
    weights = new Matrix[hLAmount+1];
    hiddenLayer = new Matrix[hLAmount];
    
    // InputSchicht wird erstellt
    inputLayer = new Matrix(iLLength, 1);

    // weights werden erstellt
    for(int i=0; i<hLAmount+1; i++){
      if(i==0){
        weights[i] = new Matrix(hLLength, iLLength);
        weights[i].set(w[i].m);
      } else if(i==hLAmount){
        weights[i] = new Matrix(oLLength, hLLength);
        weights[i].set(w[i].m);
      } else {
        weights[i] = new Matrix(hLLength, hLLength);
        weights[i].set(w[i].m);
      }
    }
    
    // HiddenSchichten werden erstellt
    for(int i=0; i<hLAmount; i++){
      hiddenLayer[i] = new Matrix(hLLength, 1);      
    }

    outputLayer = new Matrix(oLLength, 1);
  }

  NeuralNetwork(String path){
    
    String rPath = path + "/NN";
    hLAmount = (int)load(0,rPath+"/HLAmount.dat");
    
    weights = new Matrix[hLAmount+1];
    hiddenLayer = new Matrix[hLAmount];
    
    // InputSchicht wird erstellt
    inputLayer = new Matrix(iLLength, 1);
    
    // weights werden erstellt
    for(int i=0; i<hLAmount+1; i++){
      weights[i] = new Matrix(rPath + "/weights/Matrix"+i);
    }
    
    // HiddenSchichten werden erstellt
    for(int i=0; i<hLAmount; i++){
      hiddenLayer[i] = new Matrix(Creature.hLLength, 1);      
    }
    
    // OutputSchicht wird erstellt
    outputLayer = new Matrix(oLLength, 1);
    
  }

  public void update() {
    for(int i=0; i<hLAmount; i++){
      if(i==0){
        hiddenLayer[i].mult(weights[i], inputLayer);
        hiddenLayer[i].tanh();
      } else {
        hiddenLayer[i].mult(weights[i], hiddenLayer[i-1]);
        hiddenLayer[i].tanh();
      }
    }
    outputLayer.mult(weights[hLAmount], hiddenLayer[hLAmount-1]);  
    outputLayer.tanh();
  }

    void saveNeuralNetwork(String path){
    File f = new File(path + "/NN");
    f.mkdir();
    
    save(hLAmount,0,f.getPath() + "/HLAmount.dat");
    
    for(int i = 0; i < hLAmount+ 1; i++){
      weights[i].saveMatrix(f.getPath() + "/weights",i);
    }  
  }

  //// setter
  public void setInputNVelocity(float v) {
    inputLayer.set(0, 0, v);
  }
  public void setInputNEnergy(float v) {
    inputLayer.set(1, 0, v);
  }
  public void setInputNFieldType(float v) {
    inputLayer.set(2, 0, v);
  }
  public void setInputNMemory(float v) {
    inputLayer.set(3, 0, v);
  }
  /*
  public void setInputNBias(float v) {
    inputLayer.set(4, 0, v);
  }
  public void setInputNDirection(float v) {
    inputLayer.set(5, 0, v);
  }
  */
  
  //// Fühler

  public void setInputNSensorEnemyEnergy(float v) {
    inputLayer.set(4, 0, v);
  }
  public void setInputNSensorFieldEnergy(float v) {
    inputLayer.set(5, 0, v);
  }
  public void setInputNSensorFieldType(float v) {
    inputLayer.set(6, 0, v);
  }
  
  //// Nicht mehr Fühler
  
  public void setInputNPartnerFitness(float v) {
    inputLayer.set(7, 0, v);
  }
  
  public void setInputNMemory2(float v){
    inputLayer.set(8,0, v);
  }

  //// OutputSchicht
  public float getGeschwindigkeit(Creature c) {
    return map(outputLayer.get(0, 0), -1, 1, 0, c.getMaxVelocity());
  }
  public float getRotation() {
    return map(outputLayer.get(1, 0), -1, 1, -Creature.maxMovementRotationAngle/2, Creature.maxMovementRotationAngle/2);
  }
  public float getMemory() {
    return outputLayer.get(2, 0);
  }
  public float getEatingWill() {
    return map(outputLayer.get(3, 0), -1, 1, 0, 1);
  }
  public float getBirthWill() {
    return map(outputLayer.get(4, 0), -1, 1, 0, 1);
  }
  public float getAttackWill() {
    return map(outputLayer.get(5, 0), -1, 1, 0, 1);
  }
  public float getMemory2() {
    return outputLayer.get(6,0);
  }

  // andere getter
  public Matrix[] getWeights() {
    return weights;
  }
}