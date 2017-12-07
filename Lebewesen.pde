
public class Lebewesen{
  
  private int durchmesser = 15;
  private int posX, posY;
  private int fressrate;
  
  public Lebewesen(){
    posX = (int)random(0,fensterGroesse);
    posY = (int)random(0,fensterGroesse); 
  }
  
  public void drawLebewesen(){
    fill((int)random(0,256), (int)random(0,256), (int)random(0,256));
    ellipse(posX, posY, durchmesser, durchmesser);
  }
}