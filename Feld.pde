class Feld{
  
  private int posX, posY;
  private float nHoehe; //noise-Hoehe
  
  private int feldBreite;
  private int regenerationsrate  = 3;
  private int energiewert = 80;

  Feld(int x , int y, float h, int fB){
    posX = x;
    posY = y;
    nHoehe = h;
    feldBreite = fB;

  }
  // getter(bisher)
  boolean istLand(){
    if (nHoehe>45){
      return true;
    }else return false;
  }
  int getEnergie(){
    return energiewert;
  }
  void setEnergie(int x){
    energiewert = x;
  }
  void drawFeld(){
    if(nHoehe>45){
      fill((100 - energiewert)*1.5,energiewert*1.5+50,0); //muss noch geändert werden
    } else fill(0, 0, 255);
    rect(posX, posY, feldBreite, feldBreite);
  }
}
Feld getFeld(int x,int y){
  Feld returnFeld =new Feld(0,0,0,0);
  for(int i =0;i < weltGroesse;i++){
    for (Feld a: welt.welt[i]){
      if(a.posX == x && a.posY == y){
        returnFeld = a;
      }
    }  
  }
  return returnFeld;
  
}