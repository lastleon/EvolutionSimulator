import grafica.*;

//// Verschiedene Buttonarten

//    ! Reihenfolge darf nicht verändert werden !    //
enum ButtonType {FITNESS, AVGAGE, OLDEST, FLOOD};

//// Outputs zum speichern der Daten

PrintWriter outputOldestAge;
PrintWriter outputAverageAge;
PrintWriter outputAverageFitness;
PrintWriter outputDeathsAndBirths;
PrintWriter outputPopulationSize;
// Momentane Dateinummer: z.B. 532 -> durchschnittsFitnessLw532.txt
// wird unten aus saveDataIndex.dat ausgelesen
int fileNumber;
// bestimmt, ob die Daten gespeichert werden
boolean save = true;

//// Weltvariablen
// speichert die momentane Skalierung, offset, etc.

// fenstergroesse muss seperat geändert werden, sollte immer gleich sein & einen schönen Wert haben, z.B. 100, 500,...
final int windowSize = 1000;
int worldSize;
float scale = 1;
float xOffset = 0.0;
float yOffset = 0.0;
float xOffsetTotal = 0.0;
float yOffsetTotal = 0.0;
float xPressed, yPressed;

//// Interface

// neues Fenster
PApplet iface;
// Plot und zugehörige Daten
GPlot plot;

int plotX = 0;
int plotY = 0;
int plotWidth = 250;
int plotHeight = 250;
float[] margin = new float[] {30,30,10,10};

ButtonType selectedButton = ButtonType.FITNESS;

//// restliche globale Variablen
// ID System
int currentID = 0;
// Kreaturen können mit GODMODE per Hand hinzugefügt werden
boolean godmode = false;
// wenn Maus gedrückt, dann locked wahr
boolean locked = false;


//// Welt
public World map;

void settings() {
  size(1000, 1000);
}

void setup() {
  // Einstellungen
  frameRate(50);
  noStroke();
  
  // Welt erstellt
  map = new World(250, 100); // Darf nicht 10 sein, sonst hängt sich die Simulation auf (??????)
  
  // Interface (neuesFenster) erstellt
  iface = new Interface();
  
  // saveDataIndex erhöht, Dateien & Writer erstellt
  if (save) {
    if (!fileExists(sketchPath("saveDataIndex.dat"))) {
      fileNumber = 1;
      byte[] b = {1};
      saveBytes("saveDataIndex.dat", b);
    } else {
      fileNumber = bytesToInt(loadBytes("saveDataIndex.dat")) + 1;
      saveBytes("saveDataIndex.dat", intToBytes(fileNumber));
    }

    outputOldestAge = createWriter("./data/ältestesLw/ältestesLw"+fileNumber+".txt");
    outputAverageAge = createWriter("./data/durchschnittsLw/durchschnittsLw"+fileNumber+".txt");
    outputAverageFitness = createWriter("./data/durchschnittsFitnessLw/durchschnittsFitnessLw"+fileNumber+".txt");
    outputDeathsAndBirths = createWriter("./data/todeUndGeburtenLw/todeUndGeburtenLw"+fileNumber+".txt");
    outputPopulationSize = createWriter("./data/population/population"+fileNumber+".txt");
  }
  
  // Welt & Kreaturen werden angezeigt
  map.showWorld();
  map.showCreature(map.getCreatures());
}

// Mainloop
void draw() {
  map.update();
}

// Eventhandler
void mouseWheel(MouseEvent event) {
  float e = event.getCount();

  scale -= (e / 10)*scale;
  if (scale < 0.01) {
    scale = 0.01;
  }
  if (scale > 10) {
    scale = 10;
  }

  if (!(scale <= 0.01 || scale >= 10)) {
    float rMouseX = (mouseX-(xOffsetTotal))/scale;
    float rMouseY = (mouseY-(yOffsetTotal))/scale;

    xOffsetTotal += rMouseX * (e / 10)*scale;
    yOffsetTotal += rMouseY * (e / 10)*scale;
  }
}
void mouseDragged() {
  if (locked) {
    xOffset = (mouseX - xPressed);
    yOffset = (mouseY - yPressed);
    xOffsetTotal += xOffset;
    yOffsetTotal += yOffset;
    xPressed = mouseX;
    yPressed = mouseY;
    cursor(MOVE);
  }
}
void keyPressed() {
  if (key ==' ') {
    scale = 1;
    xOffsetTotal = 0;
    yOffsetTotal = 0;
  }
  if (key == 'g'){
    godmode = !godmode;
  }
  if (key == 'n' && godmode == true) {
    map.population.add(new Creature(mouseX, mouseY, map.fW, currentID));
    currentID++;
  }
}

void mousePressed() {
  locked = true;
  xPressed = mouseX;
  yPressed = mouseY;
}
void mouseReleased() {
  locked = false;
  cursor(ARROW);
}
//// Helfermethoden
byte[] intToBytes(int x) {
  int bLength = floor(x/255);
  byte[] returnValue = new byte[bLength+1];
  for (int y = 0; y < bLength; y++) {
    returnValue[y] = byte(255);
  }
  returnValue[bLength] = byte(x%255);
  return returnValue;
}

int bytesToInt(byte[] b) {
  int returnValue = 0;
  for (byte by : b) {
    returnValue += int(by);
  }
  return returnValue;
}
//// I/O Methoden
boolean fileExists(String path) {
  File file=new File(sketchPath(path));
  return file.exists();
}