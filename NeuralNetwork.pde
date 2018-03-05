public class NeuralNetwork {

  Matrix inputSchicht;
  Matrix w1;
  Matrix hiddenSchicht1;
  Matrix w2;
  Matrix outputSchicht;


  private int iSLaenge = 10; // Grund in NN_Planung.txt ersichtlich
  private int oSLaenge = 6; // Grund in NN_Planung.txt ersichtlich


  NeuralNetwork(int hS1) { // hiddenSchicht1
    // Input Neuronen werden erstellt


    inputSchicht = new Matrix(iSLaenge, 1);

    w1 = new Matrix(hS1, iSLaenge);
    w1.setRandom(-1/sqrt(iSLaenge), 1/sqrt(iSLaenge));

    hiddenSchicht1 = new Matrix(hS1, 1);
    // Hidden Neuronen (1 Schicht) werden erstellt
    w2 = new Matrix(oSLaenge, hS1);
    w2.setRandom(-1/sqrt(hS1), 1/sqrt(hS1));

    outputSchicht = new Matrix(oSLaenge, 1);
  }


  NeuralNetwork(int hS1, Matrix c1, Matrix c2) { // hiddenSchicht1
    // Input Neuronen werden erstellt

    
    inputSchicht = new Matrix(iSLaenge, 1);

    w1 = new Matrix(hS1, iSLaenge);
    w1.set(c1.m);

    hiddenSchicht1 = new Matrix(hS1, 1);
    // Hidden Neuronen (1 Schicht) werden erstellt
    w2 = new Matrix(oSLaenge, hS1);
    w2.set(c2.m);

    outputSchicht = new Matrix(oSLaenge, 1);
  }


  public void update() {
    hiddenSchicht1.mult(inputSchicht, w1);
    hiddenSchicht1.sigmoid();
    outputSchicht.mult(hiddenSchicht1, w2);  
    outputSchicht.sigmoid();
  }

  //// getter
  // InputNeuronen, setzt voraus dass so viele Neuronen generiert wurden, wie es hier Werte gibt
  public void setInputNGeschwindigkeit(float v) {
    inputSchicht.set(0, 0, v);
  }
  public void setInputNEnergie(float v) {
    inputSchicht.set(1, 0, v);
  }
  public void setInputNFeldart(float v) {
    inputSchicht.set(2, 0, v);
  }
  public void setInputNMemory(float v) {
    inputSchicht.set(3, 0, v);
  }
  public void setInputNBias(float v) {
    inputSchicht.set(4, 0, v);
  }
  public void setInputNRichtung(float v) {
    inputSchicht.set(5, 0, v);
  }
  
  ////Fuehler

  public void setInputNFuehlerGegnerEnergie(float v) {
    inputSchicht.set(6, 0, v);
  }
  public void setInputNFuehlerFeldEnergie(float v) {
    inputSchicht.set(7, 0, v);
  }
  public void setInputNFuehlerFeldArt(float v) {
    inputSchicht.set(8, 0, v);
  }
  
  ////Nicht mehr Fühler
  
  public void setInputNPartnerFitness(float v) {
    inputSchicht.set(9, 0, v);
  }

  // OutputNeuronen
  public float getGeschwindigkeit(Lebewesen lw) {
    return outputSchicht.get(0, 0) * lw.getMaxGeschwindigkeit();
  }
  public float getRotation() {
    return map(outputSchicht.get(1, 0), 0, 1, -Lebewesen.maxRotationswinkelBewegung/2, Lebewesen.maxRotationswinkelBewegung/2); // muss noch sehen, wie die Rotation wirklich laeuft
  }
  public float getRotationPur(){
    return outputSchicht.get(1,0);
  }
  public float getMemory() {
    return outputSchicht.get(2, 0);
  }
  public float getFresswille() {
    return outputSchicht.get(3, 0);
  }
  public float getGeburtwille() {
    return outputSchicht.get(4, 0);
  }

  public float getAngriffswille() {
    return outputSchicht.get(5, 0);
  }

  // Fuehler

  // andere getter
  public Matrix getConnections1() {
    return w1;
  }
  public Matrix getConnections2() {
    return w2;
  }
}