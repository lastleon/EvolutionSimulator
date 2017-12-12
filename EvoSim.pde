
// fenstergroesse muss seperat geändert werden, sollte immer gleich sein & einen schönen Wert haben, z.B. 100, 500,...
final int fensterGroesse = 1000;
private int weltGroesse;
private float xNeu, yNeu, skalierungsfaktor;
private float xOffset = 0.0;
private float yOffset = 0.0;
private float xOffsetGesamt = 0.0;
private float yOffsetGesamt = 0.0;
private float xPressed, yPressed;
private boolean locked = false;

Welt map = new Welt(100, 50);

void setup(){
  size(1000,1000);
  stroke(1);
  skalierungsfaktor = 1;
  xNeu = 0;
  yNeu = 0;
  map.showWelt();
  map.showLebewesen(map.getLebewesen());
  frameRate(50);
}

void draw(){
  map.update();
}

// Eventhandler
void mouseWheel(MouseEvent event){
  float e = event.getCount();
  
  skalierungsfaktor -= e / 10;
  xNeu = e * ((mouseX - xOffset) * skalierungsfaktor) / 100;
  yNeu = e * ((mouseY - yOffset) * skalierungsfaktor) / 100;
  
}
void mouseDragged(){
  if (locked){
    xOffset = (mouseX - xPressed) * skalierungsfaktor;
    yOffset = (mouseY - yPressed) * skalierungsfaktor;
    xOffsetGesamt += xOffset;
    yOffsetGesamt += yOffset;
    xPressed = mouseX;
    yPressed = mouseY;
    cursor(MOVE);
  }
}
void mousePressed(){
  locked = true;
  xPressed = mouseX;
  yPressed = mouseY;
}
void mouseReleased(){
  locked = false;
  cursor(ARROW);
}