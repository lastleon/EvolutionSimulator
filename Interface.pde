class Interface extends PApplet {    //<>//

  // Grafika Library für Plot benutzt
  // in Video erklärt

  Button[] buttons;

  Button bFitness;
  Button bAvgAge;
  Button bPopulation;
  Button bFlood;
  Button bGeneration;
  Button switchSlider;

  Slider slider;
  int sliderState = 0;

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
    bPopulation = new Button(100, plotHeight, 100, 50, "Population", ButtonType.POPULATION);
    bFlood = new Button(width-100, height-50, 100, 50, "FLUT", ButtonType.FLOOD);
    bGeneration = new Button(100, plotHeight+50, 100, 50, "Generation", ButtonType.GENERATION);
    switchSlider = new Button(width-100, height-100, 100, 50, "Change Slider", ButtonType.SWITCHSLIDER);

    slider = new Slider(plotWidth+leftSpacing, plotHeight-150, 130, 65, 0, 2*map.minPopulationSize);

    buttons = new Button[] {bFitness, bAvgAge, bPopulation, bFlood, bGeneration}; // order must not be changed

    floodOngoing = new Label(plotWidth+leftSpacing, plotHeight-75, 130, 65, "FLUT", color(255, 46, 46), color(255));
  }

  void draw() {
    background(bg);
    drawPlot();
    showInterface();
    stroke(0);
    line(plotWidth, 0, plotWidth, plotHeight);
    line(0, plotHeight, width, plotHeight);
    if (sliderState == 0)map.minPopulationSize = (int)slider.getValue();
    else if (sliderState == 1) oceanLevel = slider.getValue();
  }

  void drawPlot() {
    // Exceptions treten ohne ersichtlichen Grund auf, Plot funktioniert weiterhin gut
    // Liegt an Grafika
    try {
      plot.beginDraw();
      plot.drawBackground();
      plot.drawXAxis();
      plot.drawYAxis();
      plot.drawTitle();
      plot.drawLines();
    } 
    catch (IndexOutOfBoundsException e) {
    } 
    catch (NullPointerException e) {
    } 
    catch(Exception e) {
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
    text("Bewohner: " + map.populationCount, plotWidth + leftSpacing, upSpacing + 17 + lineSpacing);
    textSize(10);
    if (sliderState == 0)text("Mindest-Bewohnerzahl: " + (int)slider.getValue(), plotWidth + leftSpacing, upSpacing + 50 + lineSpacing);
    if (sliderState == 1)text("Meeresspiegelhöhe:  " + (int)slider.getValue(), plotWidth + leftSpacing, upSpacing + 50 + lineSpacing);

    bFitness.show();
    bAvgAge.show();
    bPopulation.show();
    bGeneration.show();
    bFlood.show();
    switchSlider.show();

    slider.show();

    if (map.floodOngoing) {
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
    } else if (bPopulation.isPressed()) {
      buttons[selectedButton.ordinal()].selected = false;
      bPopulation.selected = true;
      selectedButton = bPopulation.type;
    } else if (bGeneration.isPressed()) {
      buttons[selectedButton.ordinal()].selected = false;
      bGeneration.selected = true;
      selectedButton = bGeneration.type;
    } else if (bFlood.isPressed()) {
      map.flood();
    } else if (switchSlider.isPressed()) {
      sliderState++;
      sliderState %= 2;
      if (sliderState == 0) {
        slider.upperLimit = max(2*map.minPopulationSize,5);
        slider.setValue(map.minPopulationSize);
      } else if (sliderState == 1) {
        slider.upperLimit = 100;
        slider.setValue(oceanLevel);
      }
    }

    switch(selectedButton) {
    case FITNESS:
      plot.setPoints(map.fitnessGPoints);
      break;
    case POPULATION:
      plot.setPoints(map.oldestGPoints);
      break;
    case AVGAGE:
      plot.setPoints(map.averageAgeGPoints);
      break;
    case GENERATION:
      plot.setPoints(map.generationGPoints);
      break;
    }

    slider.changeValue();
  }

  void mouseDragged() {
    slider.changeValue();
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
        rectC = color(6, 9, 46);
        textC = color(255);
      }
      if (this.isPressed()) {
        rectC = color(197, 200, 229);
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

  class Label {
    float posX;
    float posY;
    float lWidth;
    float lHeight;
    String name;

    color rectC;
    color textC;

    Label(float x, float y, float w, float h, String n, color rC, color tC) {   
      posX = x;
      posY = y;
      lWidth = w;
      lHeight = h;
      name = n;
      rectC = rC;
      textC = tC;
    }

    void show() {
      stroke(0);

      fill(rectC);
      rect(posX, posY, lWidth, lHeight, 10);

      fill(textC);
      textAlign(CENTER);
      textSize(20);
      text(name, posX+lWidth/2, (posY+lHeight/2));
      text(round((1-map.floodDuration/map.initialFloodDuration)*100)+"%", posX+lWidth/2, posY+lHeight/2+20);
      noStroke();
    }
  }
  class Slider {
    float posX, posY;
    float sWidth, sHeight;
    float lowerLimit, upperLimit;
    float value;
    float sliderX;
    float sliderWidth, sliderHeight;

    Slider(float x, float y, float w, float h, float lower, float upper) {
      posX = x;
      posY = y;
      sWidth = w;
      sHeight = h;
      lowerLimit = lower;
      upperLimit = upper;
      sliderX = (2*posX + sWidth)/2;   
      sliderWidth = sWidth/8;
      sliderHeight = sHeight*0.8;
      value = map(sliderX, posX+sliderWidth, posX+sWidth-sliderWidth, lowerLimit, upperLimit);
    }

    void show() {
      color rectC;
      color sliderC;
      stroke(0);

      rectC = color(6, 9, 46);
      sliderC = color(255);

      fill(rectC);
      rect(posX, posY, sWidth, sHeight, 10);
      rectMode(CENTER);
      fill(155);
      rect(posX + sWidth/2, posY+sHeight/2, sWidth-2*sliderWidth, sliderHeight*0.25, 3);
      fill(sliderC);
      rect(sliderX, posY+sHeight/2, sliderWidth, sliderHeight, 5);
      noStroke();
      rectMode(CORNER);
    }

    void changeValue() {
      if (isPressed() && mouseX > posX+sliderWidth && mouseX < posX+sWidth-sliderWidth) {
        sliderX = mouseX;
      }
      value = map(sliderX, posX+sliderWidth, posX+sWidth-sliderWidth, lowerLimit, upperLimit);
    }

    void setValue(float v) {
      value = v;
      sliderX = map(value, lowerLimit, upperLimit, posX+sliderWidth, posX+sWidth-sliderWidth);
    }

    void setValue(int v) {
      value = v;
      sliderX = map(value, lowerLimit, upperLimit, posX+sliderWidth, posX+sWidth-sliderWidth);
    }

    boolean isPressed() {
      return (mouseX>sliderX-sliderWidth/2  && mouseX<sliderX+sliderWidth/2 && mouseY > posY+sHeight*0.1 && mouseY < posY + sliderHeight+sHeight*0.1 && mousePressed);
    }
    float getValue() {
      return value;
    }
  }
}
