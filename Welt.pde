public class Welt{
  
  // getter fehlen noch
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
  }
  
  // zeichnet die Welt
  public void showWelt(){
    for(int x=0; x<weltGroesse; x++){
      for(Feld a : welt[x]){
          a.drawFeld();
      }
    }
  }
  
  // zeichnet ein Array aus Lebewesen (meistens am Anfang genutzt)
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
  
  public Feld getFeld(int x, int y){
    return welt[(x-(x % fB)) / fB][(y-(y % fB)) / fB];
    
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
  
}