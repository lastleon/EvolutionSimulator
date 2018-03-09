class Interface extends PApplet {   //<>//
  
  // Grafika Library für Plot benutzt
  // in Video erklärt
  
  Button[] buttons;

  Button bFitness;
  Button bAvgAge;
  Button bOldest;
  Button bFlood;
  Button bGeneration;
  
  Label floodOngoing;

  int bg = 230;

  int leftSpacing = 10;
  int upSpacing = 30;
  int lineSpacing = 5;

  Interface() {
    // zweites Fenster gerufen
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
    bGeneration = new Button(100, plotHeight+50, 100, 50, "Generation", ButtonType.GENERATION);

    buttons = new Button[] {bFitness, bAvgAge, bOldest, bFlood, bGeneration}; // order must not be changed
    
    floodOngoing = new Label(plotWidth+leftSpacing, plotHeight-75, 130, 65, "FLUT", color(255, 46, 46), color(255));
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
    // Exceptions treten ohne ersichtlichen Grund auf, Plot funktioniert weiterhin gut
    // Liegt an Grafika
    try{
      plot.beginDraw();
      plot.drawBackground();
      plot.drawXAxis();
      plot.drawYAxis();
      plot.drawTitle();
      plot.drawLines();
    } catch (IndexOutOfBoundsException e) {
    } catch (NullPointerException e){
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
    bGeneration.show();
    bFlood.show();
    if(map.floodOngoing){
      floodOngoing.show();
    }
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
    } else if (bGeneration.isPressed()) {
      buttons[selectedButton.ordinal()].selected = false;
      bGeneration.selected = true;
      selectedButton = bGeneration.type;
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
    case GENERATION:
      plot.setPoints(map.generationGPoints);
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
        rectC = color(6,9,46);
        textC = color(255);
      }
      if (this.isPressed()) {
        rectC = color(197,200,229);
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
  
  class Label{
    float posX;
    float posY;
    float bWidth;
    float bHeight;
    String name;

    color rectC;
    color textC;

    Label(float x, float y, float w, float h, String n, color rC, color tC) {   
      posX = x;
      posY = y;
      bWidth = w;
      bHeight = h;
      name = n;
      rectC = rC;
      textC = tC;
    }

    void show() {
      stroke(0);

      fill(rectC);
      rect(posX, posY, bWidth, bHeight, 10);

      fill(textC);
      textAlign(CENTER);
      textSize(20);
      text(name, posX+bWidth/2, (posY+bHeight/2));
      noStroke();
    }
  }
}