public class NeuralNetwork {

  // erklärt in Video
  
  Matrix inputLayer;
  Matrix outputLayer;
  
  Matrix[] weights;
  Matrix[] hiddenLayer;


  int iLLength = 10;
  int oLLength = 6;
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

  public void update() {
    for(int i=0; i<hLAmount; i++){
      if(i==0){
        hiddenLayer[i].mult(inputLayer, weights[i]);
        hiddenLayer[i].sigmoid();
      } else {
        hiddenLayer[i].mult(hiddenLayer[i-1], weights[i]);
        hiddenLayer[i].sigmoid();
      }
    }
    outputLayer.mult(hiddenLayer[hLAmount-1], weights[hLAmount]);  
    outputLayer.sigmoid();
  }

  //// getter
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
  public void setInputNBias(float v) {
    inputLayer.set(4, 0, v);
  }
  public void setInputNDirection(float v) {
    inputLayer.set(5, 0, v);
  }
  
  //// Fühler

  public void setInputNSensorEnemyEnergy(float v) {
    inputLayer.set(6, 0, v);
  }
  public void setInputNSensorFieldEnergy(float v) {
    inputLayer.set(7, 0, v);
  }
  public void setInputNSensorFieldType(float v) {
    inputLayer.set(8, 0, v);
  }
  
  //// Nicht mehr Fühler
  
  public void setInputNPartnerFitness(float v) {
    inputLayer.set(9, 0, v);
  }

  //// OutputSchicht
  public float getGeschwindigkeit(Creature c) {
    return outputLayer.get(0, 0) * c.getMaxVelocity();
  }
  public float getRotation() {
    return map(outputLayer.get(1, 0), 0, 1, -Creature.maxMovementRotationAngle/2, Creature.maxMovementRotationAngle/2);
  }
  public float getMemory() {
    return outputLayer.get(2, 0);
  }
  public float getEatingWill() {
    return outputLayer.get(3, 0);
  }
  public float getBirthWill() {
    return outputLayer.get(4, 0);
  }

  public float getAttackWill() {
    return outputLayer.get(5, 0);
  }

  // andere getter
  public Matrix[] getWeights() {
    return weights;
  }
}