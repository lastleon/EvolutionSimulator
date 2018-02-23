class Button {
  float X;
  float Y;
  float W;
  float H;
  float posX;
  float posY;
  float bWidth;
  float bHeight;
  String name;

  Button(float x, float y, float w, float h, String n) {   
    X = x;
    Y = y;
    W= w;
    H = h;
    name = n;
  }

  void show() {

    posX = map.weltX + X/skalierungsfaktor;
    posY = map.weltY + Y/skalierungsfaktor;

    bWidth = (W)/skalierungsfaktor;
    bHeight = (H)/skalierungsfaktor;

    stroke(0);
    fill(0, 100);
    rect(posX, posY, bWidth, bHeight);
    fill(255);
    textSize(10/skalierungsfaktor);
    text(name, posX, posY+bHeight/2);
    noStroke();
  }

  boolean isPressed() {

    posX = map.weltX + X/skalierungsfaktor;
    posY = map.weltY + Y/skalierungsfaktor;

    float rMouseX = (mouseX-(xOffsetGesamt))/skalierungsfaktor;
    float rMouseY = (mouseY-(yOffsetGesamt))/skalierungsfaktor;

    bWidth = (W)/skalierungsfaktor;
    bHeight = (H)/skalierungsfaktor;

    if (rMouseX>posX && rMouseX<posX+bWidth && rMouseY > posY && rMouseY < posY+bHeight) {
      return true;
    } else return false;
  }
}