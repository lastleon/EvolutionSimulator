
public class Lebewesen{
  
  public final static int maxRotationswinkelBewegung = 10; /////////////////////////////// Version mit veraenderter Mutation
  public final static int maxRotationswinkelFuehler = 180;
  
  private PVector geschwindigkeit;
  private PVector position;
  
  private float mutationsrate = 0.5;
  private float durchmesser = 10; // muss an Welt skaliert werden
  private float fressrate = 20;
  private float maxGeschwindigkeit = 3; //GEN
  private float energie = 300.0;
  private float maxEnergie = 1400.0; 
  private color fellFarbe = fellFarbe = color((int)random(0,256), (int)random(0,256), (int)random(0,256));
  private float verbrauchBewegung = 7;
  private float wasserreibung = 0.02;
  private float energieverbrauch = 3;
  private boolean lebend = true;
  private float geburtsenergie = 200;
  private float reproduktionsWartezeit = 0.3;
  
  private double alter = 0;
  
  private Fuehler fuehler1;
  private Fuehler fuehler2;
  
  private NeuralNetwork NN;
  private float memory = 1; // GEN
  
  // sollte bei 1. Generation verwendet werden
  Lebewesen(int x, int y){
    
    NN = new NeuralNetwork(14);
    
    geschwindigkeit = new PVector(maxGeschwindigkeit,maxGeschwindigkeit);
    geschwindigkeit.limit(maxGeschwindigkeit);
    
    position = new PVector(x,y);
    
    fuehler1 = new Fuehler(this);
    fuehler2 = new Fuehler(this);
    
  }
  
  // 2. Konstruktor, damit die Farbe bei den Nachkommen berücksichtigt werden kann und die Gewichte übergeben werden können // Mutationen noch nicht implementiert
  Lebewesen(int x, int y, Connection[][] c1, Connection[][] c2){
    
    energie = geburtsenergie;
    c1 = mutieren(c1);
    c2 = mutieren(c2);
    
    NN = new NeuralNetwork(14, c1, c2);
    
    geschwindigkeit = new PVector(maxGeschwindigkeit,maxGeschwindigkeit);
    geschwindigkeit.limit(maxGeschwindigkeit);
    
    position = new PVector(x,y);
    
    fuehler1 = new Fuehler(this);
    fuehler2 = new Fuehler(this);
  }
  
  public void drawLebewesen(){
    fill(fellFarbe);
    fuehler1.drawFuehler();
    fuehler2.drawFuehler();
    ellipse(position.x, position.y, durchmesser, durchmesser);
  }
  
  // NeuralNetwork input
  public void input(){
    // Geschwindigkeit
    NN.getInputNGeschwindigkeit().setWert(map(geschwindigkeit.mag(), 0, maxGeschwindigkeit, -1, 1));
    // Fellfarbe
    NN.getInputNFellRot().setWert(map(red(fellFarbe), 0, 255, -1, 1));
    NN.getInputNFellGruen().setWert(map(green(fellFarbe), 0, 255, -1, 1));
    NN.getInputNFellBlau().setWert(map(blue(fellFarbe), 0, 255, -1, 1));
    // eigene Energie
    NN.getInputNEnergie().setWert(map(energie,0,maxEnergie,-1,1));
    // Feldart
    NN.getInputNFeldart().setWert(map(map.getFeld((int)position.x, (int)position.y).isLandInt(), 0, 1, -1, 1));
    // Memory
    NN.getInputNMemory().setWert(map(memory, 0, 1, -1, 1));
    // Bias // immer 1
    NN.getInputNBias().setWert(1);
    // Richtung
    NN.getInputNRichtung().setWert(map(degrees(geschwindigkeit.heading()), 0, 360, -1, 1));
    
    
    //// Fuehler 1
    // Richtung Fuehler 
    NN.getInputNFuehlerRichtung1().setWert(map(degrees(fuehler1.position.heading()), 0, 360, -1, 1));
    // Gegnerenergie
    //float[] gegnerEnergie1 = fuehler1.getFuehlerGegnerEnergie();
    NN.getInputNFuehlerGegnerEnergie1().setWert(map(fuehler1.getFuehlerGegnerEnergie(), 0, 1400, -1, 1));
    // Feldenergie
    //float[] feldEnergie1 = fuehler1.getFuehlerFeldEnergie();
    NN.getInputNFuehlerFeldEnergie1().setWert(map(fuehler1.getFuehlerFeldEnergie(), 0, 80, -1, 1));
    // Feldart
    NN.getInputNFuehlerFeldArt1().setWert(map(fuehler1.getFuehlerFeldArt(), 0, 1, -1, 1));
    
    //// Fuehler 2
    // Richtung Fuehler
    NN.getInputNFuehlerRichtung2().setWert(map(degrees(fuehler2.position.heading()), 0, 360, -1, 1));
    // Gegnerenergie
    //float[] gegnerEnergie2 = fuehler2.getFuehlerGegnerEnergie();
    NN.getInputNFuehlerGegnerEnergie2().setWert(map(fuehler2.getFuehlerGegnerEnergie(), 0, 1400, -1, 1));
    // Feldenergie
    //float[] feldEnergie2 = fuehler2.getFuehlerFeldEnergie();
    NN.getInputNFuehlerFeldEnergie2().setWert(map(fuehler2.getFuehlerFeldEnergie(), 0, 80, -1, 1));
    // Feldart
    NN.getInputNFuehlerFeldArt2().setWert(map(fuehler2.getFuehlerFeldArt(), 0, 1, -1, 1));
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
  
  // Grundverbrauch
  public void leben(){
    energie -= energieverbrauch*(alter/2);
  }
  
  // Fressen
  public void fressen(float wille){
    if(wille > 0.5){
      energie -= energieverbrauch*(alter/2);
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
  }
  
  // Gebaeren
  public void gebaeren(float wille){
    if(wille > 0.5 && energie >= geburtsenergie && (alter % reproduktionsWartezeit >= 0.0 && alter % reproduktionsWartezeit <0.0005) && alter > 0.1){
      energie -= geburtsenergie;
      map.addLebewesen(new Lebewesen((int)position.x, (int)position.y, NN.getConnections1(), NN.getConnections2()));
      println("Ein neues Früchtchen ist entsprungen!");
    }
    
  }
  
  // Fuehler 1 rotieren
  public void fuehlerRotieren1(float angle){
    fuehler1.fuehlerRotieren(angle);
  }
  
  // Fuehler 2 rotieren
  public void fuehlerRotieren2(float angle){
    fuehler2.fuehlerRotieren(angle);
  }
  
  // mutiert Gewichte
  public Connection[][] mutieren(Connection[][] cArr){
    for(int x=0; x<cArr.length; x++){
      for(Connection c : cArr[x]){
        float chance = random(0,1);
        if(chance>0.3){
          float multiplizierer = random(-mutationsrate,mutationsrate);
          c.setWeight(c.getWeight()+c.getWeight() * multiplizierer);
        }
      }
    }
    return cArr;
  }
  
  public void altern(){
    alter += map.getZeitProFrame();
  }
  
  public void erinnern(float m){
    memory = m;
  }
  
  public void fellfarbeAendern(float r, float g, float b){
    fellFarbe = color(r,g,b);
  }
  
  // getter 
  public boolean getStatus(){
    if(energie<0){
      lebend = false;
    }
    return lebend;
  }
  public float getMaxGeschwindigkeit(){
    return maxGeschwindigkeit;
  }
  public float getEnergie(){
    return energie;
  }
  public float getMaxEnergie(){
    return maxEnergie;
  }
  public PVector getPosition(){
    return position;
  }
}