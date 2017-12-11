
public class Lebewesen{
  
  private PVector geschwindigkeit;
  private PVector position;
  
  private float durchmesser = 15; // muss an Welt skaliert werden
  private float fressrate = 5;
  private float maxGeschwindigkeit = 10;
  private float energie = 400.0;
  private float maxEnergie = 400.0;
  private color fellFarbe;
  private float verbrauchBewegung = 7;
  private float wasserreibung = 0.02;
  private NeuralNetwork NN;
  
  // sollte bei 1. Generation verwendet werden
  Lebewesen(int x, int y){
    fellFarbe = color((int)random(0,256), (int)random(0,256), (int)random(0,256));
    NeuralNetwork NN = new NeuralNetwork(2,5);
    geschwindigkeit = new PVector(maxGeschwindigkeit,maxGeschwindigkeit);
    geschwindigkeit.limit(maxGeschwindigkeit);
    
    position = new PVector(x,y);
   
  }
  
  // 2. Konstruktor, damit die Farbe bei den Nachkommen berücksichtigt werden kann
  Lebewesen(int x, int y, color c){
    fellFarbe = c;
    NeuralNetwork NN = new NeuralNetwork(2,5);
    geschwindigkeit = new PVector(maxGeschwindigkeit,maxGeschwindigkeit);
    geschwindigkeit.limit(maxGeschwindigkeit);
    
    position = new PVector(x,y);
    
  }
  
  public void drawLebewesen(){
    fill(fellFarbe);
    ellipse(position.x, position.y, durchmesser, durchmesser);
  }
  
  // Bewewgung
  public void bewegen(float v, float angle){ // Rotationswinkel in Grad
    if (energie-verbrauchBewegung>=0 && v<maxGeschwindigkeit && v>0){ // 3. Fall sollte nicht auftreten, weil das NN die Richtung nicht über v, sondern angle bestimmt
      energie-=verbrauchBewegung;
      geschwindigkeit.rotate(radians(angle));
      geschwindigkeit.setMag(v);
      
      // im Wasser bewegen sich die Lebewesen langsamer
      if(map.getFeld((int)position.x,(int)position.y).isLand() ==0){
        position.add(geschwindigkeit);
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
  //INputen
  void input(){
    // Farbe
    // NN.inputSchicht[0].setWert(green(fellFarbe));    
    // NN.inputSchicht[1].setWert(red(fellFarbe));
    // NN.inputSchicht[2].setWert(blue(fellFarbe));
    NN.inputSchicht[0].setWert(energie);
    NN.inputSchicht[1].setWert(map.getFeld((int)position.x,(int)position.y).isLand());
  
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
  
  // getter 
  // Intervall von [-PI;PI[
  public float getWinkelRad(){
    return geschwindigkeit.heading();
  }
  // 360 Grad
  public float getWinkelDeg(){
    return degrees(geschwindigkeit.heading());
  }
}
