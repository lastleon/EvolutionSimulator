
public class Lebewesen{
  
  private PVector geschwindigkeit;
  private PVector position;
  
  private float durchmesser = 15; // muss an Welt skaliert werden
  private float fressrate = 5;
  private float maxGeschwindigkeit = 4; //GEN
  private float energie = 1400.0;
  private float maxEnergie = 1400.0; 
  private color fellFarbe;
  private float verbrauchBewegung = 7;
  private float wasserreibung = 0.02;
  
  private NeuralNetwork NN;
  private float memory = 1; // GEN
  
  // sollte bei 1. Generation verwendet werden
  Lebewesen(int x, int y){
    
    NN = new NeuralNetwork(7);
    
    fellFarbe = color((int)random(0,256), (int)random(0,256), (int)random(0,256));
    geschwindigkeit = new PVector(maxGeschwindigkeit,maxGeschwindigkeit);
    geschwindigkeit.limit(maxGeschwindigkeit);
    
    position = new PVector(x,y);
  }
  
  // 2. Konstruktor, damit die Farbe bei den Nachkommen berücksichtigt werden kann
  Lebewesen(int x, int y, color c){
    NN = new NeuralNetwork(3,5);
    fellFarbe = c;
    
    geschwindigkeit = new PVector(maxGeschwindigkeit,maxGeschwindigkeit);
    geschwindigkeit.limit(maxGeschwindigkeit);
    
    position = new PVector(x,y);
  }
  
  public void drawLebewesen(){
    fill(fellFarbe);
    ellipse(position.x, position.y, durchmesser, durchmesser);
  }
  
  // NeuralNetwork input
  public void input(){
    // Geschwindigkeit
    NN.getInputNGeschwindigkeit().setWert(map(geschwindigkeit.mag(), 0, maxGeschwindigkeit, -6, 6));
    // Fellfarbe
    NN.getInputNFellRot().setWert(map(red(fellFarbe), 0, 255, -1, 1));
    NN.getInputNFellGruen().setWert(map(green(fellFarbe), 0, 255, -1, 1));
    NN.getInputNFellBlau().setWert(map(blue(fellFarbe), 0, 255, -1, 1));
    // eigene Energie
    NN.getInputNEnergie().setWert(map(energie, 0, maxEnergie, -1, 1));
    // Feldart
    NN.getInputNFeldart().setWert(map(map.getFeld((int)position.x, (int)position.y).isLandInt(), 0, 1, -1, 1));
    // Memory
    NN.getInputNMemory().setWert(map(memory, 0, 1, -1, 1));
    // Bias // immer 1
    NN.getInputNBias().setWert(1);
    // Richtung
    NN.getInputNRichtung().setWert(map(degrees(geschwindigkeit.heading()), 0, 360, -1, 1));
  }
  
  // Bewewgung
  public void bewegen(float v, float angle){ // Rotationswinkel in Grad
    if (energie-verbrauchBewegung>=0 && v<maxGeschwindigkeit && v>=0){
      energie-=verbrauchBewegung;
      geschwindigkeit.rotate(radians(angle));
      geschwindigkeit.setMag(v);
      
      // im Wasser bewegen sich die Lebewesen langsamer
      if(!map.getFeld((int)position.x,(int)position.y).isLand()){
        position.add(geschwindigkeit.mult(1-wasserreibung));
      } else {
        position.add(geschwindigkeit);
      }

      // Lebewesen werden auf die gegenüberliegende Seite teleportiert, wenn sie außerhalb der Map sind
      if (position.x > fensterGroesse){ // wenn zu weit rechts        
        position.set(position.x-fensterGroesse, position.y);
      }
      if (position.x < 0){ // wenn zu weit links       
        position.set(fensterGroesse+position.x, position.y); // + position.x, weil es immer ein negativer Wert ist
      }
      if (position.y > fensterGroesse){ // wenn zu weit unten
        position.set(position.x, position.y-fensterGroesse);
      }
      if (position.y < 0){ // wenn zu weit oben
        position.set(position.x, fensterGroesse+position.y); // + position.y, weil es immer ein negativer Wert ist
      }
      
    }
  }
  // Fressen
  public void fressen(){
    Feld feld = map.getFeld((int)position.x,(int)position.y);
    float neueFeldEnergie = feld.getEnergie() - fressrate;
    
    if (neueFeldEnergie>=0){ // Feld hat genug Energie
      energie += fressrate;
      feld.setEnergie((int)neueFeldEnergie);
    } else { // Feld hat zu wenig Energie
      energie += feld.getEnergie();
      feld.setEnergie(0);
    }
    
    if (energie>maxEnergie){ // Lebewesen-Energie ist über dem Maximum
      feld.setEnergie((int)(feld.getEnergie()+(energie-maxEnergie)));
      energie = maxEnergie;
    }
  }
  
  public void erinnern(float m){
    memory = m;
  }
  
  public void fellfarbeAendern(float r, float g, float b){
    fellFarbe = color(r,g,b);
  }
  
  // getter 
  
  public float getMaxGeschwindigkeit(){
    return maxGeschwindigkeit;
  }
}