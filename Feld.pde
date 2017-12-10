class Feld{
  
  private float posX, posY;
  private float nHoehe; //noise-Hoehe
  private float regenerationsrate;
  private float energiewert;
  private float maxEnergiewert;
  private int feldBreite;
  
  private int meeresspiegel = 45;

  Feld(int x , int y, float h, int fB){
    posX = x;
    posY = y;
    nHoehe = h;
    feldBreite = fB;
    
    if(this.isLand()){
      regenerationsrate = 0.4;
      energiewert = 80;
      maxEnergiewert = 80;
    } else {
      regenerationsrate = 0;
      energiewert = 0;
      maxEnergiewert = 0;
    }
  }
  
  public void regenerieren(){
    energiewert += regenerationsrate;
    if (energiewert > maxEnergiewert){
      energiewert = maxEnergiewert;
    }
  }
  
  public boolean isLand(){
    if (nHoehe>meeresspiegel){
      return true;
    } else return false;
  }
  
  public void drawFeld(){
    if(nHoehe>meeresspiegel){
      fill(map(energiewert, 0, maxEnergiewert, 255, 80), map(energiewert, 0, maxEnergiewert, 210, 140), 20); //muss noch geändert werden
    } else fill(0, 0, map(nHoehe, 0, 45, 0, 140));
    rect(posX, posY, feldBreite, feldBreite);
  }
  
  // getter(bisher)
  public float getEnergie(){
    return energiewert;
  }
  
  public void setEnergie(int x){
    energiewert = x;
  }
}