class Interface extends PApplet {   //<>//

  Button[] buttons;

  Button bFitness;
  Button bAvgAge;
  Button bOldest;
  Button bFlood;

  int bg = 230;

  int leftSpacing = 10;
  int upSpacing = 30;
  int lineSpacing = 5;

  Interface() {
    super();
    PApplet.runSketch(new String[] {"LiveData"}, this);
    
    this.getSurface().setTitle("Live Data");
  }

  void settings() {
    size(400, 350);
  }

  void setup() {

    plot = new GPlot(this, plotX, plotY, plotWidth, plotHeight);
    plot.setMar(margin);
    plot.setOuterDim(plotWidth, plotHeight);
    plot.setBgColor(bg);

    //Buttons Interface: x:200, y: 250
    bFitness = new Button(0, plotHeight, 100, 50, "Ø Fitness", ButtonType.FITNESS);
    bFitness.selected = true;

    bAvgAge = new Button(0, plotHeight + 50, 100, 50, "Ø Alter", ButtonType.AVGAGE);
    bOldest = new Button(100, plotHeight, 100, 50, "Ältestes Alter", ButtonType.OLDEST);
    bFlood = new Button(width-100, height-50, 100, 50, "FLUT", ButtonType.FLOOD);

    buttons = new Button[] {bFitness, bAvgAge, bOldest, bFlood}; // order must not be changed
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
    try {
      plot.drawLines();
    } catch (IndexOutOfBoundsException e) {
      // ka wieso die Exception auftritt, alles funktioniert weiterhin gut
    } catch (NullPointerException e){
      // ka wieso die Exception auftritt, alles funktioniert weiterhin gut
    } catch(Exception e){
      e.printStackTrace();
    }
    plot.endDraw();
  }

  public void showInterface() {
    float year = floor((float)map.year*100);
    fill(0);
    textSize(17);
    textAlign(LEFT);
    text("Jahre: " + year/100, plotWidth + leftSpacing, upSpacing);
    text("Bewohner: " + map.population.size(), plotWidth + leftSpacing, upSpacing + 17 + lineSpacing);

    bFitness.show();
    bAvgAge.show();
    bOldest.show();
    bFlood.show();
  }

  void mousePressed() {
    if (bFitness.isPressed()) {
      buttons[selectedButton.ordinal()].selected = false;
      bFitness.selected = true;
      selectedButton = bFitness.type;
    } else if (bAvgAge.isPressed()) {
      buttons[selectedButton.ordinal()].selected = false;
      bAvgAge.selected = true;
      selectedButton = bAvgAge.type;
    } else if (bOldest.isPressed()) {
      buttons[selectedButton.ordinal()].selected = false;
      bOldest.selected = true;
      selectedButton = bOldest.type;
    } else if (bFlood.isPressed()) {
      map.flood();
    }
    switch(selectedButton) {
    case FITNESS:
      plot.setPoints(map.fitnessGPoints);
      break;
    case OLDEST:
      plot.setPoints(map.oldestGPoints);
      break;
    case AVGAGE:
      plot.setPoints(map.averageAgeGPoints);
      break;
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
      if (selected) {
        rectC = color(255);
        textC = color(0);
      } else {
        rectC = color(0);
        textC = color(255);
      }
      if (this.isPressed()) {
        rectC = color(210);
        textC = color(0);
      }

      fill(rectC);
      rect(posX, posY, bWidth, bHeight, 10);

      fill(textC);
      textAlign(CENTER);
      textSize(14);
      text(name, posX+bWidth/2, (posY+bHeight/2));
      noStroke();
    }

    boolean isPressed() {
      return (mouseX>posX && mouseX<posX + bWidth && mouseY > posY && mouseY < posY + bHeight && mousePressed);
    }
  }
}