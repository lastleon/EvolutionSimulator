class Interface extends PApplet {   //<>//
  
  Button[] buttons;
  
  Button bFitness;
  Button bAltersschnitt;
  Button bAeltestes;
  
  int bg = 230;
  
  int leftSpacing = 10;
  int upSpacing = 30;
  int lineSpacing = 5;
  
  Interface(){
    super();
    PApplet.runSketch(new String[] {"LiveData"}, this);
  }
  
  void settings() {
    size(400, 350);
  }
  
  void setup(){
    
    plot = new GPlot(this, plotX, plotY, plotWidth, plotHeight);
    plot.setMar(margin);
    plot.setOuterDim(plotWidth, plotHeight);
    plot.setBgColor(bg);
    
    //Buttons Interface: x:200, y: 250
    bFitness = new Button(0, plotHeight, 100, 50, "Ø Fitness", ButtonType.FITNESS);
    bFitness.selected = true;
    
    bAltersschnitt = new Button(0, plotHeight + 50, 100, 50, "Ø Alter", ButtonType.ALTERSSCHNITT);
    bAeltestes = new Button(100, plotHeight, 100, 50, "Ältestes Alter", ButtonType.AELTESTES);
    
    buttons = new Button[] {bFitness, bAltersschnitt, bAeltestes}; // order must not be changed
  }

  void draw() {
    background(bg);
    drawPlot();
    showInterface();
    stroke(0);
    line(plotWidth, 0, plotWidth, plotHeight);
    line(0, plotHeight, width, plotHeight);
  }

  void drawPlot() {
    plot.beginDraw();
    plot.drawBackground();
    plot.drawXAxis();
    plot.drawYAxis();
    plot.drawTitle();
    //plot.drawLines();
    plot.endDraw();
  }
  
  public void showInterface() {
    
    float jahr = floor((float)map.jahr*100);
    
    fill(0);
    textSize(17);
    textAlign(LEFT);
    text("Jahre: " + jahr/100, plotWidth + leftSpacing, upSpacing);
    text("Bewohner: " + map.bewohner.size(), plotWidth + leftSpacing, upSpacing + 17 + lineSpacing);
    
    bFitness.show();
    bAltersschnitt.show();
    bAeltestes.show();
  }
  
  void mousePressed(){
    if(bFitness.isPressed()){
      bFitness.selected = true;
      buttons[selectedButton.ordinal()].selected = false;
      selectedButton = bFitness.type;
    } else if(bAltersschnitt.isPressed()){
      bAltersschnitt.selected = true;
      buttons[selectedButton.ordinal()].selected = false;
      selectedButton = bAltersschnitt.type;
    } else if(bAeltestes.isPressed()){
      bAeltestes.selected = true;
      buttons[selectedButton.ordinal()].selected = false;
      selectedButton = bAeltestes.type;
    }
  }
  
  class Button {
    
    float posX;
    float posY;
    float bWidth;
    float bHeight;
    String name;
    ButtonType type;
    
    boolean selected = false;
    
    color rectC;
    color textC;
  
    Button(float x, float y, float w, float h, String n, ButtonType t) {   
      posX = x;
      posY = y;
      bWidth = w;
      bHeight = h;
      name = n;
      type = t;
    }
  
    void show() {
      stroke(0);
      if(selected){
        rectC = color(255);
        textC = color(0);
      } else {
        rectC = color(0);
        textC = color(255);
      }
      
      fill(rectC);
      rect(posX, posY, bWidth, bHeight, 10);
      
      fill(textC);
      textAlign(CENTER);
      textSize(14);
      text(name, posX+bWidth/2, posY+bHeight/2);
      noStroke();
    }
  
    boolean isPressed() {
      return (mouseX>posX && mouseX<posX + bWidth && mouseY > posY && mouseY < posY + bHeight);
    }
  }  
}