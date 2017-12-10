public class Welt{
  
  private Feld[][] welt;
  private ArrayList<Lebewesen> bewohner;
  
  private int fB;
  
  public Welt(int weltG, int lw){
    
    weltGroesse = weltG;
    
    // skaliert die Feldbreite and die Fenstergroesse und die Feldanzahl pro Reihe
    fB = (int)fensterGroesse/weltGroesse;
    
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
        posX = (int)random(0,fensterGroesse);
        posY = (int)random(0,fensterGroesse);
      } while (!this.getFeld(posX,posY).isLand());
      
      bewohner.add(new Lebewesen(posX,posY));
    }
    
  }
  
  // update Methode wird immer in draw (Mainloop) gerufen
  public void update(){
    translate(xOffsetGesamt+xOffset, yOffsetGesamt+yOffset);
    scale(skalierungsfaktor);
    background(0,128,255);
    for(Lebewesen lw : bewohner){
      lw.bewegen(4,/**random(0,361)**/30); // Ort dieser Methoden wird noch umgelagert && input kommt von NN
      lw.fressen(); // Fressen ist noch ein bisschen fehlerhaft
    }
    for(int x=0; x<weltGroesse; x++){
      for(Feld f : welt[x]){
        f.regenerieren();
      }
    }
    showWelt();
    showLebewesen();
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
    for(Lebewesen lw : bewohner){
      lw.drawLebewesen();
    }
  }
  // zeichnet ein Array aus Lebewesen (meistens am Anfang genutzt) // ka ob mans noch braucht, ich lass es einfach mal drinnen
  public void showLebewesen(Lebewesen[] lwArray){
    for(Lebewesen lw : lwArray){
      lw.drawLebewesen();
    }
  }
  
  // zeichnet ein einziges Lebewesen (eig. unnötig, aber um die Form zu wahren sollte man diese Methode nutzen)
  public void showLebewesen(Lebewesen lw){
    lw.drawLebewesen();
  }
  
  //// Getter
  public Lebewesen[] getLebewesen(){
    return bewohner.toArray(new Lebewesen[bewohner.size()]);
  }
  
  public int getWeltGroesse(){
    return weltGroesse;
  }
  
  public Feld getFeld(int x, int y){ // funktioniert nur bei schönen Zahle, muss noch besser werden (1000, 100, etc)
    float xFeld = (x - (x%fB)) / fB;
    float yFeld = (y - (y%fB)) / fB;
    if (xFeld == weltGroesse){
      xFeld = 0;
    }
    if (yFeld == weltGroesse){
      yFeld = 0;
    }
    return welt[(int)xFeld][(int)yFeld];  // so müssen nicht jedes mal alle Felder durchlaufen werden && bin mir nicht sicher, ob es überhaupt funktioniert hätte, weil ja nur die Linke obere Ecke (x&y) überprüft wird
    
  /**Feld returnFeld = new Feld(0,0,0,0);
    for(int i=0; i<weltGroesse; i++){
      for (Feld a: welt.welt[i]){
        if(a.posX == x && a.posY == y){
          returnFeld = a;
        }
      }  
    }
    return returnFeld;**/ 
   
  }
  
  public Feld[][] getWelt(){
    return welt;
  }
  
}