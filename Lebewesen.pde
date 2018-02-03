
public class Lebewesen {

  public final static int maxRotationswinkelBewegung = 20; /////////////////////////////// Version mit veraenderter Mutation
  public final static int maxRotationswinkelFuehler = 10;

  private PVector geschwindigkeit;
  private PVector position;

  private float mutationsrate = 0.5;
  private float durchmesser = 7; // muss an Welt skaliert werden
  private float fressrate = 20;
  private float maxGeschwindigkeit = 2; //GEN
  private float energie = 300.0;
  private float maxEnergie = 1400.0; 
  private color fellFarbe;
  private float verbrauchBewegung = 7;
  private float verbrauchWasserbewegung = 3;
  private float wasserreibung = 0.1;
  private float energieverbrauch = 3;
  private boolean lebend = true;
  public final static float geburtsenergie = 200;
  private float reproduktionswartezeit = 0.25;
  private float angriffswert = 20;
  public final static float reproduktionswille = 0.4;
  private boolean geburtsbereit = false;
  private float letzteGeburt = 0;
  private float reproduktionsschwellwert = 0.5;
  private boolean rot = false;
  private float rotzeit = 0;
  private float fitness; // wird spaeter eine Rolle bei der Paarung spielen
  private int generation;
  private float praeferenzEnergie;
  private float praeferenzGeneration;


  private double alter = 0;

  private Fuehler fuehler1;
  private Fuehler fuehler2;

  private NeuralNetwork NN;
  private float memory = 1; // GEN


  // sollte bei 1. Generation verwendet werden
  Lebewesen(int x, int y) {
    generation = 0;

    NN = new NeuralNetwork(11);

    geschwindigkeit = new PVector(maxGeschwindigkeit, maxGeschwindigkeit);
    geschwindigkeit.limit(maxGeschwindigkeit);

    position = new PVector(x, y);

    fuehler1 = new Fuehler(this);
    fuehler2 = new Fuehler(this);

    fellFarbe = color((int)random(0, 256), (int)random(0, 256), (int)random(0, 256));
  }

  // 2. Konstruktor, damit die Farbe bei den Nachkommen berücksichtigt werden kann und die Gewichte übergeben werden können
  Lebewesen(int x, int y, Connection[][] c11, Connection[][] c12, Connection[][] c21, Connection[][] c22, color fellfarbe1, color fellfarbe2, int g, float f1, float mG1, float r1, float a1, float f2, float mG2, float r2, float a2) {

    fressrate = mutieren(mixGenes(f1, f2));
    maxGeschwindigkeit = mutieren(mixGenes(mG1, mG2));
    reproduktionswartezeit = mutieren(mixGenes(r1, r2));
    angriffswert = mutieren(mixGenes(a1, a2));

    generation = g+1;
    energie = geburtsenergie;

    // fellfarben wird linear interpoliert
    fellFarbe = lerpColor(fellfarbe1, fellfarbe2, 0.75);

    // Connections
    Connection[][] c1;
    Connection[][] c2;

    c1 = this.mixConnections(c11, c21);
    c2 = this.mixConnections(c12, c22);

    c1 = mutieren(c1);
    c2 = mutieren(c2);

    NN = new NeuralNetwork(11, c1, c2);

    geschwindigkeit = new PVector(maxGeschwindigkeit, maxGeschwindigkeit);
    geschwindigkeit.limit(maxGeschwindigkeit);

    position = new PVector(x, y);

    fuehler1 = new Fuehler(this);
    fuehler2 = new Fuehler(this);
  }

  public void drawLebewesen() {
    if (rotzeit == 0) {
      fill(fellFarbe);
    } else if(rot){
      fill(255, 0, 0);
      rotzeit--;
    } else {
      fill(fellFarbe);
      rotzeit--;
    }
    if(rotzeit %4==0){
      rot = !rot;
    }
    fuehler1.drawFuehler();
    fuehler2.drawFuehler();
    ellipse(position.x, position.y, durchmesser, durchmesser);
  }

  // NeuralNetwork input
  public void input() {
    // Geschwindigkeit
    NN.getInputNGeschwindigkeit().setWert(map(geschwindigkeit.mag(), 0, maxGeschwindigkeit, -1, 1));
    // Fellfarbe
    /*
    NN.getInputNFellRot().setWert(map(red(fellFarbe), 0, 255, -1, 1));
     NN.getInputNFellGruen().setWert(map(green(fellFarbe), 0, 255, -1, 1));
     NN.getInputNFellBlau().setWert(map(blue(fellFarbe), 0, 255, -1, 1));
     */
    // eigene Energie
    NN.getInputNEnergie().setWert(map(energie, 0, maxEnergie, -1, 1));
    // Feldart
    //println("\n\ngetInputNFeldArt");
    //NN.getInputNFeldart().setWert(map(map.getFeld((int)position.x, (int)position.y).isLandInt(), 0, 1, -1, 1));
    // Memory
    NN.getInputNMemory().setWert(map(memory, 0, 1, -1, 1));
    // Bias // immer 1
    NN.getInputNBias().setWert(1);
    // Richtung
    NN.getInputNRichtung().setWert(map(degrees(geschwindigkeit.heading()), -180, 180, -1, 1));


    //// Fuehler 1
    // Richtung Fuehler 
    NN.getInputNFuehlerRichtung1().setWert(map(fuehler1.getRichtung(), -180, 180, -1, 1));//                                                                  Hier könnte es Probleme mit map geben
    // Gegnerenergie
    //float[] gegnerEnergie1 = fuehler1.getFuehlerGegnerEnergie();
    NN.getInputNFuehlerGegnerEnergie1().setWert(map(fuehler1.getFuehlerGegnerEnergie(), 0, maxEnergie, -1, 1));// maxEnergie muss geändert werden, falls die maximale Energie von Tier zu Tier variieren kann
    // Feldenergie
    //float[] feldEnergie1 = fuehler1.getFuehlerFeldEnergie();
    NN.getInputNFuehlerFeldEnergie1().setWert(map(fuehler1.getFuehlerFeldEnergie(), 0, Feld.maxEnergiewertAllgemein, -1, 1));
    // Feldart
    //NN.getInputNFuehlerFeldArt1().setWert(map(fuehler1.getFuehlerFeldArt(), 0, 1, -1, 1));

    //// Fuehler 2
    // Richtung Fuehler
    NN.getInputNFuehlerRichtung2().setWert(map(fuehler2.getRichtung(), -180, 180, -1, 1)); //                                                                  Hier könnte es Probleme mit map geben
    // Gegnerenergie
    //float[] gegnerEnergie2 = fuehler2.getFuehlerGegnerEnergie();
    NN.getInputNFuehlerGegnerEnergie2().setWert(map(fuehler2.getFuehlerGegnerEnergie(), 0, maxEnergie, -1, 1)); // maxEnergie muss geändert werden, falls die maximale Energie von Tier zu Tier variieren kann
    // Feldenergie
    //float[] feldEnergie2 = fuehler2.getFuehlerFeldEnergie();
    NN.getInputNFuehlerFeldEnergie2().setWert(map(fuehler2.getFuehlerFeldEnergie(), 0, Feld.maxEnergiewertAllgemein, -1, 1));
    // Feldart
    //NN.getInputNFuehlerFeldArt2().setWert(map(fuehler2.getFuehlerFeldArt(), 0, 1, -1, 1));
  }

  // Bewewgung
  public void bewegen(float v, float angle) { // Rotationswinkel in Grad
    if (energie-verbrauchBewegung>=0 && v<maxGeschwindigkeit && v>=0) {
      energie-=verbrauchBewegung;
      geschwindigkeit.rotate(radians(angle));
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
      addEnergie(-energieverbrauch);
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
  // Fressen
  public void fressen(float wille) {
    if (wille > 0.5) {
      energie -= energieverbrauch*(alter/2);
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
  public Connection[][] mutieren(Connection[][] cArr) {
    for (int x=0; x<cArr.length; x++) {
      for (Connection c : cArr[x]) {
        if (random(0, 1)>0.3) {
          float multiplizierer = random(-mutationsrate, mutationsrate);
          c.setWeight(c.getWeight()+c.getWeight() * multiplizierer);
        }
      }
    }
    return cArr;
  }
  public float mutieren(float x) {
    float a = x;
    float chance = random(0, 1);
    if (chance>0.5) {
      a += random(-mutationsrate, mutationsrate)*x/4;
    }
    return a;
  }

  public Connection[][] mixConnections(Connection[][] c1, Connection[][] c2) { // nimmt an, dass c1 und c2 gleich gross sind

    // ACHTUNG:
    // BEI DIESER METHODE WERDEN NUR DIE GEWICHTE VERMISCHT, DA DIE CONNECTIONS IM NN KONSTRUKTOR SOWIESO NEU GEMACHT WERDEN
    // DAS HEISST DIE CONNECTIONS REFERENZIEREN IMMER NOCH DIE NEURONEN DER ELTERN (liegt an .clone())
    // ----> NUR FUER ERSTELLEN VON KINDERN VERWENDEN

    Connection[][] mixedConnections = new Connection[c1.length][];

    // mixedConnections wird zu Kopie von c1
    for (int i=0; i<c1.length; i++) {
      mixedConnections[i] = c1[i].clone();
    }
    // Gewichte werden vermischt
    for (int x=0; x<c1.length; x++) {
      for (int y=0; y<c1[0].length; y++) {
        if (random(0, 1) > reproduktionsschwellwert) {
          mixedConnections[x][y].setWeight(c2[x][y].getWeight());
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
}