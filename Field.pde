class Field {

  final public static float maxOverallEnergy = 100;
  float posX, posY;
  float noiseHeight; //noise-Hoehe
  float regenerationrate;
  float energyValue = 0;
  float maxEnergyValue;
  float fieldWidth;
  float maxRegenerationrate = maxOverallEnergy/1000;
  float[] influencingValues;
  boolean influenceable;

  int arrayPosX;
  int arrayPosY;

  

  float oceanLevel = World.stdOceanLevel;

  Field(float x, float y, float h, float fW, int aX, int aY) {
    posX = x;
    posY = y;
    noiseHeight = h;
    fieldWidth = fW;
    arrayPosX = aX;
    arrayPosY = aY;
    influencingValues = new float[4];

    if (this.isLand()) {
      maxEnergyValue = maxOverallEnergy;
      influenceable = true;
    } else {
      maxRegenerationrate = 0;
      maxEnergyValue = 0;
      influenceable = false;
    }
  }

  public void grow() { // Das ist wahrscheinlich ein Performance-eatdes Monster, sollte man bei Gelegenheit optimieren // btw das ist sehr hässlich geschrieben
    if (influenceable && noiseHeight>oceanLevel) {
      float rest = maxRegenerationrate - regenerationrate;
      influencingValues = sort(influencingValues);
      for (int i = 3; i >= 0; i--) { 
        if (influencingValues[i] > random(0.5,0.8)) {
          regenerationrate += influencingValues[i] * rest;
        }
        rest = maxRegenerationrate - regenerationrate;
      }
    }
    
    regenerationrate *= World.stdOceanLevel+20/noiseHeight;
    if (regenerationrate>maxRegenerationrate)regenerationrate = maxRegenerationrate;
    
    energyValue += regenerationrate;
    if (energyValue > maxEnergyValue)energyValue = maxEnergyValue;
  }

  public boolean isLand() {
     return noiseHeight>oceanLevel;
  }
  public int isLandInt() {
    if (noiseHeight>oceanLevel) {
      return 1;
    } else return 0;
  }

  public void drawField() {
    if (noiseHeight>oceanLevel) {
      fill(map(energyValue, 0, maxEnergyValue, 255, 80), map(energyValue, 0, maxEnergyValue, 210, 140), 20); //muss noch geändert werden
    } else {
      fill(0, 0, map(noiseHeight, 0, oceanLevel, 0, 140));
      if(energyValue > 0){
        energyValue = 0;
      }
    }
    rect(posX, posY, fieldWidth, fieldWidth);
  }

  public void setEnergy(int x) {
    energyValue = x;
  }

  // getter(bisher)
  public float getEnergy() {
    return energyValue;
  }

  public float getMaxEnergy() {
    return maxEnergyValue;
  }

  public float getGrown() {
    return energyValue/maxOverallEnergy;
  }
  public void influenceByWater() {
    boolean water = false;
    if (arrayPosX > 0 && !water) water = !map.getFieldInArray(arrayPosX-1, arrayPosY).isLand();
    if (arrayPosY > 0 && !water) water = !map.getFieldInArray(arrayPosX, arrayPosY-1).isLand();
    if (arrayPosX < worldSize -1 && !water) water = !map.getFieldInArray(arrayPosX+1, arrayPosY).isLand();
    if (arrayPosY < worldSize -1 && !water) water = !map.getFieldInArray(arrayPosX, arrayPosY+1).isLand();
    if (water) {
      regenerationrate = maxRegenerationrate;
      influenceable = false;
    }
  }

  public void influenceNeighbours() {
    if (arrayPosX > 0) {
      Field f = map.getFieldInArray(arrayPosX-1, arrayPosY);
      if (f.influenceable) {
        f.influencingValues[0] = getGrown();
      }
    };
    if (arrayPosY > 0) {
      Field f = map.getFieldInArray(arrayPosX, arrayPosY-1);
      if (f.influenceable) {
        f.influencingValues[1] = getGrown();
      }
    };
    if (arrayPosX < worldSize -1) {
      Field f = map.getFieldInArray(arrayPosX+1, arrayPosY);
      if (f.influenceable) {
        f.influencingValues[2] = getGrown();
      }
    };
    if (arrayPosY < worldSize -1) {
      Field f = map.getFieldInArray(arrayPosX, arrayPosY+1);
      if (f.influenceable) {
        f.influencingValues[3] = getGrown();
      }
    };
  }
}