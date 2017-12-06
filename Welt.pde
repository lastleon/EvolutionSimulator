public class Welt{
  
  // getter fehlen noch
  private Feld[][] welt;
  private ArrayList<Lebewesen> bewohner;
  
  private int weltGroesse;
  private int fB;
  
  public Welt(int weltGroesse, int lw){
    
    this.weltGroesse = weltGroesse;
    
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
      bewohner.add(new Lebewesen((int)random(0,fensterGroesse),(int)random(0,fensterGroesse)));
    }
    
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
  
}