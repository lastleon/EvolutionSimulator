
public class Creature {

  public final static int maxMovementRotationAngle = 20; /////////////////////////////// Version mit veraenderter Mutation
  public final static int maxSensorRotationAngle = 10;

  PVector velocity;
  PVector position;

  float mutationRate = 0.4;
  float diameter; // muss an World skaliert werden
  float eatingRate = World.stdEatingRate;
  float maxVelocity = World.stdMaxVelocity; //GEN
  float energy = 1400.0; // 500
  float maxEnergy = 4000.0; // 2000
  color furColour;
  float movementConsumption = 3;
  float movementConsumptionInWater = 5;
  float waterFriction = 0.1;
  float energyConsumption = 2;
  public final static float birthEnergy = 800;
  float reproductionWaitingPeriod = World.stdReproductionWaitingPeriod;
  float attackValue = World.stdAttackValue;
  public final static float reproductionWill = 0.4;
  boolean readyToGiveBirth = false;
  float lastBirth = 0;
  float reproductionThreshold = 0.5;
  float mixingThreshold = 0.3;
  boolean red = false;
  float redtime = 0;
  int generation;
  
  int hLAmount = 1;
  int hLLength = 8;
  
  int id;
  
  boolean inTop10 = false;
  
  float fitness = 0;

  double age = 0;

  Sensor sensor;

  NeuralNetwork NN;
  float memory = 1; // GEN


  // sollte bei 1. Generation verwendet werden
  Creature(int x, int y, float fW, int ID) {
    
    id = ID;
    diameter = fW*1.25;
    
    generation = 0;

    NN = new NeuralNetwork(hLLength, hLAmount);

    velocity = new PVector(maxVelocity, maxVelocity);
    velocity.limit(maxVelocity);

    position = new PVector(x, y);
    
    sensor = new Sensor(this);
        
    furColour = color((int)random(0, 256), (int)random(0, 256), (int)random(0, 256));
  }

  // 2. Konstruktor, damit die Farbe bei den Nachkommen berücksichtigt werden kann und die Gewichte übergeben werden können
  Creature(int x, int y, Matrix[] weights1, Matrix[] weights2, color furColour1, color furColour2, int g, float f1, float mG1, float r1, float a1, float f2, float mG2, float r2, float a2, int ID) {
    
    id = ID;
    diameter = map.getFieldWidth()*1.25;
    
    eatingRate = mutate(mixGenes(f1, f2));
    maxVelocity = mutate(mixGenes(mG1, mG2));
    reproductionWaitingPeriod = mutate(mixGenes(r1, r2));
    attackValue = mutate(mixGenes(a1, a2));

    generation = g+1;
    //energy = birthEnergy;

    // furColour wird random aus beiden Elternteilen gewaehlt
    if(random(0,1)>0.5){
      furColour = furColour1;
    } else {
      furColour = furColour2;
    }
    
    furColour = mutateFurColour(furColour);

    NN = new NeuralNetwork(hLLength, mutate(mixMatrix(weights1,weights2)));

    velocity = new PVector(maxVelocity, maxVelocity);
    velocity.limit(maxVelocity);

    position = new PVector(x, y);
    
    sensor = new Sensor(this);
  }

  public void drawCreature() {
    PVector direction = new PVector(velocity.x, velocity.y);
    diameter = map.stdDiameter * energy/4000 + 10 ;
    if(diameter<0) {
      diameter = 0;
    }
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
    direction.setMag(diameter/2);
    ellipse(position.x, position.y, diameter , diameter );
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
    // Geschwindigkeit
    NN.setInputNVelocity(map(velocity.mag(), 0, maxVelocity, -6, 6));
    // eigene Energy
    NN.setInputNEnergy(map(energy, 0, maxEnergy, -6, 6));
    // Fieldart
    //println("\n\ngetInputNFieldType");
    NN.setInputNFieldType(map(map.getField((int)position.x, (int)position.y).isLandInt(), 0, 1, -6, 6));
    // Memory
    NN.setInputNMemory(map(memory, 0, 1, -6, 6));
    // Bias // immer 1
    NN.setInputNBias(1);
    // Direction
    NN.setInputNDirection(map(degrees(velocity.heading()), -180, 180, -6, 6));
    // Mating Partner Fitness
    Creature partner = sensor.getSensorPartner();
    if(partner != null){
      //println(partner.calculateFitnessStandard() + " " + map.calculateFitnessMaximum());
      //println(partner.fitnessGPoints + " " + map.fitnessGPointsMaximum + " " + partner.fitnessGPoints/map.fitnessGPointsMaximum);
      //println(partner.fitnessGPoints/map.fitnessGPointsMaximum);
      NN.setInputNPartnerFitness(map(partner.fitness/map.fitnessMaximum, 0, 1, -6, 6));
    } else {
      NN.setInputNPartnerFitness(-6);
    }

    //// Sensor 
    
    // Enemyenergy
    //float[] gegnerEnergy1 = sensor1.getSensorEnemyEnergy();
    NN.setInputNSensorEnemyEnergy(map(sensor.getSensorEnemyEnergy(), 0, maxEnergy, -6, 6));// maxEnergy muss geändert werden, falls die maximale Energy von Creature zu Creature variieren kann
    // Fieldenergy
    //float[] fieldEnergy1 = sensor1.getSensorFieldEnergy();
    NN.setInputNSensorFieldEnergy(map(sensor.getSensorFieldEnergy(), 0, Field.maxOverallEnergy, -6, 6));
    // Fieldart
    NN.setInputNSensorFieldType(map(sensor.getSensorFieldType(), 0, 1, -6, 6));
  }

  // Bewewgung
  public void move(float v, float angle) { // redationswinkel in Grad
    if (v<maxVelocity && v>=0) { // Bewegungsverbrauch passt sich an momentane velocity an
      energy -= movementConsumption*(v/World.stdMaxVelocity);
      velocity.rotate(radians(angle));
      this.sensor.rotateSensor(angle);
      velocity.setMag(v);

      // im Wasser move sich die Creature langsamer und verbrauchen mehr Energy
      if (!map.getField((int)position.x, (int)position.y).isLand()) {
        position.add(velocity.mult(1-waterFriction));
        energy -= movementConsumptionInWater;
      } else {
        position.add(velocity);
      }

      // Creature werden auf die gegenüberliegende Seite teleportiert, wenn sie außerhalb der Map sind
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
  // Angriff auf Enemy
  public void attack(float will) {
    if (will > 0.5) {
      addEnergy(-energyConsumption*(attackValue/World.stdAttackValue));
      // Opfer nur DIREKT vor dem Creature (d.h. in Geschwindigkeitsdirection) kann angegriffen werden
      PVector victimPosition = new PVector(cos(velocity.heading())*(diameter/2)+position.x, sin(velocity.heading())*(diameter/2)+position.y);

      Creature victim = map.getCreature(victimPosition);
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
        if (energy>maxEnergy) { // Creature-Energy ist über dem Maximum
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

  // Fitnessfunktion // Fitness wird nur beim Rufen der Methode gerufen
  public float calculateFitnessStandard() { // berechnet die Fitness des Creaturees im Bezug auf die Standardwerte
    float bias = 0.1;
    float a = log((float)(age+1));
    float g = log((float)(generation+1))*1.5;
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

      if (newFieldEnergy>=0) { // Field hat genug Energy
        energy += eatingRate;
        field.setEnergy((int)newFieldEnergy);
      } else { // Field hat zu wenig Energy
        energy += field.getEnergy();
        field.setEnergy(0);
      }

      if (energy>maxEnergy) { // Creature-Energy ist über dem Maximum
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
          float multiplier = random(-mutationRate, mutationRate);
          float newValue = m.get(x,y)+multiplier*m.get(x,y);
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
  public float mutate(float x) { // x ist der Wert, der mutiert wird
    if (x > 0 && random(0, 1)>0.5) {
      x += random(-mutationRate, mutationRate)*x/4;
    }
    return x;
  }
  
  public Matrix[] mutate(Matrix[] m){
    Matrix[] returnMatrix = new Matrix[m.length];
    for(int i=0; i<m.length; i++){
      returnMatrix[i] = mutate(m[i]);
    }
    return returnMatrix;
  }

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
    float newAge = (float)(age * map.getTimeMultiplier());
    age = (double)floor(newAge) / (double)map.getTimeMultiplier();

    // readyToGiveBirth
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