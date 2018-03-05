public class Welt {

  private Feld[][] welt;
  private ArrayList<Lebewesen> bewohner;
  private ArrayList<Feld> land;
  private int lwZahl;
  private float weltX;
  private float weltY;
  private double jahr;
  private float spacing;
  private float fB;
  private double zeitProFrame = 0.0005;
  private int multiplikator = 10000;
  private float gesamtFitness = 0;
  private float gesamtAlter = 0;
  private int geburtenProJahr;
  private int todeProJahr;
  private int geburten = 0;
  private float fitnessMaximum = 1; // arbitrary value 
  Lebewesen[] top10 = new Lebewesen[10];
  private int maxGeneration;

  float ueProb = 0.000001; 
  float ueStartD;
  float ueDauer;
  float ueHoehe;
  boolean ueLaufend = false;
  float ueAnstiegProFrame;
  float ueAbstiegProFrame;
  float minUeberschwemmungsjahr = 3;

  GPointsArray fitness;
  GPointsArray altersschnitt;
  GPointsArray aeltestes;

  float maxUeberschwemmungsdauer = 3;
  
  NNOutput output;

  PrintWriter outputWriter;

  // Tiere: Standard Werte
  final public static float stdFressrate = 22;
  final public static float stdMaxGeschwindigkeit = 2;
  final public static float stdAngriffswert = 17;
  final public static float stdReproduktionswartezeit = 0.2;
  float stdDurchmesser;
  
  // Welt: Standard Werte
  final public static float stdMeeresspiegel = 43;


  public Welt(int weltG, int lw) {

    output = new NNOutput();

    jahr = 0;
    lwZahl = lw;
    weltGroesse = weltG;

    // Arrays for plots
    fitness = new GPointsArray();

    altersschnitt = new GPointsArray();
    altersschnitt.add(0, 0);

    aeltestes = new GPointsArray();
    aeltestes.add(0, 0);

    // skaliert die Feldbreite and die Fenstergroesse und die Feldanzahl pro Reihe
    fB = fensterGroesse/weltGroesse;
    stdDurchmesser = fB * 1.25;

    // generiert Welt
    welt = new Feld[weltGroesse][weltGroesse];
    float yNoise = 0.0;
    for (int y=0; y<weltGroesse; y++) {
      float xNoise = 0.0;
      for (int x=0; x<weltGroesse; x++) {
        welt[x][y] = new Feld(x*fB, y*fB, noise(xNoise, yNoise)*100, fB, x, y);
        xNoise += 0.038;
      }
      yNoise += 0.038;
    }
    land = new ArrayList<Feld>();

    for (int i = 0; i<weltGroesse; i++) {
      for (Feld f : welt[i]) {
        if (f.isLand()) {
          land.add(f);
        }
      }
    }

    // generiert Anfangs-Lebewesen
    bewohner = new ArrayList<Lebewesen>(lw);
    for (int i=0; i<lw; i++) {
      int posX;
      int posY;
      do {
        //println("\n\ngeneriere Lebewesen");
        posX = (int)random(0, fensterGroesse);
        posY = (int)random(0, fensterGroesse);
      } while (!this.getFeld(posX, posY).isLand());

      bewohner.add(new Lebewesen(posX, posY, fB, currentID));
      currentID++;

      if (i<10) {
        top10[i] = bewohner.get(i);
        top10[i].inTop10 = true;
      }
    }
  }

  // entfernt Tote
  public void geburt() {
    ArrayList<Lebewesen> bewohnerCopy = new ArrayList<Lebewesen>(bewohner);
    for (Lebewesen lw1 : bewohnerCopy) {
      for (Lebewesen lw2 : bewohnerCopy) {
        if (!lw1.equals(lw2) && lw1.collision(lw2)) {
          this.gebaeren(lw1, lw2);
        }
      }
    }
  }

  public float entfernungLebewesen(Lebewesen lw1, Lebewesen lw2) {
    //return sqrt(abs(lw1.getPosition().x - lw2.getPosition().x) + abs(lw1.getPosition().y - lw2.getPosition().y));
    return lw1.getPosition().dist(lw2.getPosition());
  }

  public void gebaeren(Lebewesen lw1, Lebewesen lw2) {
    if ((lw1.NN.getGeburtwille() > Lebewesen.reproduktionswille && lw2.NN.getGeburtwille() > Lebewesen.reproduktionswille) //Beide LW muessen zustimmen
      &&
      (lw1.getEnergie() >= Lebewesen.geburtsenergie && lw2.getEnergie() >= Lebewesen.geburtsenergie) // Beide LW muessen genug Energie haben
      &&
      (lw1.isGeburtsbereit() && lw2.isGeburtsbereit()) // Beide LW muessen geburtsbereit sein
      //&&
      //(lw1.calculateFitnessStandard() > this.getDurchschnittsFitness() && lw2.calculateFitnessStandard() > this.getDurchschnittsFitness()) // funktioniert nur bei Standardfitness
      )
    {
      // benötigte Geburtsenergie wird abgezogen
      lw1.addEnergie(-Lebewesen.geburtsenergie);
      lw2.addEnergie(-Lebewesen.geburtsenergie);

      // Dummy-Vectoren
      PVector posLw1 = new PVector(lw1.getPosition().x, lw1.getPosition().y);
      PVector posLw2 = new PVector(lw2.getPosition().x, lw2.getPosition().y);
      geburten++;
      println("geburt" + geburten);
      // Neues Lebewesen mit gemischten Connections entsteht
      this.addLebewesen(
        new Lebewesen(
        (int)(posLw1.x + cos(PVector.angleBetween(posLw1, posLw2))*(lw1.getDurchmesser()/2)), 
        (int)(posLw1.y + sin(PVector.angleBetween(posLw1, posLw2))*(lw1.getDurchmesser()/2)), 
        lw1.NN.getConnections1(), 
        lw1.NN.getConnections2(), 
        lw2.NN.getConnections1(), 
        lw2.NN.getConnections2(), 
        lw1.getFellfarbe(), 
        lw2.getFellfarbe(), 
        max(lw1.getGeneration(), lw2.getGeneration()), 
        lw1.getFressrate(), 
        lw1.getMaxGeschwindigkeit(), 
        lw1.getReproduktionswartezeit(), 
        lw1.getAngriffswert(), 

        lw2.getFressrate(), 
        lw2.getMaxGeschwindigkeit(), 
        lw2.getReproduktionswartezeit(), 
        lw2.getAngriffswert(), 

        currentID

        ));
      currentID++;
      lw1.setLetzteGeburt((float)lw1.getAlter());
      lw2.setLetzteGeburt((float)lw2.getAlter());

      geburtenProJahr++;
    }
  }

  // update Methode wird immer in draw (Mainloop) gerufen
  public void update() {
    if(!ueLaufend && jahr > minUeberschwemmungsjahr && random(0, 1) < ueProb){
      ueberschwemmung();
    }
    if(ueLaufend){
      //println(ueAnstiegProFrame);
      ueDauer -= (float)zeitProFrame;
      if(ueDauer <= 0){
        ueLaufend = false;
        for(Feld f : land){
          f.meeresspiegel = stdMeeresspiegel;
        }
      } else if(ueDauer/ueStartD > 0.25){
        for(Feld f : land){
          f.meeresspiegel += ueAnstiegProFrame;
        } 
      } else {
        for(Feld f : land){
          f.meeresspiegel -= ueAbstiegProFrame;
        }
      }
    }
    translate(xOffsetGesamt+xOffset, yOffsetGesamt+yOffset);
    scale(skalierungsfaktor);
    background(0, 128, 255);
    weltX = (0-xOffsetGesamt-xOffset)/skalierungsfaktor;
    weltY = (0-yOffsetGesamt-yOffset)/skalierungsfaktor;
    spacing = 20/skalierungsfaktor;
    int bewohnerZahl = bewohner.size();
    if (bewohnerZahl < lwZahl) {
      for (int i=0; i<lwZahl-bewohnerZahl; i++) {
        int posX;
        int posY;
        do {
          //println("\n\nfehlende Lebewesen werden hizugefügt");
          posX = (int)random(0, fensterGroesse);
          posY = (int)random(0, fensterGroesse);
        } while (!this.getFeld(posX, posY).isLand());

        bewohner.add(new Lebewesen(posX, posY, fB, currentID));
        currentID++;
      }
    }

    gesamtAlter = 0;
    gesamtFitness = 0;


    //println("AAA " + this.calculateFitnessMaximum() + " " + fitnessMaximum);

    for (int i = bewohner.size()-1; i>=0; i--) {

      Lebewesen lw = bewohner.get(i);

      lw.input();
      lw.NN.update();
      lw.leben();
      lw.altern();
      lw.bewegen(lw.NN.getGeschwindigkeit(lw), lw.NN.getRotation());
      lw.fressen(lw.NN.getFresswille());
      lw.erinnern(lw.NN.getMemory());
      //lw.fellfarbeAendern(lw.NN.getFellRot(), lw.NN.getFellGruen(), lw.NN.getFellBlau());
      lw.angriff(lw.NN.getAngriffswille()); // hilft, Bevoelkerung nicht zu gross zu halten

      gesamtAlter += lw.getAlter();
      gesamtFitness += lw.calculateFitnessStandard(); // funktioniert nur bei Standardfitness
      if (!lw.getStatus()) {
        if (lw.inTop10) {
          while (true) {
            int index = int (random(0, bewohner.size()));
            if (!bewohner.get(index).inTop10) {
              top10[findInTop10(lw)] = bewohner.get(index);
              bewohner.get(index).inTop10 = true;
              break;
            }
          }
        }
        bewohner.remove(bewohner.indexOf(lw));
        todeProJahr++;
        continue;
      }
      output.addValue((int)(lw.NN.getRotationPur()*10000));

      lw.updateFitness();
    }

    fitnessMaximum = this.calculateFitnessMaximum();

    geburt();

    //println("CCC " + fitnessMaximum + " " + fitnessMaximum);

    if (frameCount > 1) {
      felderBewachsen();
    } else {
      for (Feld f : land) {
        f.vonWasserBeeinflussen();
      }
    }


    jahr += zeitProFrame;
    float neuesJahr = (float)(jahr * multiplikator);
    jahr = (double)floor(neuesJahr) / multiplikator;
    if (jahr != 0 && jahr/((int)jahr) == 1) {
      println("Max Generation: " + maxGeneration);
    }
    if (jahr != 0 && jahr/((int)jahr) == 10) {
      fitness.remove(0);
      altersschnitt.remove(0);
      aeltestes.remove(0);
    }
    if (save) {
      if ((jahr*100)%1 == 0) {
        double aeltestesLwAlter = 0;
        int aeltestesLwID = 0; // 0 ist Dummywert
        for (Lebewesen lw : bewohner) {
          if (lw.getAlter() > aeltestesLwAlter) {
            aeltestesLwAlter = lw.getAlter();
            aeltestesLwID = lw.getID();
          }
        }
        fitness.add((float)jahr, (float)gesamtFitness/bewohner.size());
        aeltestes.add((float)jahr, (float)aeltestesLwAlter);
        altersschnitt.add((float)jahr, (float)gesamtAlter/bewohner.size());
        
        if(selectedButton == ButtonType.FITNESS){
          plot.addPoint((float)jahr, (float)gesamtFitness/bewohner.size());
        } else if(selectedButton == ButtonType.AELTESTES){
          plot.addPoint((float)jahr, (float)aeltestesLwAlter);
        } else if(selectedButton == ButtonType.ALTERSSCHNITT){
          plot.addPoint((float)jahr, (float)gesamtAlter/bewohner.size());
        }
        
        output1.print("(" + jahr + "," + aeltestesLwAlter + "," + aeltestesLwID + ");");
        output1.flush();
        output2.print("(" + jahr + "," + gesamtAlter/bewohner.size() + ");");
        output2.flush();
        output3.print("(" + jahr + "," + gesamtFitness/bewohner.size() + ");");
        output3.flush();
        output5.print("(" + jahr + "," + bewohner.size() + ");");
        output5.flush();
      }
      if (jahr%1==0) {
        output4.print("(" + jahr + "," + todeProJahr + "," + geburtenProJahr + ");");
        output4.flush();
        geburtenProJahr = 0;
        todeProJahr = 0;
      }
    }

    showWelt();
    showLebewesen();

  }
  // Lebewesen hinzufügen
  public void addLebewesen(Lebewesen lw) {
    bewohner.add(lw);
  }

  void saveOutput() {
    outputWriter = createWriter(sketchPath("/NNOutput/"+(int)jahr+".txt"));
    StringBuilder sb = new StringBuilder();
    for (int i=0; i<output.deviation.length; i++) {
      sb.append("("+i+","+output.deviation[i]+");");
    }
    outputWriter.print(sb.toString());
    output = new NNOutput();
  }
  
  void ueberschwemmung(){
    println("Überschwemmung!");
    ueLaufend = true;
    ueDauer = random(1, maxUeberschwemmungsdauer);
    ueHoehe = random(5, 12);
    ueAnstiegProFrame = ueHoehe/((ueDauer * 0.75)/(float)zeitProFrame);
    ueAbstiegProFrame = ueHoehe/((ueDauer *0.25)/(float)zeitProFrame);
    ueStartD = ueDauer;
  }

  float calculateFitnessMaximum() {
    float maxFitness=0;
    int tempMaxGeneration = 0;
    for (Lebewesen lw : bewohner) {
      if (lw.fitness > maxFitness) {
        maxFitness = lw.fitness;
      }
      if (lw.generation > tempMaxGeneration) {
        tempMaxGeneration = lw.generation;
      }
      addTop10(lw);
    }
    maxGeneration = tempMaxGeneration;
    if (maxFitness != 0) {
      return maxFitness;
    } else return 0.001;
  }

  void addTop10(Lebewesen lw) {
    int index = 0;
    boolean replaced = false;
    for (int i=0; i<10; i++) {
      if (top10[i] == lw) {
        return;
      }
    }
    for (int i=0; i<10; i++) {
      if (top10[i].fitness < lw.fitness && top10[index].fitness > top10[i].fitness) {
        index = i;
        replaced = true;
      }
    }
    if (replaced) {
      top10[index].inTop10 = false;
      top10[index] = lw;
      lw.inTop10 = true;
    }
  }

  Integer findInTop10(Lebewesen lw) {
    for (int i = 0; i<10; i++) {
      if (top10[i] == lw) {
        return i;
      }
    }
    return null;
  }

  // zeichnet die Welt
  public void showWelt() {
    for (int x=0; x<weltGroesse; x++) {
      for (Feld a : welt[x]) {
        a.drawFeld();
      }
    }
  }
  public void showLebewesen() {
    stroke(1);
    strokeWeight(0.2);
    for (Lebewesen lw : bewohner) {
      lw.drawLebewesen();
    }
    noStroke();
  }
  // zeichnet ein Array aus Lebewesen (meistens am Anfang genutzt) // ka ob mans noch braucht, ich lass es einfach mal drinnen
  public void showLebewesen(Lebewesen[] lwArray) {
    stroke(1);
    strokeWeight(0.2);
    for (Lebewesen lw : lwArray) {
      lw.drawLebewesen();
    }
    noStroke();
  }

  // zeichnet ein einziges Lebewesen (eig. unnötig, aber um die Form zu wahren sollte man diese Methode nutzen)
  public void showLebewesen(Lebewesen lw) {
    stroke(1);
    strokeWeight(0.2);
    lw.drawLebewesen();
    noStroke();
  }

  public void felderBewachsen() {
    for (Feld f : land) {
      f.nachbarnBeeinflussen();
    }
    for (Feld f : land) {
      f.wachsen();
    }
  }

  //// Getter
  public Lebewesen[] getLebewesen() {
    return bewohner.toArray(new Lebewesen[bewohner.size()]);
  }

  public int getWeltGroesse() {
    return weltGroesse;
  }

  public Feld getFeld(int x, int y) { // funktioniert nur bei schönen Zahle, muss noch besser werden (1000, 100, etc)
    float xFeld = (x - (x % fB)) / fB;
    float yFeld = (y - (y % fB)) / fB;
    if (xFeld >= weltGroesse) {
      xFeld = 0;
    }
    if (yFeld >= weltGroesse) {
      yFeld = 0;
    }
    //println("x: " + x + " xFeld: " + xFeld + "         y: " + y + " yFeld: " + yFeld);
    return welt[(int)xFeld][(int)yFeld];
  }

  public Feld getFeldInArray(int x, int y) {
    try {
      if (x != -1 && x != weltGroesse && y != -1 && y != weltGroesse) { // um die ArrayIndexOutOfBoundsException zu umgehen, die normalerweise auftreten würde // try-catch Block ist trotzdem zur sicherheit da
        return welt[x][y];
      } else return null;
    } 
    catch(Exception e) {
      e.printStackTrace();
      return null;
    }
  }

  public Lebewesen getTier(PVector v) {

    for (Lebewesen lw : bewohner) {
      if (v.dist(lw.position) < lw.durchmesser/2) {
        return lw;
      }
    }
    return null;
  }

  public double getJahr() {
    return jahr;
  }
  public double getZeitProFrame() {
    return zeitProFrame;
  }
  public int getZeitMultiplikator() {
    return multiplikator;
  }
  public float getFeldbreite() {
    return fB;
  }
  public float getDurchschnittsFitness() { // funktioniert nur bei Standardfitness
    return gesamtFitness/bewohner.size();
  }
}