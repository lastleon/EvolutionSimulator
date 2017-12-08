class Feld{
  
  private int posX, posY;
  private float nHoehe; //noise-Hoehe
  
  private int feldBreite;
  private int regenerationsrate  = 3;
  private int energiewert = 80;
  private int maxEnergiewert = 80;

  Feld(int x , int y, float h, int fB){
    posX = x;
    posY = y;
    nHoehe = h;
    feldBreite = fB;
  }
  
  public boolean isLand(){
    if (nHoehe>45){
      return true;
    } else return false;
  }
  
  public void drawFeld(){
    if(nHoehe>45){
      fill(map(energiewert, 0, maxEnergiewert, 255, 80), map(energiewert, 0, maxEnergiewert, 210, 140), 20); //muss noch geändert werden
    } else fill(0, 0, map(nHoehe, 0, 45, 0, 140));
    rect(posX, posY, feldBreite, feldBreite);
  }
  
  // getter(bisher)
  public int getEnergie(){
    return energiewert;
  }
  
  public void setEnergie(int x){
    energiewert = x;
  }
}