
public class Lebewesen {

  public final static int maxRotationswinkelBewegung = 20; /////////////////////////////// Version mit veraenderter Mutation
  public final static int maxRotationswinkelFuehler = 10;

  private PVector geschwindigkeit;
  private PVector position;

  private float mutationsrate = 0.5;
  private float durchmesser; // muss an Welt skaliert werden
  private float fressrate = Welt.stdFressrate;
  private float maxGeschwindigkeit = Welt.stdMaxGeschwindigkeit; //GEN
  private float energie = 500.0;
  private float maxEnergie = 2000.0; 
  private color fellFarbe;
  private float verbrauchBewegung = 3;
  private float verbrauchWasserbewegung = 2;
  private float wasserreibung = 0.1;
  private float energieverbrauch = 2;
  private boolean lebend = true;
  public final static float geburtsenergie = 200;
  private float reproduktionswartezeit = Welt.stdReproduktionswartezeit;
  private float angriffswert = Welt.stdAngriffswert;
  public final static float reproduktionswille = 0.4;
  private boolean geburtsbereit = false;
  private float letzteGeburt = 0;
  private float reproduktionsschwellwert = 0.5;
  private boolean rot = false;
  private float rotzeit = 0;
  private int generation;
  
  private int id;


  private double alter = 0;

  private Fuehler fuehler1;
  private Fuehler fuehler2;

  private NeuralNetwork NN;
  private float memory = 1; // GEN


  // sollte bei 1. Generation verwendet werden
  Lebewesen(int x, int y, float fB, int ID) {
    id = ID;
    durchmesser = fB*1.5;
    
    generation = 0;

    NN = new NeuralNetwork(15);

    geschwindigkeit = new PVector(maxGeschwindigkeit, maxGeschwindigkeit);
    geschwindigkeit.limit(maxGeschwindigkeit);

    position = new PVector(x, y);

    fuehler1 = new Fuehler(this);
    fuehler2 = new Fuehler(this);

    fellFarbe = color((int)random(0, 256), (int)random(0, 256), (int)random(0, 256));
  }

  // 2. Konstruktor, damit die Farbe bei den Nachkommen berücksichtigt werden kann und die Gewichte übergeben werden können
  Lebewesen(int x, int y, Matrix c11, Matrix c12,Matrix c21, Matrix c22, color fellfarbe1, color fellfarbe2, int g, float f1, float mG1, float r1, float a1, float f2, float mG2, float r2, float a2, int ID) {
    id = ID;
    durchmesser = map.getFeldbreite()*1.5;

    fressrate = mutieren(mixGenes(f1, f2));
    maxGeschwindigkeit = mutieren(mixGenes(mG1, mG2));
    reproduktionswartezeit = mutieren(mixGenes(r1, r2));
    angriffswert = mutieren(mixGenes(a1, a2));

    generation = g+1;
    energie = geburtsenergie;

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

    NN = new NeuralNetwork(15, c1, c2);

    geschwindigkeit = new PVector(maxGeschwindigkeit, maxGeschwindigkeit);
    geschwindigkeit.limit(maxGeschwindigkeit);

    position = new PVector(x, y);

    fuehler1 = new Fuehler(this);
    fuehler2 = new Fuehler(this);
  }

  public void drawLebewesen() {
    PVector richtung = new PVector(geschwindigkeit.x, geschwindigkeit.y);
    durchmesser = map.stdDurchmesser * energie/2000 + 10 ;
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
    fuehler1.drawFuehler();
    fuehler2.drawFuehler();
    richtung.setMag(durchmesser/2);
    ellipse(position.x, position.y, durchmesser , durchmesser );
    line(position.x,position.y,position.x + richtung.x,position.y + richtung .y);
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


    //// Fuehler 1
    // Richtung Fuehler 
    NN.setInputNFuehlerRichtung1(map(fuehler1.getRichtung(), -180, 180, -6, 6));//                                                                  Hier könnte es Probleme mit map geben
    // Gegnerenergie
    //float[] gegnerEnergie1 = fuehler1.getFuehlerGegnerEnergie();
    NN.setInputNFuehlerGegnerEnergie1(map(fuehler1.getFuehlerGegnerEnergie(), 0, maxEnergie, -6, 6));// maxEnergie muss geändert werden, falls die maximale Energie von Tier zu Tier variieren kann
    // Feldenergie
    //float[] feldEnergie1 = fuehler1.getFuehlerFeldEnergie();
    NN.setInputNFuehlerFeldEnergie1(map(fuehler1.getFuehlerFeldEnergie(), 0, Feld.maxEnergiewertAllgemein, -6, 6));
    // Feldart
    NN.setInputNFuehlerFeldArt1(map(fuehler1.getFuehlerFeldArt(), 0, 1, -6, 6));

    //// Fuehler 2
    // Richtung Fuehler
    NN.setInputNFuehlerRichtung2(map(fuehler2.getRichtung(), -180, 180, -6, 6)); //                                                                  Hier könnte es Probleme mit map geben
    // Gegnerenergie
    //float[] gegnerEnergie2 = fuehler2.getFuehlerGegnerEnergie();
    NN.setInputNFuehlerGegnerEnergie2(map(fuehler2.getFuehlerGegnerEnergie(), 0, maxEnergie, -6, 6)); // maxEnergie muss geändert werden, falls die maximale Energie von Tier zu Tier variieren kann
    // Feldenergie
    //float[] feldEnergie2 = fuehler2.getFuehlerFeldEnergie();
    NN.setInputNFuehlerFeldEnergie2(map(fuehler2.getFuehlerFeldEnergie(), 0, Feld.maxEnergiewertAllgemein, -6, 6));
    // Feldart
    NN.setInputNFuehlerFeldArt2(map(fuehler2.getFuehlerFeldArt(), 0, 1, -6, 6));
  }

  // Bewewgung
  public void bewegen(float v, float angle) { // Rotationswinkel in Grad
    if (energie-verbrauchBewegung*v*0.75>=0 && v<maxGeschwindigkeit && v>=0) { // Bewegungsverbrauch pass sich an momenta n
      energie-=verbrauchBewegung*(v*0.75);
      geschwindigkeit.rotate(radians(angle));
      geschwindigkeit.setMag(v);

      // im Wasser bewegen sich die Lebewesen langsamer und verbrauchen mehr Energie
      if (!map.getFeld((int)position.x, (int)position.y).isLand()) {
        position.add(geschwindigkeit);
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
      PVector opferPosition = new PVector(cos(geschwindigkeit.heading())*durchmesser+position.x, position.y-sin(geschwindigkeit.heading())*durchmesser);

      Lebewesen opfer = map.getTier((int)(opferPosition.x), (int)(opferPosition.y));

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
    energie -= energieverbrauch*(alter/10);
  }
  public void hit() {
    rotzeit = 30;
  }

  // Fitnessfunktion // Fitness wird nur beim Rufen der Methode gerufen
  public float calculateFitnessStandard() { // berechnet die Fitness des Tieres im Bezug auf die Standardwerte
    float alter = sq((float)this.getAlter())*0.5;
    float fressrate = (this.getFressrate() - Welt.stdFressrate)/Welt.stdFressrate;
    float maxV = (this.getMaxGeschwindigkeit() - Welt.stdMaxGeschwindigkeit)/Welt.stdMaxGeschwindigkeit;
    float angriff = (this.getAngriffswert() - Welt.stdAngriffswert)/Welt.stdAngriffswert;
    float wartezeit = Welt.stdReproduktionswartezeit/this.getReproduktionswartezeit() - 1;
    float result = alter + fressrate + maxV + angriff + wartezeit;
    //println(alter + " " + fressrate + " " + maxV + " " + angriff + " " + wartezeit + " " + result);
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

  // Fuehler 1 rotieren
  public void fuehlerRotieren1(float angle) {
    fuehler1.fuehlerRotieren(angle);
  }

  // Fuehler 2 rotieren
  public void fuehlerRotieren2(float angle) {
    fuehler2.fuehlerRotieren(angle);
  }

  // mutiert Gewichte
  public Matrix mutieren(Matrix cArr) {
    for (int x=0; x<cArr.rows; x++) {
      for (int y=0; y<cArr.cols; y++) {
        if (random(0, 1)>0.3) {
          float multiplikator = random(-mutationsrate, mutationsrate);
          cArr.set(x,y,cArr.get(x,y)+multiplikator*cArr.get(x,y));
        }
      }
    }
    return cArr;
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
        if (random(0, 1) > reproduktionsschwellwert) {
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
    if (energie<0) {
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