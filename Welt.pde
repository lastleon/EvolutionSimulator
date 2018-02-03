public class Welt{
  
  private Feld[][] welt;
  private ArrayList<Lebewesen> bewohner;
  private int lwZahl;
  private float weltX;
  private float weltY;
  private double jahr;
  private float spacing;
  private float fB;
  private double zeitProFrame = 0.0005;
  private int multiplikator = 10000;
  
  // Tiere: Standard Werte
  final public static float stdFressrate = 20;
  final public static float stdMaxGeschwindigkeit = 2;
  final public static float stdAngriffswert = 20;
  final public static float stdReproduktionswartezeit = 0.25;
  
  public Welt(int weltG, int lw){
    
    jahr = 0;
    lwZahl = lw;
    
    weltGroesse = weltG;
    
    // skaliert die Feldbreite and die Fenstergroesse und die Feldanzahl pro Reihe
    fB = fensterGroesse/weltGroesse;
    
    // generiert Welt
    welt = new Feld[weltGroesse][weltGroesse];
    float yNoise = 0.0;
    for (int y=0; y<weltGroesse; y++){
      float xNoise = 0.0;
      for(int x=0; x<weltGroesse; x++){
        welt[x][y] = new Feld(x*fB, y*fB, noise(xNoise, yNoise)*100, fB, x, y);
        xNoise += 0.038;
      }
      yNoise += 0.038;
    }
    // generiert Anfangs-Lebewesen
    bewohner = new ArrayList<Lebewesen>(lw);
    for(int i=0; i<lw; i++){
      int posX;
      int posY;
      do {
        //println("\n\ngeneriere Lebewesen");
        posX = (int)random(0,fensterGroesse);
        posY = (int)random(0,fensterGroesse);
      } while (!this.getFeld(posX,posY).isLand());
      
      bewohner.add(new Lebewesen(posX,posY, fB));
      
    }
  }
  
  // entfernt Tote
  public void todUndGeburt(){
    ArrayList<Lebewesen> bewohnerCopy = new ArrayList<Lebewesen>(bewohner);
    for(Lebewesen lw : bewohnerCopy){
      if(!lw.getStatus()){
        bewohner.remove(bewohner.indexOf(lw));
      }
    }
    
    bewohnerCopy = new ArrayList<Lebewesen>(bewohner);
    
    for(Lebewesen lw1 : bewohnerCopy){
      for(Lebewesen lw2 : bewohnerCopy){
        if(!lw1.equals(lw2) && lw1.collision(lw2)){
          this.gebaeren(lw1, lw2);
        }
      }
    }
  }
  
  public float entfernungLebewesen(Lebewesen lw1, Lebewesen lw2){
    //return sqrt(abs(lw1.getPosition().x - lw2.getPosition().x) + abs(lw1.getPosition().y - lw2.getPosition().y));
    return lw1.getPosition().dist(lw2.getPosition());
  }
  
  public void gebaeren(Lebewesen lw1, Lebewesen lw2){
    if((lw1.NN.getGeburtwille()*lw1.calculateFitnessStandard() > Lebewesen.reproduktionswille && lw2.NN.getGeburtwille()*lw2.calculateFitnessStandard() > Lebewesen.reproduktionswille) //Beide LW muessen zustimmen // EXPERIMENTELL: geburtswille * fitness
      &&
      (lw1.getEnergie() >= Lebewesen.geburtsenergie && lw2.getEnergie() >= Lebewesen.geburtsenergie) // Beide LW muessen genug Energie haben
      &&
      (lw1.isGeburtsbereit() && lw2.isGeburtsbereit())) // Beide LW muessen geburtsbereit sein
      {
      // benötigte Geburtsenergie wird abgezogen
      lw1.addEnergie(-Lebewesen.geburtsenergie);
      lw2.addEnergie(-Lebewesen.geburtsenergie);
      
      // Dummy-Vectoren
      PVector posLw1 = new PVector(lw1.getPosition().x, lw1.getPosition().y);
      PVector posLw2 = new PVector(lw2.getPosition().x, lw2.getPosition().y);
      
      // Neues Lebewesen mit gemischten Connections entsteht
      this.addLebewesen(
      new Lebewesen((int)(posLw1.x + cos(PVector.angleBetween(posLw1,
                    posLw2))*(lw1.getDurchmesser()/2)),
                    (int)(posLw1.y + sin(PVector.angleBetween(posLw1, posLw2))*(lw1.getDurchmesser()/2)),
                    lw1.NN.getConnections1(),
                    lw1.NN.getConnections2(),
                    lw2.NN.getConnections1(),
                    lw2.NN.getConnections2(),
                    lw1.getFellfarbe(),
                    lw2.getFellfarbe(),
                    max(lw1.getGeneration(), lw2.getGeneration()),
                    lw1.getFressrate(),
                    lw1.getMaxGeschwindigkeit(),
                    lw1.getReproduktionswartezeit(),
                    lw1.getAngriffswert(),
                    
                    lw2.getFressrate(),
                    lw2.getMaxGeschwindigkeit(),
                    lw2.getReproduktionswartezeit(),
                    lw2.getAngriffswert()
                    ));
      println("Ein neues Früchtchen ist entsprungen!");
      lw1.setLetzteGeburt((float)lw1.getAlter());
      lw2.setLetzteGeburt((float)lw2.getAlter());
    }
  }
  
  // update Methode wird immer in draw (Mainloop) gerufen
  public void update(){
    translate(xOffsetGesamt+xOffset, yOffsetGesamt+yOffset);
    scale(skalierungsfaktor);
    background(0,128,255);
    weltX = (0-xOffsetGesamt-xOffset)/skalierungsfaktor;
    weltY = (0-yOffsetGesamt-yOffset)/skalierungsfaktor;
    spacing = 20/skalierungsfaktor;
    int bewohnerZahl = bewohner.size();
    if(bewohnerZahl < lwZahl){
      for(int i=0; i<lwZahl-bewohnerZahl; i++){
        int posX;
        int posY;
        do {
          //println("\n\nfehlende Lebewesen werden hizugefügt");
          posX = (int)random(0,fensterGroesse);
          posY = (int)random(0,fensterGroesse);
        } while (!this.getFeld(posX,posY).isLand());
        
        bewohner.add(new Lebewesen(posX, posY, fB));
      }
    }
    
    
    for(Lebewesen lw : bewohner){
      lw.input();
      lw.leben();
      lw.altern();
      lw.bewegen(lw.NN.getGeschwindigkeit(lw), lw.NN.getRotation());
      lw.fressen(lw.NN.getFresswille());
      lw.erinnern(lw.NN.getMemory());
      //lw.fellfarbeAendern(lw.NN.getFellRot(), lw.NN.getFellGruen(), lw.NN.getFellBlau());
      lw.fuehlerRotieren1(lw.NN.getRotationFuehler1());
      lw.fuehlerRotieren2(lw.NN.getRotationFuehler2());
      lw.angriff(lw.NN.getAngriffswille()); // hilft, Bevoelkerung nicht zu gross zu halten
    }
    
    todUndGeburt();
    
    felderBewachsen();
    
    jahr += zeitProFrame;
    float neuesJahr = (float)(jahr * multiplikator);
    jahr = (double)floor(neuesJahr) / multiplikator;
    if(jahr%1 == 0){
      double aeltestesLw = 0;
      for(Lebewesen lw : bewohner){
        if(lw.getAlter() > aeltestesLw) aeltestesLw = lw.getAlter();
      }
      println("Momentan ältestes Lebewsen: " + aeltestesLw);
    }
    
    showWelt();
    showLebewesen();
    showInterface();
  }
  // Lebewesen hinzufügen
  public void addLebewesen(Lebewesen lw){
    bewohner.add(lw);
  }
  
  // Interface
  public void showInterface(){
    String jahre = "Jahre: " + jahr;
    fill(50, 200);
    rect(weltX,weltY, 200/skalierungsfaktor, 250/skalierungsfaktor);
    
    fill(255);
    textSize(17/skalierungsfaktor);
    textAlign(LEFT);
    text(jahre, weltX + spacing, weltY + spacing);
    
    text("Bewohner: " + bewohner.size(), weltX + spacing*2, weltY + spacing*2);
  }
  
  // zeichnet die Welt
  public void showWelt(){
    for(int x=0; x<weltGroesse; x++){
      for(Feld a : welt[x]){
          a.drawFeld();
      }
    }
  }
  public void showLebewesen(){
    stroke(1);
    strokeWeight(0.2);
    for(Lebewesen lw : bewohner){
      lw.drawLebewesen();
    }
    noStroke();
  }
  // zeichnet ein Array aus Lebewesen (meistens am Anfang genutzt) // ka ob mans noch braucht, ich lass es einfach mal drinnen
  public void showLebewesen(Lebewesen[] lwArray){
    stroke(1);
    strokeWeight(0.2);
    for(Lebewesen lw : lwArray){
      lw.drawLebewesen();
    }
    noStroke();
  }
  
  // zeichnet ein einziges Lebewesen (eig. unnötig, aber um die Form zu wahren sollte man diese Methode nutzen)
  public void showLebewesen(Lebewesen lw){
    stroke(1);
    strokeWeight(0.2);
    lw.drawLebewesen();
    noStroke();
  }
  
  public void felderBewachsen(){
    for(int x=0; x<weltGroesse; x++){
      for(Feld f : welt[x]){
        f.wachsen();
      }
    }
  }
  
  //// Getter
  public Lebewesen[] getLebewesen(){
    return bewohner.toArray(new Lebewesen[bewohner.size()]);
  }
  
  public int getWeltGroesse(){
    return weltGroesse;
  }
  
  public Feld getFeld(int x, int y){ // funktioniert nur bei schönen Zahle, muss noch besser werden (1000, 100, etc)
    float xFeld = (x - (x % fB)) / fB;
    float yFeld = (y - (y % fB)) / fB;
    if (xFeld >= weltGroesse){
      xFeld = 0;
    }
    if (yFeld >= weltGroesse){
      yFeld = 0;
    }
    //println("x: " + x + " xFeld: " + xFeld + "         y: " + y + " yFeld: " + yFeld);
    return welt[(int)xFeld][(int)yFeld];
   
  }
  
  public Feld getFeldInArray(int x, int y){
    try{
      if(x != -1 && x != weltGroesse && y != -1 && y != weltGroesse){ // um die ArrayIndexOutOfBoundsException zu umgehen, die normalerweise auftreten würde // try-catch Block ist trotzdem zur sicherheit da
        return welt[x][y];
      } else return null;
    } catch(Exception e){
      e.printStackTrace();
      return null;
    }
  }
  
  public Lebewesen getTier(int x,int y){
    for(Lebewesen lw : bewohner){
      if(sqrt(sq(lw.position.x- x) + sq(lw.position.y- y)) < lw.durchmesser/2){
        return lw;
      }
    }
    return null; 
  }
  
  public double getJahr(){
    return jahr;
  }
  public double getZeitProFrame(){
    return zeitProFrame;
  }
  public int getZeitMultiplikator(){
    return multiplikator;
  }
  public float getFeldbreite(){
    return fB;
  }
}