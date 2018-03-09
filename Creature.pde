public class Creature {
  
  //// Bewegung
  // Position x & y
  PVector position;
  // Geschwindigkeit in x & y Richtung gespeichert
  PVector velocity;
  
  // Verbrauch Land & Wasser
  float movementConsumption = 3;
  float additionalMovementConsumptionInWater = 5;
  // Wasserreibung 
  float waterFriction = 0.1;
  
  //// Gene
  float eatingRate = World.stdEatingRate; // GEN
  float maxVelocity = World.stdMaxVelocity; //GEN
  float attackValue = World.stdAttackValue; // GEN
  float reproductionWaitingPeriod = World.stdReproductionWaitingPeriod; // GEN
  
  //// wichtige Werte für die Kreatur
  color furColour;
  float energy = 1400.0;
  // wird an Welt & Energielevel skaliert
  float diameter;
  boolean readyToGiveBirth = false;
  double age = 0;
  int generation;
  
  //// statische Werte
  final static float mutationRate = 0.2;
  final static float maxEnergy = 2500.0;
  final static float energyConsumption = 2;
  final static float birthEnergy = 800;
  final static float reproductionWill = 0.4;
  final static float reproductionThreshold = 0.5;
  final static float mixingThreshold = 0.3;
  public final static int maxMovementRotationAngle = 20; // Grad
  public final static int maxSensorRotationAngle = 10; // Grad
  
  //// Berechnungsvariablen
  float lastBirth = 0;
  boolean red = false;
  float redtime = 0;
  boolean inTop10 = false;
  int id;
  
  //// Neuronales Netzwerk
  NeuralNetwork NN;
  // Hiddenlayerwerte
  int hLAmount = 1;
  int hLLength = 8;
  
  float memory = 1;
  float fitness = 0;
  
  //// Fühler
  Sensor sensor;
   
   
   
  // sollte bei 1. Generation verwendet werden
  Creature(int x, int y, float fW, int ID) {
    
    id = ID;
    diameter = fW*1.25;
    
    generation = 1;

    NN = new NeuralNetwork(hLLength, hLAmount);

    velocity = new PVector(maxVelocity, maxVelocity);
    velocity.limit(maxVelocity);

    position = new PVector(x, y);
    
    sensor = new Sensor(this);
        
    furColour = color((int)random(0, 256), (int)random(0, 256), (int)random(0, 256));
  }

  // 2. Konstruktor, damit die Farbe bei den Nachkommen berücksichtigt werden kann und die Gewichte übergeben werden können
  //                                  Elternweights                         Elternfellfarben       g: Generation, f1, f2: Fressrate, mG1, mG2: maxGeschwindigkeit, r1, r2: Reproduktionswartezeit, a1, a2: Angriffswert
  Creature(int x, int y, Matrix[] weights1, Matrix[] weights2, color furColour1, color furColour2, int g, float f1, float mG1, float r1, float a1, float f2, float mG2, float r2, float a2, int ID) {
    
    id = ID;
    diameter = map.getFieldWidth()*1.25;
    
    // Gene der Eltern werden vermischt & mutiert
    eatingRate = mutate(mixGenes(f1, f2));
    maxVelocity = mutate(mixGenes(mG1, mG2));
    reproductionWaitingPeriod = mutate(mixGenes(r1, r2));
    attackValue = mutate(mixGenes(a1, a2));

    generation = g+1;

    // furColour wird random aus beiden Elternteilen gewählt
    if(random(0,1)>0.5){
      furColour = furColour1;
    } else {
      furColour = furColour2;
    }
    // Fellfarbe wird mutiert
    furColour = mutateFurColour(furColour);
    
    // Gewichtmatrizen der Eltern werden vermischt & mutiert
    NN = new NeuralNetwork(hLLength, mutate(mixMatrix(weights1,weights2)));

    velocity = new PVector(maxVelocity, maxVelocity);
    velocity.limit(maxVelocity);

    position = new PVector(x, y);
    
    sensor = new Sensor(this);
  }
  
  // Kreatur wird gemalt
  public void drawCreature() {
    // Durchmesser an Energielevel angepasst
    diameter = map.stdDiameter * energy/2000 + 5 ;
    
    // nach Angriff blinkt Kreatur 30 Frames rot
    if (redtime == 0) {
      fill(furColour);
    } else if (red) {
      fill(255, 0, 0);
      redtime--;
    } else {
      fill(furColour);
      redtime--;
    }
    if (redtime %4==0) {
      red = !red;
    }
    sensor.drawSensor();
    // Körper
    ellipse(position.x, position.y, diameter , diameter );
    // wenn in Top 10, dann werden Werte angezeigt
    if(inTop10){
      textSize(14);
      textAlign(CENTER);
      text("E: " + int(energy), position.x, position.y - 54);
      text("FR: " + eatingRate, position.x, position.y-43);
      text("V: " + maxVelocity, position.x, position.y-32);
      text("RW: " + reproductionWaitingPeriod, position.x, position.y-21);
      text("A: " + attackValue, position.x, position.y-10);
    }
  }
  
  void updateFitness(){
    fitness = this.calculateFitnessStandard();
    if(map.fitnessMaximum<fitness){
      map.fitnessMaximum = fitness;
    }
  }

  // NeuralNetwork input
  public void input() {
    // Werte werden auf -6 bis 6 gemappt, weil die Sigmoidfunktion so fast alle Werte zwischen 0 und 1 erreichen kann
    
    // Geschwindigkeit
    NN.setInputNVelocity(map(velocity.mag(), 0, maxVelocity, -6, 6));
    // eigene Energie
    NN.setInputNEnergy(map(energy, 0, maxEnergy, -6, 6));
    // Feldart
    NN.setInputNFieldType(map(map.getField((int)position.x, (int)position.y).isLandInt(), 0, 1, -6, 6));
    // Memory
    NN.setInputNMemory(map(memory, 0, 1, -6, 6));
    // Bias // immer 1
    NN.setInputNBias(1);
    // Richtung
    NN.setInputNDirection(map(degrees(velocity.heading()), -180, 180, -6, 6));
    // Paarungspartner/Gegner Fitness
    Creature c = sensor.getSensorPartner();
    if(c != null){
      NN.setInputNPartnerFitness(map(c.fitness/map.fitnessMaximum, 0, 1, -6, 6));
    } else {
      NN.setInputNPartnerFitness(-6);
    }

    //// Fühler
    
    // Gegnerenergie
    NN.setInputNSensorEnemyEnergy(map(sensor.getSensorEnemyEnergy(), 0, maxEnergy, -6, 6));
    // Feldenergie
    NN.setInputNSensorFieldEnergy(map(sensor.getSensorFieldEnergy(), 0, Field.maxOverallEnergy, -6, 6));
    // Feldart
    NN.setInputNSensorFieldType(map(sensor.getSensorFieldType(), 0, 1, -6, 6));
  }

  // Bewewgung
  public void move(float v, float angle) { // Rotationswinkel in Grad
    if (v<maxVelocity && v>=0) { // Bewegungsverbrauch passt sich an momentane Geschwindigkeit an
      energy -= movementConsumption*(v/World.stdMaxVelocity);
      velocity.rotate(radians(angle));
      this.sensor.rotateSensor(angle);
      velocity.setMag(v);

      // im Wasser bewegt sich die Kreatur langsamer und verbraucht mehr Energie
      if (!map.getField((int)position.x, (int)position.y).isLand()) {
        position.add(velocity.mult(1-waterFriction));
        energy -= additionalMovementConsumptionInWater;
      } else {
        position.add(velocity);
      }

      // Kreatur wird auf die gegenüberliegende Seite teleportiert, wenn sie außerhalb der Map ist
      if (position.x > windowSize) { // wenn zu weit rechts        
        position.set(position.x-windowSize, position.y);
      }
      if (position.x < 0) { // wenn zu weit links       
        position.set(windowSize+position.x, position.y); // + position.x, weil es immer ein negativer Wert ist
      }
      if (position.y > windowSize) { // wenn zu weit unten
        position.set(position.x, position.y-windowSize);
      }
      if (position.y < 0) { // wenn zu weit oben
        position.set(position.x, windowSize+position.y); // + position.y, weil es immer ein negativer Wert ist
      }
    }
  }
  // Angriff auf Gegner
  public void attack(float will) {
    if (will > 0.5) {
      addEnergy(-energyConsumption*(attackValue/World.stdAttackValue));
      // Opfer nur DIREKT vor dem Kreatur (d.h. in Geschwindigkeitsrichtung) kann angegriffen werden
      PVector victimPosition = new PVector(cos(velocity.heading())*(diameter/2)+position.x, sin(velocity.heading())*(diameter/2)+position.y);

      Creature victim = map.getCreature(victimPosition);
      // verhindert, dass Kreatur sich selbst angreift
      if(victim==this){
        victim = null;
      }

      if (!(victim == null)) {
        if (victim.getEnergy() >= attackValue) {
          victim.addEnergy(-attackValue);
          this.addEnergy(attackValue);
        } else {
          this.addEnergy(victim.getEnergy());
          victim.setEnergy(0);
        }
        if (energy>maxEnergy) { // Kreatur-Energie ist über dem Maximum
          energy = maxEnergy;
        }
        victim.hit();
      }
    }
  }

  // Grundverbrauch
  public void live() {
    energy -= energyConsumption*(age/100);
  }
  public void hit() {
    redtime = 30;
  }

  // Fitnessfunktion
  public float calculateFitnessStandard() { // berechnet die Fitness der Kreatur im Bezug auf die Standardwerte
    float bias = 0.1;
    float a = log((float)(age+1));
    float g = log((float)(generation))*1.5;
    float eatingRate = ((this.getEatingRate() - World.stdEatingRate)/World.stdEatingRate)*2;
    float maxV = ((this.getMaxVelocity() - World.stdMaxVelocity)/World.stdMaxVelocity)*2;
    float attack = ((this.getAttackValue() - World.stdAttackValue)/World.stdAttackValue)*2;
    float waitingPeriod = (World.stdReproductionWaitingPeriod/this.getReproductionWaitingPeriod() - 1)*2;
    float result = (bias + a + g + eatingRate + maxV + attack + waitingPeriod);
    if(result < 0){
      result = 0;
    }
    return result;
  }
  // Fressen
  public void eat(float will) {
    if (will > 0.5) {
      energy -= energyConsumption*(age/10);
      Field field = map.getField((int)position.x, (int)position.y);
      float newFieldEnergy = field.getEnergy() - eatingRate;

      if (newFieldEnergy>=0) { // Feld hat genug Energie
        energy += eatingRate;
        field.setEnergy((int)newFieldEnergy);
      } else { // Feld hat zu wenig Energie
        energy += field.getEnergy();
        field.setEnergy(0);
      }

      if (energy>maxEnergy) { // Kreatur-Energie ist über dem Maximum
        field.setEnergy((int)(field.getEnergy()+(energy-maxEnergy)));
        energy = maxEnergy;
      }
    }
  }

  public boolean collision(Creature c) {
    return map.creatureDistance(this, c) <= diameter;
  }
  
  public color mutateFurColour(color furColour) {

    float r = red(furColour) + red(furColour) * random(-0.3, 0.3);
    float g = green(furColour) + green(furColour) * random(-0.3, 0.3);
    float b = blue(furColour) + blue(furColour) * random(-0.3, 0.3);

    if (r < 0) {
      r = 0;
    } else if (r > 255) {
      r = 255;
    }
    if (g < 0) {
      g = 0;
    } else if (g > 255) {
      g = 255;
    }
    if (b < 0) {
      b = 0;
    } else if (b > 255) {
      b = 255;
    }
    return color(r, g, b);
  }
  

  // mutiert Gewichte
  public Matrix mutate(Matrix m) {
    for (int x=0; x<m.rows; x++) {
      for (int y=0; y<m.cols; y++) {
        if (random(0, 1)>0.3) {
          float newValue = mutate(m.get(x,y));
          if(newValue > 1){
            newValue = 1;
          }else if(newValue < 0){
            newValue = 0;
          }
          m.set(x,y,newValue);
        }
      }
    }
    return m;
  }
  // mutiert einzelnen Wert
  public float mutate(float x) { // x ist der Wert, der mutiert wird
    if (x > 0 && random(0, 1)>0.5) {
      x += random(-mutationRate, mutationRate)*((log(x)/log(10))+1);
    }
    if(x<0) x = 0;
    return x;
  }
  // mutiert ganze Matrix
  public Matrix[] mutate(Matrix[] m){
    Matrix[] returnMatrix = new Matrix[m.length];
    for(int i=0; i<m.length; i++){
      returnMatrix[i] = mutate(m[i]);
    }
    return returnMatrix;
  }
  // vermischt zwei Matrizen
  public Matrix mixMatrix(Matrix c1, Matrix c2) { // nimmt an, dass c1 und c2 gleich gross sind
    Matrix mixedMatrix = new Matrix(c1.rows,c1.cols);
    mixedMatrix.copyM(c1);
    // mixedMatrix wird zu Kopie von c1
    // Gewichte werden vermischt
    for (int x=0; x<c1.rows; x++) {
      for (int y=0; y<c1.cols; y++) {
        if (random(0, 1) > mixingThreshold) {
          mixedMatrix.set(x,y,c2.get(x,y));
        }
      }
    }
    return mixedMatrix;
  }
  
  // vermischt zweit Matrizen-Arrays
  public Matrix[] mixMatrix(Matrix[] m1, Matrix[] m2){
    Matrix[] returnMatrix = new Matrix[m1.length];
    for(int i=0; i<returnMatrix.length; i++){
      returnMatrix[i] = this.mixMatrix(m1[i], m2[i]);
    }
    return returnMatrix;
  }
  
  public float mixGenes(float g1, float g2) {
    if (random(0, 1)>reproductionThreshold) {
      return g1;
    } else return g2;
  }

  public void age() {
    age += map.getTimePerFrame();
    
    // Alter wird gerundet
    float newAge = (float)(age * map.getTimeMultiplier());
    age = (double)floor(newAge) / (double)map.getTimeMultiplier();

    // check, ob Kreatur geburtsbereit ist
    if (age - lastBirth >= reproductionWaitingPeriod) {
      readyToGiveBirth = true;
    } else {
      readyToGiveBirth = false;
    }
  }
  
  
  public void memorise(float m) {
    memory = m;
  }

  public void addEnergy(float e) {
    energy += e;
  }

  public void setEnergy(float e) {
    energy = e;
  }

  public void setLastBirth(float lB) {
    lastBirth = lB;
  }

  // getter 
  public boolean getStatus() {
    return energy>0;
  }
  public float getMaxVelocity() {
    return maxVelocity;
  }
  public float getEnergy() {
    return energy;
  }
  public float getMaxEnergy() {
    return maxEnergy;
  }
  public PVector getPosition() {
    return position;
  }
  public double getAge() {
    return age;
  }
  public boolean isReadyToGiveBirth() {
    return readyToGiveBirth;
  }
  public color getFurColour() {
    return furColour;
  }
  public float getDiameter() {
    return diameter;
  }
  public int getGeneration() {
    return generation;
  }
  public float getEatingRate() {
    return eatingRate;
  }
  public float getAttackValue() {
    return attackValue;
  }
  public float getReproductionWaitingPeriod() {
    return reproductionWaitingPeriod;
  }
  public int getID(){
    return id;
  }
}