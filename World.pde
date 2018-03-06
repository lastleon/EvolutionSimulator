public class World {

  Field[][] world;
  ArrayList<Creature> population;
  ArrayList<Field> land;
  int initialPopulationSize;
  double year;
  float fW;
  double timePerFrame = 0.0005;
  int multiplier = 10000;
  float totalFitness = 0;
  float totalAge = 0;
  int birthCountPerYear;
  int deathCountPerYear;
  float fitnessMaximum = 1; // arbitrary value 
  Creature[] top10 = new Creature[10];
  int maxGeneration;

  float floodProbability = 0.00005; 
  float inititalFloodDuration;
  float floodDuration;
  float floodHeight;
  boolean floodOngoing = false;
  float floodIncreasePerFrame;
  float floodDecreasePerFrame;
  float firstPossibilityOfFlood = 15;
  
  float removePointsFromThisTime = 25;

  GPointsArray fitnessGPoints;
  GPointsArray averageAgeGPoints;
  GPointsArray oldestGPoints;

  float maxFloodDuration = 3;
  
  PrintWriter outputWriter;

  // Creaturee: Standard Werte
  final public static float stdEatingRate = 20;
  final public static float stdMaxVelocity = 2;
  final public static float stdAttackValue = 20;
  final public static float stdReproductionWaitingPeriod = 0.2;
  float stdDiameter;

  // World: Standard Werte
  final public static float stdOceanLevel = 43;


  public World(int worldS, int c) {

    year = 0;
    initialPopulationSize = c;
    worldSize = worldS;

    // Arrays for plots
    fitnessGPoints = new GPointsArray();

    averageAgeGPoints = new GPointsArray();
    averageAgeGPoints.add(0, 0);

    oldestGPoints = new GPointsArray();
    oldestGPoints.add(0, 0);

    // skaliert die Fieldbreite and die Fenstergroesse und die Fieldanzahl pro Reihe
    fW = windowSize/worldSize;
    stdDiameter = fW * 1.25;

    // generiert World
    world = new Field[worldSize][worldSize];
    float yNoise = 0.0;
    for (int y=0; y<worldSize; y++) {
      float xNoise = 0.0;
      for (int x=0; x<worldSize; x++) {
        world[x][y] = new Field(x*fW, y*fW, noise(xNoise, yNoise)*100, fW, x, y);
        xNoise += 0.038;
      }
      yNoise += 0.038;
    }
    land = new ArrayList<Field>();

    for (int i = 0; i<worldSize; i++) {
      for (Field f : world[i]) {
        if (f.isLand()) {
          land.add(f);
        }
      }
    }

    // generiert Anfangs-Creature
    population = new ArrayList<Creature>(c);
    for (int i=0; i<c; i++) {
      int posX;
      int posY;
      do {
        //println("\n\ngeneriere Creature");
        posX = (int)random(0, windowSize);
        posY = (int)random(0, windowSize);
      } while (!this.getField(posX, posY).isLand());

      population.add(new Creature(posX, posY, fW, currentID));
      currentID++;

      if (i<10) {
        top10[i] = population.get(i);
        top10[i].inTop10 = true;
      }
    }
  }

  // entfernt Tote
  public void birth() {
    ArrayList<Creature> populationCopy = new ArrayList<Creature>(population);
    for (Creature c1 : populationCopy) {
      for (Creature c2 : populationCopy) {
        if (!(c1.id == c2.id) && c1.collision(c2)) {
          this.mate(c1, c2);
          if(!c1.isReadyToGiveBirth()){
            break;
          }
        }
      }
    }
  }

  public float creatureDistance(Creature c1, Creature c2) {
    //return sqrt(abs(c1.getPosition().x - c2.getPosition().x) + abs(c1.getPosition().y - c2.getPosition().y));
    return c1.getPosition().dist(c2.getPosition());
  }

  public void mate(Creature c1, Creature c2) {
    if ((c1.NN.getBirthWill() > Creature.reproductionWill && c2.NN.getBirthWill() > Creature.reproductionWill) //Beide LW muessen zustimmen
      &&
      (c1.getEnergy() >= Creature.birthEnergy && c2.getEnergy() >= Creature.birthEnergy) // Beide LW muessen genug Energy haben
      &&
      (c1.isReadyToGiveBirth() && c2.isReadyToGiveBirth()) // Beide LW muessen readyToGiveBirth sein
      )
    {
      // benötigte Geburtsenergy wird abgezogen
      c1.addEnergy(-Creature.birthEnergy);
      c2.addEnergy(-Creature.birthEnergy);

      // Dummy-Vectoren
      PVector posC1 = new PVector(c1.getPosition().x, c1.getPosition().y);
      PVector posC2 = new PVector(c2.getPosition().x, c2.getPosition().y);

      // Neues Creature mit gemischten Connections entsteht
      this.addCreature(
        new Creature(
        (int)(posC1.x + cos(PVector.angleBetween(posC1, posC2))*(c1.getDiameter()/2)), 
        (int)(posC1.y + sin(PVector.angleBetween(posC1, posC2))*(c1.getDiameter()/2)), 
        c1.NN.getWeights(), 
        c2.NN.getWeights(), 
        c1.getFurColour(), 
        c2.getFurColour(), 
        max(c1.getGeneration(), c2.getGeneration()), 
        c1.getEatingRate(), 
        c1.getMaxVelocity(), 
        c1.getReproductionWaitingPeriod(), 
        c1.getAttackValue(), 

        c2.getEatingRate(), 
        c2.getMaxVelocity(), 
        c2.getReproductionWaitingPeriod(), 
        c2.getAttackValue(), 

        currentID

        ));
      currentID++;
      c1.setLastBirth((float)c1.getAge());
      c2.setLastBirth((float)c2.getAge());

      birthCountPerYear++;
    }
  }

  // update Methode wird immer in draw (Mainloop) gerufen
  public void update() {
    
    if (!floodOngoing && year > firstPossibilityOfFlood && random(0, 1) < floodProbability) {
      flood();
    }
    if (floodOngoing) {
      //println(floodIncreasePerFrame);
      floodDuration -= (float)timePerFrame;
      if (floodDuration <= 0) {
        floodOngoing = false;
        for (Field f : land) {
          f.oceanLevel = stdOceanLevel;
        }
      } else if (floodDuration/inititalFloodDuration > 0.25) {
        for (Field f : land) {
          f.oceanLevel += floodIncreasePerFrame;
        }
      } else {
        for (Field f : land) {
          f.oceanLevel -= floodDecreasePerFrame;
        }
      }
    }
    translate(xOffsetTotal+xOffset, yOffsetTotal+yOffset);
    scale(scale);
    background(0, 128, 255);
    int populationZahl = population.size();
    if (populationZahl < initialPopulationSize) {
      for (int i=0; i<initialPopulationSize-populationZahl; i++) {
        int posX;
        int posY;
        do {
          //println("\n\nfehlende Creature werden hizugefügt");
          posX = (int)random(0, windowSize);
          posY = (int)random(0, windowSize);
        } while (!this.getField(posX, posY).isLand());

        population.add(new Creature(posX, posY, fW, currentID));
        currentID++;
      }
    }

    totalAge = 0;
    totalFitness = 0;


    //println("AAA " + this.calculateFitnessMaximum() + " " + fitnessGPointsMaximum);

    for (int i = population.size()-1; i>=0; i--) {

      Creature c = population.get(i);

      c.input();
      c.NN.update();
      c.live();
      c.age();
      c.move(c.NN.getGeschwindigkeit(c), c.NN.getRotation());
      c.eat(c.NN.getEatingWill());
      c.memorise(c.NN.getMemory());
      c.attack(c.NN.getAttackWill()); // hilft, Bevoelkerung nicht zu gross zu halten

      totalAge += c.getAge();
      totalFitness += c.calculateFitnessStandard(); // funktioniert nur bei StandardfitnessGPoints
      if (!c.getStatus()) {
        if (c.inTop10) {
          while (true) {
            int index = int (random(0, population.size()));
            if (!population.get(index).inTop10) {
              top10[findInTop10(c)] = population.get(index);
              population.get(index).inTop10 = true;
              break;
            }
          }
        }
        population.remove(population.indexOf(c));
        deathCountPerYear++;
        continue;
      }

      c.updateFitness();
    }

    fitnessMaximum = this.calculateFitnessMaximum();

    birth();

    //println("CCC " + fitnessGPointsMaximum + " " + fitnessGPointsMaximum);

    if (frameCount > 1) {
      growFields();
    } else {
      for (Field f : land) {
        f.influenceByWater();
      }
    }


    year += timePerFrame;
    float neuesJahr = (float)(year * multiplier);
    year = (double)floor(neuesJahr) / multiplier;
    if (year != 0 && year/((int)year) == 1) {
      println("Max Generation: " + maxGeneration);
    }
    
    if ((year*100)%1 == 0) {
      double oldestCAge = 0;
      int oldestCID = 0; // 0 ist Dummywert
      for (Creature c : population) {
        if (c.getAge() > oldestCAge) {
          oldestCAge = c.getAge();
          oldestCID = c.getID();
        }
      }

      fitnessGPoints.add((float)year, (float)totalFitness/population.size());
      oldestGPoints.add((float)year, (float)oldestCAge);
      averageAgeGPoints.add((float)year, (float)totalAge/population.size());
      
      if (year>removePointsFromThisTime) {
        fitnessGPoints.remove(0);
        averageAgeGPoints.remove(0);
        oldestGPoints.remove(0);
        
        plot.removePoint(0);
      }

      switch(selectedButton) {
      case FITNESS:
        plot.addPoint((float)year, (float)totalFitness/population.size());
        break;
      case OLDEST:
        plot.addPoint((float)year, (float)oldestCAge);
        break;
      case AVGAGE:
        plot.addPoint((float)year, (float)totalAge/population.size());
      }

      if (save) {
        outputOldestAge.print("(" + year + "," + oldestCAge + "," + oldestCID + ");");
        outputOldestAge.flush();
        outputAverageAge.print("(" + year + "," + totalAge/population.size() + ");");
        outputAverageAge.flush();
        outputAverageFitness.print("(" + year + "," + totalFitness/population.size() + ");");
        outputAverageFitness.flush();
        outputPopulationSize.print("(" + year + "," + population.size() + ");");
        outputPopulationSize.flush();

        if (year%1==0) {
          outputDeathsAndBirths.print("(" + year + "," + deathCountPerYear + "," + birthCountPerYear + ");");
          outputDeathsAndBirths.flush();
          birthCountPerYear = 0;
          deathCountPerYear = 0;
        }
      }
    }
    showWorld();
    showCreature();
    
  }
  
  // Creature hinzufügen
  public void addCreature(Creature c) {
    population.add(c);
  }

  void flood() {
    floodOngoing = true;
    floodDuration = random(1, maxFloodDuration);
    floodHeight = random(5, 12);
    floodIncreasePerFrame = floodHeight/((floodDuration * 0.75)/(float)timePerFrame);
    floodDecreasePerFrame = floodHeight/((floodDuration * 0.25)/(float)timePerFrame);
    inititalFloodDuration = floodDuration;
  }

  float calculateFitnessMaximum() {
    float maxFitness=0;
    int tempMaxGeneration = 0;
    for (Creature c : population) {
      if (c.fitness > maxFitness) {
        maxFitness = c.fitness;
      }
      if (c.generation > tempMaxGeneration) {
        tempMaxGeneration = c.generation;
      }
      addTop10(c);
    }
    maxGeneration = tempMaxGeneration;
    if (maxFitness != 0) {
      return maxFitness;
    } else return 0.001;
  }

  void addTop10(Creature c) {
    int index = 0;
    boolean replaced = false;
    for (int i=0; i<10; i++) {
      if (top10[i] == c) {
        return;
      }
    }
    for (int i=0; i<10; i++) {
      if (top10[i].fitness < c.fitness && top10[index].fitness > top10[i].fitness) {
        index = i;
        replaced = true;
      }
    }
    if (replaced) {
      top10[index].inTop10 = false;
      top10[index] = c;
      c.inTop10 = true;
    }
  }

  Integer findInTop10(Creature c) {
    for (int i = 0; i<10; i++) {
      if (top10[i] == c) {
        return i;
      }
    }
    return null;
  }

  // zeichnet die World
  public void showWorld() {
    for (int x=0; x<worldSize; x++) {
      for (Field a : world[x]) {
        a.drawField();
      }
    }
  }
  public void showCreature() {
    stroke(1);
    strokeWeight(0.2);
    for (Creature c : population) {
      c.drawCreature();
    }
    noStroke();
  }
  // zeichnet ein Array aus Creature (meistens am Anfang genutzt) // ka ob mans noch braucht, ich lass es einfach mal drinnen
  public void showCreature(Creature[] cArray) {
    stroke(1);
    strokeWeight(0.2);
    for (Creature c : cArray) {
      c.drawCreature();
    }
    noStroke();
  }

  public void growFields() {
    for (Field f : land) {
      f.influenceNeighbours();
    }
    for (Field f : land) {
      f.grow();
    }
  }

  //// Getter
  public Creature[] getCreatures() {
    return population.toArray(new Creature[population.size()]);
  }

  public Field getField(int x, int y) { // funktioniert nur bei schönen Zahle, muss noch besser werden (1000, 100, etc)
    float xField = (x - (x % fW)) / fW;
    float yField = (y - (y % fW)) / fW;
    if (xField >= worldSize) {
      xField = 0;
    }
    if (yField >= worldSize) {
      yField = 0;
    }
    //println("x: " + x + " xField: " + xField + "         y: " + y + " yField: " + yField);
    return world[(int)xField][(int)yField];
  }

  public Field getFieldInArray(int x, int y) {
    try {
      if (x != -1 && x != worldSize && y != -1 && y != worldSize) { // um die ArrayIndexOutOfWoundsException zu umgehen, die normalerweise auftreten würde // try-catch Block ist tredzdem zur sicherheit da
        return world[x][y];
      } else return null;
    } 
    catch(Exception e) {
      e.printStackTrace();
      return null;
    }
  }

  public Creature getCreature(PVector v) {

    for (Creature c : population) {
      if (v.dist(c.position) < c.diameter/2) {
        return c;
      }
    }
    return null;
  }
  public double getTimePerFrame() {
    return timePerFrame;
  }
  public int getTimeMultiplier() {
    return multiplier;
  }
  public float getFieldWidth() {
    return fW;
  }
}