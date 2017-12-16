public class Welt{
  
  private Feld[][] welt;
  private ArrayList<Lebewesen> bewohner;
  private int lwZahl;
  private float weltX;
  private float weltY;
  private float jahr;
  private float spacing;
  private int fB;
  private float zeitProFrame = 0.0005;
  
  public Welt(int weltG, int lw){
    
    jahr = 0;
    lwZahl = lw;
    
    weltGroesse = weltG;
    
    // skaliert die Feldbreite and die Fenstergroesse und die Feldanzahl pro Reihe
    fB = (int)(fensterGroesse/weltGroesse);
    
    // generiert Welt
    welt = new Feld[weltGroesse][weltGroesse];
    float yNoise = 0.0;
    for (int y=0; y<weltGroesse; y++){
      float xNoise = 0.0;
      for(int x=0; x<weltGroesse; x++){
        welt[x][y] = new Feld(x*fB, y*fB, noise(xNoise, yNoise)*100, fB);
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
      
      bewohner.add(new Lebewesen(posX,posY));
      
    }
  }
  
  // entfernt Tote
  public void todUndGeburt(){
    ArrayList<Lebewesen> bewohnerCopy = new ArrayList<Lebewesen>(bewohner);
    for(Lebewesen lw : bewohnerCopy){
      if(!lw.getStatus()){
        bewohner.remove(bewohner.indexOf(lw));
      }
      lw.gebaeren(lw.NN.getGeburtwille());
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
        
        bewohner.add(new Lebewesen(posX,posY));
      }
    }
    
    
    for(Lebewesen lw : bewohner){
      lw.input();
      lw.leben();
      lw.altern();
      lw.bewegen(lw.NN.getGeschwindigkeit(lw), degrees(lw.NN.getRotation()));
      lw.fressen(lw.NN.getFresswille());
      lw.erinnern(lw.NN.getMemory());
      lw.fellfarbeAendern(lw.NN.getFellRot(), lw.NN.getFellGruen(), lw.NN.getFellBlau());
      lw.fuehlerRotieren1(lw.NN.getRotationFuehler1());
      lw.fuehlerRotieren2(lw.NN.getRotationFuehler2());
      lw.angriff(lw.NN.getAngriffswille());
    }
    
    todUndGeburt();
    
    felderRegenerieren();
    
    jahr += zeitProFrame;
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
    strokeWeight(0.1);
    for(Lebewesen lw : bewohner){
      lw.drawLebewesen();
    }
    noStroke();
  }
  // zeichnet ein Array aus Lebewesen (meistens am Anfang genutzt) // ka ob mans noch braucht, ich lass es einfach mal drinnen
  public void showLebewesen(Lebewesen[] lwArray){
    stroke(1);
    strokeWeight(0.1);
    for(Lebewesen lw : lwArray){
      lw.drawLebewesen();
    }
    noStroke();
  }
  
  // zeichnet ein einziges Lebewesen (eig. unnötig, aber um die Form zu wahren sollte man diese Methode nutzen)
  public void showLebewesen(Lebewesen lw){
    stroke(1);
    strokeWeight(0.1);
    lw.drawLebewesen();
    noStroke();
  }
  
  public void felderRegenerieren(){
    for(int x=0; x<weltGroesse; x++){
      for(Feld f : welt[x]){
        f.regenerieren();
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
  
  public Feld[][] getWelt(){
    return welt;
  }
  
  public Lebewesen getTier(int x,int y){
    for(Lebewesen lw : bewohner){
      if(sqrt(sq(lw.position.x- x) + sq(lw.position.y- y)) < lw.durchmesser/2){
        return lw;
      }
    }
    return null; 
  }
  
  public float getJahr(){
    return jahr;
  }
  public float getZeitProFrame(){
    return zeitProFrame;
  }
}