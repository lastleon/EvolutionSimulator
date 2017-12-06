class Feld{
  
  // getter müssen noch geschrieben werden
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
  void drawFeld(){
    if(nHoehe>45){
      fill((100 - energiewert)*1.5,energiewert*1.5+50,0); //muss noch geändert werden
    } else fill(0, 0, 255);
    rect(posX, posY, feldBreite, feldBreite);
  }
  
}