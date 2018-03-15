public class World {

  //// Veränderbare Werte
  // Flutwerte
  double floodProbability = 0.00005;
  float firstPossibilityOfFlood = 15;
  float maxFloodDuration = 3;

  // Kreatur: Standard Werte
  final public static float stdEatingRate = 17;
  final public static float stdMaxVelocity = 2;
  final public static float stdAttackValue = 60;
  float diameterMultiplier = 0.25;

  // Welt: Standard Werte

  ////
  //// Welt
  // Welt
  Field[][] world;
  ArrayList<Field> land;
  float fW = 8;
  float worldBounds;

  // Population
  ArrayList<Creature> population;
  int minPopulationSize;
  float stdDiameter;

  // Zeit
  double year;
  double timePerFrame = 0.0005;
  int multiplier = 10000;

  // Statistiken
  Creature[] top10 = new Creature[10];
  float totalFitness = 0;
  float fitnessMaximum = 1; // arbitrary value

  float totalAge = 0;

  int birthCountPerYear;
  int deathCountPerYear;

  int maxGeneration;

  //// Flut
  float initialFloodDuration;
  float floodDuration;
  float floodHeight;
  boolean floodOngoing = false;
  float floodIncreasePerFrame;
  float floodDecreasePerFrame;

  //// Plot
  float removePointsFromThisTime = 25;

  GPointsArray fitnessGPoints;
  GPointsArray averageAgeGPoints;
  GPointsArray oldestGPoints;
  GPointsArray generationGPoints;


  public World(int worldS, int c) {

    year = 0;
    minPopulationSize = c;
    worldSize = worldS;

    // Arrays für Plots
    fitnessGPoints = new GPointsArray();

    averageAgeGPoints = new GPointsArray();
    averageAgeGPoints.add(0, 0);

    oldestGPoints = new GPointsArray();

    generationGPoints = new GPointsArray();
    generationGPoints.add(0, 1);

    stdDiameter = fW * diameterMultiplier;
    worldBounds = worldSize*fW;

    land = new ArrayList<Field>();

    // generiert Welt
    world = new Field[worldSize][worldSize];
    float yNoise = 0.0;
    for (int y=0; y<worldSize; y++) {
      float xNoise = 0.0;
      for (int x=0; x<worldSize; x++) {
        world[x][y] = new Field(x*fW, y*fW, noise(xNoise, yNoise)*100, fW, x, y);
        if (world[x][y].isLand()) {
          land.add(world[x][y]);
        }
        xNoise += 0.046;
      }
      yNoise += 0.046;
    }

    // generiert Anfangspopulation
    population = new ArrayList<Creature>(c);
    for (int i=0; i<c; i++) {
      int posX;
      int posY;
      do {
        posX = (int)random(0, this.worldBounds);
        posY = (int)random(0, this.worldBounds);
      } while (!this.getField(posX, posY).isLand());

      population.add(new Creature(posX, posY, this, currentID));
      currentID++;

      // anfangs werden ersten 10 zu Top 10
      if (i<10) {
        top10[i] = population.get(i);
        top10[i].inTop10 = true;
      }
    }
  }

  // 
  public void lookForMatingPartner() {
    ArrayList<Creature> populationCopy = new ArrayList<Creature>(population);
    for (Creature c1 : populationCopy) {
      for (Creature c2 : populationCopy) {
        if (!(c1.id == c2.id) && c1.collision(c2)) {
          this.mate(c1, c2);
          if (!c1.isReadyToGiveBirth()) {
            break;
          }
        }
      }
    }
  }

  public float creatureDistance(Creature c1, Creature c2) {
    return c1.getPosition().dist(c2.getPosition());
  }

  public void mate(Creature c1, Creature c2) {
    if ((c1.NN.getBirthWill() > Creature.reproductionWill && c2.NN.getBirthWill() > Creature.reproductionWill) //Beide Kreaturen müssen zustimmen
      &&
      (c1.getEnergy() >= Creature.birthEnergy && c2.getEnergy() >= Creature.birthEnergy) // Beide Kreaturen müssen genug Energie haben
      &&
      (c1.isReadyToGiveBirth() && c2.isReadyToGiveBirth()) // Beide Kreaturen müssen geburtsbereit sein
      )
    {
      // benötigte Geburtsenergie wird abgezogen
      c1.addEnergy(-Creature.birthEnergy);
      c2.addEnergy(-Creature.birthEnergy);

      // Dummy-Vectoren
      PVector posC1 = new PVector(c1.getPosition().x, c1.getPosition().y);
      PVector posC2 = new PVector(c2.getPosition().x, c2.getPosition().y);

      // Neue Kreatur mit gemischten Weights & Genen entsteht
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
        c1.getAttackValue(), 

        c2.getEatingRate(), 
        c2.getMaxVelocity(), 
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
    // Flut
    if (!floodOngoing && year > firstPossibilityOfFlood && random(0, 1) < floodProbability) {
      flood();
    }
    if (floodOngoing) {
      floodDuration -= (float)timePerFrame;
      for (Field f : land) {
        f.influenceByWater();
      }
      if (floodDuration <= 0) {
        floodOngoing = false;
        oceanLevel = stdOceanLevel;
      } else if (floodDuration/initialFloodDuration > 0.25) {
        oceanLevel += floodIncreasePerFrame;
      } else {
        oceanLevel -= floodDecreasePerFrame;
      }
    }
    translate(xOffsetTotal+xOffset, yOffsetTotal+yOffset);
    scale(scale);
    background(0, 128, 255);

    totalAge = 0;
    totalFitness = 0;

    for (int i = population.size()-1; i>=0; i--) {

      Creature c = population.get(i);

      c.input();
      c.NN.update();
      c.live();
      c.age();
      c.move(c.NN.getGeschwindigkeit(c), c.NN.getRotation());
      c.eat(c.NN.getEatingWill());
      c.memorise(c.NN.getMemory(), c.NN.getMemory2());
      c.attack(c.NN.getAttackWill()); // hilft, Bevölkerung nicht zu gross zu halten

      totalAge += c.getAge();
      totalFitness += c.calculateFitnessStandard();

      if (!c.getStatus()) {
        // updated Top 10, wenn Kreatur stirbt & in Top 10 war
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

    lookForMatingPartner();

    // Felder wachsen
    if (frameCount > 1) {
      growFields();
    } else {
      for (Field f : land) {
        f.influenceByWater();
      }
    }

    // wenn Population unter Minimalwert ist, dann werden neue Kreaturen hinzugefügt
    int populationZahl = population.size();
    if (populationZahl < minPopulationSize) {
      for (int i=0; i<minPopulationSize-populationZahl; i++) {
        int posX;
        int posY;
        do {
          posX = (int)random(0, map.worldBounds);
          posY = (int)random(0, map.worldBounds);
        } while (!this.getField(posX, posY).isLand());

        population.add(new Creature(posX, posY, this, currentID));
        currentID++;
      }
    }

    // Zeitrechnung
    year += timePerFrame;
    float neuesJahr = (float)(year * multiplier);
    year = (double)floor(neuesJahr) / multiplier;

    // Alter ältester Kreatur bestimmt 
    if ((year*100)%1 == 0) {
      double oldestCAge = 0;
      int oldestCID = 0; // 0 ist Dummywert
      for (Creature c : population) {
        if (c.getAge() > oldestCAge) {
          oldestCAge = c.getAge();
          oldestCID = c.getID();
        }
      }

      fitnessGPoints.add((float)year, totalFitness/population.size());
      oldestGPoints.add((float)year, population.size());
      averageAgeGPoints.add((float)year, (float)totalAge/population.size());
      generationGPoints.add((float)year, maxGeneration);

      if (year>removePointsFromThisTime) {
        fitnessGPoints.remove(0);
        averageAgeGPoints.remove(0);
        oldestGPoints.remove(0);
        generationGPoints.remove(0);

        plot.removePoint(0);
      }

      switch(selectedButton) {
      case FITNESS:
        plot.addPoint((float)year, totalFitness/population.size());
        break;
      case POPULATION:
        plot.addPoint((float)year, population.size());
        break;
      case AVGAGE:
        plot.addPoint((float)year, (float)totalAge/population.size());
        break;
      case GENERATION:
        plot.addPoint((float)year, maxGeneration);
        break;
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

  // Kreatur hinzufügen
  public void addCreature(Creature c) {
    population.add(c);
  }

  void flood() {
    floodOngoing = true;
    floodDuration = random(1, maxFloodDuration);
    floodHeight = random(5, 12);
    floodIncreasePerFrame = floodHeight/((floodDuration * 0.75)/(float)timePerFrame);
    floodDecreasePerFrame = floodHeight/((floodDuration * 0.25)/(float)timePerFrame);
    initialFloodDuration = floodDuration;
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

  // zeichnet die Welt
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
  // zeichnet ein Array aus Kreaturen (meistens am Anfang genutzt)
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

  void loadSelectedFolder() {
    selectFolder("Select file to load", "loadWorld");
  }

  //// Getter
  public Creature[] getCreatures() {
    return population.toArray(new Creature[population.size()]);
  }

  public Field getField(int x, int y) {
    float xField = (x - (x % fW)) / fW;
    float yField = (y - (y % fW)) / fW;
    if (xField >= worldSize) {
      xField = 0;
    }
    if (yField >= worldSize) {
      yField = 0;
    }
    return world[(int)xField][(int)yField];
  }

  public Field getFieldInArray(int x, int y) {
    try {
      if (x != -1 && x != worldSize && y != -1 && y != worldSize) { // um die ArrayIndexOutOfWoundsException zu umgehen, die normalerweise auftreten würde // try-catch Block ist trotzdem zur Sicherheit da
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