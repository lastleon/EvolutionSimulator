
public class Lebewesen {

  public final static int maxRotationswinkelBewegung = 20; /////////////////////////////// Version mit veraenderter Mutation
  public final static int maxRotationswinkelFuehler = 10;

  private PVector geschwindigkeit;
  private PVector position;

  private float mutationsrate = 0.5;
  private float durchmesser; // muss an Welt skaliert werden
  private float fressrate = Welt.stdFressrate;
  private float maxGeschwindigkeit = Welt.stdMaxGeschwindigkeit; //GEN
  private float energie = 600.0; // 500
  private float maxEnergie = 2100.0; // 2000
  private color fellFarbe;
  private float verbrauchBewegung = 3;
  private float verbrauchWasserbewegung = 5;
  private float wasserreibung = 0.1;
  private float energieverbrauch = 2;
  private boolean lebend = true;
  public final static float geburtsenergie = 500;
  private float reproduktionswartezeit = Welt.stdReproduktionswartezeit;
  private float angriffswert = Welt.stdAngriffswert;
  public final static float reproduktionswille = 0.4;
  private boolean geburtsbereit = false;
  private float letzteGeburt = 0;
  private float reproduktionsschwellwert = 0.5;
  private float mixSchwellwert = 0.1;
  private boolean rot = false;
  private float rotzeit = 0;
  private int generation;
  
  private int id;
  
  private boolean inTop10 = false;
  
  float fitness = 0;

  private double alter = 0;

  private Fuehler fuehler;

  private NeuralNetwork NN;
  private float memory = 1; // GEN


  // sollte bei 1. Generation verwendet werden
  Lebewesen(int x, int y, float fB, int ID) {
    
    id = ID;
    durchmesser = fB*1.25;
    
    generation = 0;

    NN = new NeuralNetwork(7);

    geschwindigkeit = new PVector(maxGeschwindigkeit, maxGeschwindigkeit);
    geschwindigkeit.limit(maxGeschwindigkeit);

    position = new PVector(x, y);
    
    fuehler = new Fuehler(this);
        
    fellFarbe = color((int)random(0, 256), (int)random(0, 256), (int)random(0, 256));
  }

  // 2. Konstruktor, damit die Farbe bei den Nachkommen berücksichtigt werden kann und die Gewichte übergeben werden können
  Lebewesen(int x, int y, Matrix c11, Matrix c12, Matrix c21, Matrix c22, color fellfarbe1, color fellfarbe2, int g, float f1, float mG1, float r1, float a1, float f2, float mG2, float r2, float a2, int ID) {
    
    id = ID;
    durchmesser = map.getFeldbreite()*1.25;
    
    fressrate = mutieren(mixGenes(f1, f2));
    maxGeschwindigkeit = mutieren(mixGenes(mG1, mG2));
    reproduktionswartezeit = mutieren(mixGenes(r1, r2));
    angriffswert = mutieren(mixGenes(a1, a2));

    generation = g+1;
    //energie = geburtsenergie;

    // fellfarbe wird random aus beiden Elternteilen gewaehlt
    if(random(0,1)>0.5){
      fellFarbe = fellfarbe1;
    } else {
      fellFarbe = fellfarbe2;
    }
    
    fellFarbe = fellfarbeMutieren(fellFarbe);

    // Connections
    Matrix c1;
    Matrix c2;

    c1 = this.mixMatrix(c11, c21);
    c2 = this.mixMatrix(c12, c22);

    c1 = mutieren(c1);
    c2 = mutieren(c2);

    NN = new NeuralNetwork(7, c1, c2);

    geschwindigkeit = new PVector(maxGeschwindigkeit, maxGeschwindigkeit);
    geschwindigkeit.limit(maxGeschwindigkeit);

    position = new PVector(x, y);
    
    fuehler = new Fuehler(this);
  }

  public void drawLebewesen() {
    PVector richtung = new PVector(geschwindigkeit.x, geschwindigkeit.y);
    durchmesser = map.stdDurchmesser * energie/2000 + 10 ;
    if(durchmesser<0) {
      durchmesser = 0;
    }
    if (rotzeit == 0) {
      fill(fellFarbe);
    } else if (rot) {
      fill(255, 0, 0);
      rotzeit--;
    } else {
      fill(fellFarbe);
      rotzeit--;
    }
    if (rotzeit %4==0) {
      rot = !rot;
    }
    fuehler.drawFuehler();
    richtung.setMag(durchmesser/2);
    ellipse(position.x, position.y, durchmesser , durchmesser );
    if(inTop10){
      textSize(14);
      textAlign(CENTER);
      text("E: " + int(energie), position.x, position.y - 54);
      text("FR: " + fressrate, position.x, position.y-43);
      text("V: " + maxGeschwindigkeit, position.x, position.y-32);
      text("RW: " + reproduktionswartezeit, position.x, position.y-21);
      text("A: " + angriffswert, position.x, position.y-10);
    }
  }
  
  void updateFitness(){
    fitness = this.calculateFitnessStandard();
    if(map.fitnessMaximum<fitness){
      map.fitnessMaximum = fitness;
    }
  }

  // NeuralNetwork input
  public void input() {
    // Geschwindigkeit
    NN.setInputNGeschwindigkeit(map(geschwindigkeit.mag(), 0, maxGeschwindigkeit, -6, 6));
    // eigene Energie
    NN.setInputNEnergie(map(energie, 0, maxEnergie, -6, 6));
    // Feldart
    //println("\n\ngetInputNFeldArt");
    NN.setInputNFeldart(map(map.getFeld((int)position.x, (int)position.y).isLandInt(), 0, 1, -6, 6));
    // Memory
    NN.setInputNMemory(map(memory, 0, 1, -6, 6));
    // Bias // immer 1
    NN.setInputNBias(1);
    // Richtung
    NN.setInputNRichtung(map(degrees(geschwindigkeit.heading()), -180, 180, -6, 6));
    // Mating Partner Fitness
    Lebewesen partner = fuehler.getFuehlerPartner();
    if(partner != null){
      //println(partner.calculateFitnessStandard() + " " + map.calculateFitnessMaximum());
      //println(partner.fitness + " " + map.fitnessMaximum + " " + partner.fitness/map.fitnessMaximum);
      //println(partner.fitness/map.fitnessMaximum);
      NN.setInputNPartnerFitness(map(partner.fitness/map.fitnessMaximum, 0, 1, -6, 6));
    } else {
      NN.setInputNPartnerFitness(-6);
    }

    //// Fuehler 
    
    // Gegnerenergie
    //float[] gegnerEnergie1 = fuehler1.getFuehlerGegnerEnergie();
    NN.setInputNFuehlerGegnerEnergie(map(fuehler.getFuehlerGegnerEnergie(), 0, maxEnergie, -6, 6));// maxEnergie muss geändert werden, falls die maximale Energie von Tier zu Tier variieren kann
    // Feldenergie
    //float[] feldEnergie1 = fuehler1.getFuehlerFeldEnergie();
    NN.setInputNFuehlerFeldEnergie(map(fuehler.getFuehlerFeldEnergie(), 0, Feld.maxEnergiewertAllgemein, -6, 6));
    // Feldart
    NN.setInputNFuehlerFeldArt(map(fuehler.getFuehlerFeldArt(), 0, 1, -6, 6));
  }

  // Bewewgung
  public void bewegen(float v, float angle) { // rotationswinkel in Grad
    if (v<maxGeschwindigkeit && v>=0) { // Bewegungsverbrauch passt sich an momentane geschwindigkeit an
      energie-=verbrauchBewegung*(v*0.75);
      geschwindigkeit.rotate(radians(angle));
      this.fuehler.fuehlerRotieren(angle);
      geschwindigkeit.setMag(v);

      // im Wasser bewegen sich die Lebewesen langsamer und verbrauchen mehr Energie
      if (!map.getFeld((int)position.x, (int)position.y).isLand()) {
        position.add(geschwindigkeit.mult(1-wasserreibung));
        energie -= verbrauchWasserbewegung;
      } else {
        position.add(geschwindigkeit);
      }

      // Lebewesen werden auf die gegenüberliegende Seite teleportiert, wenn sie außerhalb der Map sind
      if (position.x > fensterGroesse) { // wenn zu weit rechts        
        position.set(position.x-fensterGroesse, position.y);
      }
      if (position.x < 0) { // wenn zu weit links       
        position.set(fensterGroesse+position.x, position.y); // + position.x, weil es immer ein negativer Wert ist
      }
      if (position.y > fensterGroesse) { // wenn zu weit unten
        position.set(position.x, position.y-fensterGroesse);
      }
      if (position.y < 0) { // wenn zu weit oben
        position.set(position.x, fensterGroesse+position.y); // + position.y, weil es immer ein negativer Wert ist
      }
    }
  }
  // Angriff auf Gegner
  public void angriff(float wille) {
    if (wille > 0.5) {
      addEnergie(-energieverbrauch*(angriffswert*0.5));
      // Opfer nur DIREKT vor dem Lebewesen (d.h. in Geschwindigkeitsrichtung) kann angegriffen werden
      PVector opferPosition = new PVector(cos(geschwindigkeit.heading())*(durchmesser/2)+position.x, sin(geschwindigkeit.heading())*(durchmesser/2)+position.y);

      Lebewesen opfer = map.getTier(opferPosition);
      if(opfer==this){
        opfer = null;
      }

      if (!(opfer == null)) {
        if (opfer.getEnergie() >= angriffswert) {
          opfer.addEnergie(-angriffswert);
          this.addEnergie(angriffswert);
        } else {
          this.addEnergie(opfer.getEnergie());
          opfer.setEnergie(0);
        }
        if (energie>maxEnergie) { // Lebewesen-Energie ist über dem Maximum
          energie = maxEnergie;
        }
        opfer.hit();
      }
    }
  }

  // Grundverbrauch
  public void leben() {
    energie -= energieverbrauch*(alter/100);
  }
  public void hit() {
    rotzeit = 30;
  }

  // Fitnessfunktion // Fitness wird nur beim Rufen der Methode gerufen
  public float calculateFitnessStandard() { // berechnet die Fitness des Tieres im Bezug auf die Standardwerte
    float bias = 0.1;
    float a = log((float)(alter+1));
    float g = log((float)(generation+1))*1.5;
    float fressrate = ((this.getFressrate() - Welt.stdFressrate)/Welt.stdFressrate)*2;
    float maxV = ((this.getMaxGeschwindigkeit() - Welt.stdMaxGeschwindigkeit)/Welt.stdMaxGeschwindigkeit)*2;
    float angriff = ((this.getAngriffswert() - Welt.stdAngriffswert)/Welt.stdAngriffswert)*2;
    float wartezeit = (Welt.stdReproduktionswartezeit/this.getReproduktionswartezeit() - 1)*2;
    float result = (bias + a + g + fressrate + maxV + angriff + wartezeit);
    if(result < 0){                                                                                                                  /////////////////        SCHLECHT!!!
      result = 0;
    }
    //println(a + " " + g + " " + fressrate + " " + maxV + " " + angriff + " " + wartezeit + " " + result);
    //println((bias + a + g + fressrate + maxV + angriff + wartezeit) + "/" + map.fitnessMaximum);
    //println(result);
    return result;
  }

  public float calculateFitnessIndividual(Lebewesen partner) { // berechnet die Fitness des Tieres im Bezug auf eigene Werte
    return 0.0;
  }
  // Fressen
  public void fressen(float wille) {
    if (wille > 0.5) {
      energie -= energieverbrauch*(alter/4);
      //println("\n\nfressen");
      Feld feld = map.getFeld((int)position.x, (int)position.y);
      float neueFeldEnergie = feld.getEnergie() - fressrate;

      if (neueFeldEnergie>=0) { // Feld hat genug Energie
        energie += fressrate;
        feld.setEnergie((int)neueFeldEnergie);
      } else { // Feld hat zu wenig Energie
        energie += feld.getEnergie();
        feld.setEnergie(0);
      }

      if (energie>maxEnergie) { // Lebewesen-Energie ist über dem Maximum
        feld.setEnergie((int)(feld.getEnergie()+(energie-maxEnergie)));
        energie = maxEnergie;
      }
    }
  }

  // Gebaeren
  // wird in Welt Klasse verlegt

  /*
  if(wille > 0.5 && energie >= geburtsenergie && ((float)alter % reproduktionsWartezeit == 0)){ // Bedingung ist so seltsam, weil das Alter ungenau ist
   energie -= geburtsenergie;
   map.addLebewesen(new Lebewesen((int)position.x, (int)position.y, NN.getConnections1(), NN.getConnections2(), fellFarbe));
   println("Ein neues Früchtchen ist entsprungen!");
   }
   */  // Das wird viel :((

  public boolean collision(Lebewesen lw) {
    float abstand = map.entfernungLebewesen(this, lw);
    if (abstand <= durchmesser) {
      return true;
    } else {
      return false;
    }
  }
  public color fellfarbeMutieren(color fellfarbe) {

    float r = red(fellfarbe) + red(fellfarbe) * random(-0.3, 0.3);
    float g = green(fellfarbe) + green(fellfarbe) * random(-0.3, 0.3);
    float b = blue(fellfarbe) + blue(fellfarbe) * random(-0.3, 0.3);

    if (r < 0) {
      r = 0;
    } else if (r > 255) {
      r = 255;
    }
    if (g < 0) {
      g = 0;
    } else if (g > 255) {
      g = 255;
    }
    if (b < 0) {
      b = 0;
    } else if (b > 255) {
      b = 255;
    }
    return color(r, g, b);
  }
  

  // mutiert Gewichte
  public Matrix mutieren(Matrix m) {
    for (int x=0; x<m.rows; x++) {
      for (int y=0; y<m.cols; y++) {
        if (random(0, 1)>0.3) {
          float multiplikator = random(-mutationsrate, mutationsrate);
          float neuerWert = m.get(x,y)+multiplikator*m.get(x,y);
          if(neuerWert > 1){
            neuerWert = 1;
          }else if(neuerWert < 0){
            neuerWert = 0;
          }
          m.set(x,y,neuerWert);
        }
      }
    }
    return m;
  }
  public float mutieren(float x) { // x ist der Wert, der mutiert wird
    float a = x;
    if (random(0, 1)>0.5) {
      a += random(-mutationsrate, mutationsrate)*x/4;
    }
    return a;
  }

  public Matrix mixMatrix(Matrix c1, Matrix c2) { // nimmt an, dass c1 und c2 gleich gross sind
    Matrix mixedConnections = new Matrix(c1.rows,c1.cols);
    mixedConnections.copyM(c1);
    // mixedConnections wird zu Kopie von c1
    // Gewichte werden vermischt
    for (int x=0; x<c1.rows; x++) {
      for (int y=0; y<c1.cols; y++) {
        if (random(0, 1) > mixSchwellwert) {
          mixedConnections.set(x,y,c2.get(x,y));
        }
      }
    }
    return mixedConnections;
  }

  public float mixGenes(float g1, float g2) {
    if (random(0, 1)>reproduktionsschwellwert) {
      return g1;
    } else return g2;
  }


  public void altern() {
    alter += map.getZeitProFrame();
    float neuesAlter = (float)(alter * map.getZeitMultiplikator());
    alter = (double)floor(neuesAlter) / (double)map.getZeitMultiplikator();

    // geburtsbereit
    if (alter - letzteGeburt >= reproduktionswartezeit) {
      geburtsbereit = true;
    } else {
      geburtsbereit = false;
    }
  }

  public void erinnern(float m) {
    memory = m;
  }

  public void fellfarbeAendern(float r, float g, float b) {
    fellFarbe = color(r, g, b);
  }

  public void addEnergie(float e) {
    energie += e;
  }

  public void setEnergie(float e) {
    energie = e;
  }

  public void setLetzteGeburt(float lG) {
    letzteGeburt = lG;
  }

  // getter 
  public boolean getStatus() {
    if (energie<=0) {
      lebend = false;
    }
    return lebend;
  }
  public float getMaxGeschwindigkeit() {
    return maxGeschwindigkeit;
  }
  public float getEnergie() {
    return energie;
  }
  public float getMaxEnergie() {
    return maxEnergie;
  }
  public PVector getPosition() {
    return position;
  }
  public double getAlter() {
    return alter;
  }
  public boolean isGeburtsbereit() {
    return geburtsbereit;
  }
  public color getFellfarbe() {
    return fellFarbe;
  }
  public float getDurchmesser() {
    return durchmesser;
  }
  public int getGeneration() {
    return generation;
  }
  public float getFressrate() {
    return fressrate;
  }
  public float getAngriffswert() {
    return angriffswert;
  }
  public float getReproduktionswartezeit() {
    return reproduktionswartezeit;
  }
  public int getID(){
    return id;
  }
}