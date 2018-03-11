class Field {

  //// Positionswerte
  float posX;
  float posY;
  float fieldWidth;
  float noiseHeight;
  int arrayPosX;
  int arrayPosY;

  float oceanLevel = World.stdOceanLevel;

  //// Energie- & Wachstumswerte
  final public static float maxOverallEnergy = 300;
  float energyValue = 0;
  float maxEnergyValue;
  float regenerationrate;
  float maxRegenerationrate = maxOverallEnergy/600;
  float[] influencingValues;
  boolean influenceable;
  float influencingThreshold = 0.75;

  //                     h: noise Höhe, fW: Feldbreite, aX,aY: array Position
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

  // Wachstumsalgorithmus
  public void grow() {
    if (influenceable && noiseHeight>oceanLevel) {
      regenerationrate = 0;
      float rest = maxRegenerationrate;
      influencingValues = sort(influencingValues);
      for (int i = 3; i >= 0; i--) { 
        if (influencingValues[i] > random(0.5, 0.8)) {
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
      fill(map(energyValue, 0, maxEnergyValue, 255, 80), map(energyValue, 0, maxEnergyValue, 210, 140), 20);
    } else {
      fill(0, 0, map(noiseHeight, 0, oceanLevel, 0, 140));
      if (energyValue > 0) {
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

  // Wachstumsalgorithmus
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

  // Wachstumsalgorithmus
  public void influenceNeighbours() {
    if (arrayPosX > 0) {
      Field f = map.getFieldInArray(arrayPosX-1, arrayPosY);
      if (f.influenceable) {
        f.influencingValues[0] = getGrown();
      }
    }
    if (arrayPosY > 0) {
      Field f = map.getFieldInArray(arrayPosX, arrayPosY-1);
      if (f.influenceable) {
        f.influencingValues[1] = getGrown();
      }
    }
    if (arrayPosX < worldSize -1) {
      Field f = map.getFieldInArray(arrayPosX+1, arrayPosY);
      if (f.influenceable) {
        f.influencingValues[2] = getGrown();
      }
    }
    if (arrayPosY < worldSize -1) {
      Field f = map.getFieldInArray(arrayPosX, arrayPosY+1);
      if (f.influenceable) {
        f.influencingValues[3] = getGrown();
      }
    }
  }
  
    // save & load
  void saveField(String path, int fNr){
    File f = new File(path + "/Field" + fNr);
    f.mkdir();
    
    save(fieldWidth,2,f.getPath() + "/fieldWidth.dat");
    save(arrayPosX,0,f.getPath() + "/arrayPosX");
    save(arrayPosY,0,f.getPath() + "/arrayPosY");
    save(noiseHeight,4,f.getPath() + "/noiseHeight.dat");
    
    save(oceanLevel,4,f.getPath() + "/oceanLevel.dat");
    
    save(energyValue,4,f.getPath() + "/energyValue.dat");
    save(maxEnergyValue,3,f.getPath() + "/maxEnergyValue.dat");
    save(regenerationrate,4,f.getPath() + "/regenerationrate.dat");
    
    save(int(influenceable),0,f.getPath() + "/influenceable");
  }
  
  void loadField(String path, int fNr){
    String rPath = (path + "/Field" + fNr);

    fieldWidth = load(2,rPath + "/fieldWidth.dat");
    arrayPosX = (int)load(0,rPath + "/arrayPosX");
    arrayPosY = (int)load(0,rPath + "/arrayPosY");
    posX = arrayPosX*fieldWidth;
    posY = arrayPosY*fieldWidth;
    noiseHeight = load(4,rPath + "/noiseHeight.dat");
    
    oceanLevel = load(4,rPath + "/oceanLevel.dat");
    
    energyValue = load(4,rPath + "/energyValue.dat");
    maxEnergyValue = load(3,rPath + "/maxEnergyValue.dat");
    regenerationrate = load(4,rPath + "/regenerationrate.dat");
    
    influenceable = boolean((int)load(0,rPath + "/influenceable"));
}
  
}