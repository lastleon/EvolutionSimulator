
public class Lebewesen{
  
  private PVector geschwindigkeit;
  private PVector position;
  
  private float durchmesser = 15; // muss an Welt skaliert werden
  private float fressrate;
  private float maxGeschwindigkeit = 12; // muss noch gefixt werden, hat anscheinend keinen Effekt auf die Geschwindigkeit, bin aber zu müde
  private color fellFarbe;
  
  // sollte bei 1. Generation verwendet werden
  Lebewesen(int x, int y){
    fellFarbe = color((int)random(0,256), (int)random(0,256), (int)random(0,256));
    
    geschwindigkeit = new PVector(maxGeschwindigkeit,maxGeschwindigkeit);
    geschwindigkeit.limit(maxGeschwindigkeit);
    
    position = new PVector(x,y);
  }
  
  // 2. Konstruktor, damit die Farbe bei den Nachkommen berücksichtigt werden kann
  Lebewesen(int x, int y, color c){
    fellFarbe = c;
    
    geschwindigkeit = new PVector(maxGeschwindigkeit,maxGeschwindigkeit);
    geschwindigkeit.limit(maxGeschwindigkeit);
    
    position = new PVector(x,y);
  }
  
  public void drawLebewesen(){
    fill(fellFarbe);
    ellipse(position.x, position.y, durchmesser, durchmesser);
  }
  
  // Bewewgung
  public void bewegen(float v, float angle){ // muss noch heftig bearbeitet werden // angle beschreibt den Winkel, in den das Lebewesen will (nicht die Änderung!)
    geschwindigkeit.rotate(radians(angle-degrees(geschwindigkeit.heading())));
    geschwindigkeit.setMag(v);
    position.add(geschwindigkeit);
  }
  
  // getter 
  // Intervall von [-PI;PI[
  public float getWinkelRad(){
    return geschwindigkeit.heading();
  }
  // 360 Grad
  public float getWinkelDeg(){
    return degrees(geschwindigkeit.heading());
  }
}