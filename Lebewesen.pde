
public class Lebewesen{
  
  private int durchmesser = 15;
  private int posX, posY;
  private int fressrate;
  private int[] velocity;
  
  Lebewesen(int x, int y){
    posX = x;
    posY = y;
  }
  
  public void drawLebewesen(){
    fill((int)random(0,256), (int)random(0,256), (int)random(0,256));
    ellipse(posX, posY, durchmesser, durchmesser);
  }
}