class Feld {

  
  final public static float maxEnergiewertAllgemein = 25;
  private float posX, posY;
  private float nHoehe; //noise-Hoehe
  private float regenerationsrate;
  private float energiewert = 0;
  private float maxEnergiewert;
  private float feldBreite;
  private float maxRegenerationsrate = maxEnergiewertAllgemein/1000;
  private float[] bewachsen;
  private boolean beeinflussbar;

  private int arrayPosX;
  private int arrayPosY;

  

  private float meeresspiegel = Welt.stdMeeresspiegel;

  Feld(float x, float y, float h, float fB, int aX, int aY) {
    posX = x;
    posY = y;
    nHoehe = h;
    feldBreite = fB;
    arrayPosX = aX;
    arrayPosY = aY;
    bewachsen = new float[4];

    if (this.isLand()) {
      maxEnergiewert = maxEnergiewertAllgemein;
      beeinflussbar = true;
    } else {
      maxRegenerationsrate = 0;
      maxEnergiewert = 0;
      beeinflussbar = false;
    }
  }

  public void wachsen() { // Das ist wahrscheinlich ein Performance-fressendes Monster, sollte man bei Gelegenheit optimieren // btw das ist sehr hässlich geschrieben
    /*
    energiewert += regenerationsrate;
     if (energiewert > maxEnergiewert){
     energiewert = maxEnergiewert;
     }
     */
    if (beeinflussbar && nHoehe>meeresspiegel) {
      float rest = maxRegenerationsrate - regenerationsrate;
      bewachsen = sort(bewachsen);
      for (int i = 3; i >= 0; i--) { 
        if (bewachsen[i] > random(0.5,0.8)) {
          regenerationsrate += bewachsen[i] * rest;
        }
        rest = maxRegenerationsrate - regenerationsrate;
      }
    }
    
    regenerationsrate *= Welt.stdMeeresspiegel+20/nHoehe;
    if (regenerationsrate>maxRegenerationsrate)regenerationsrate = maxRegenerationsrate;
    
    energiewert += regenerationsrate;
    if (energiewert > maxEnergiewert)energiewert = maxEnergiewert;
  }

  public boolean isLand() {
     return nHoehe>meeresspiegel;
  }
  public int isLandInt() {
    if (nHoehe>meeresspiegel) {
      return 1;
    } else return 0;
  }

  public void drawFeld() {
    if (nHoehe>meeresspiegel) {
      fill(map(energiewert, 0, maxEnergiewert, 255, 80), map(energiewert, 0, maxEnergiewert, 210, 140), 20); //muss noch geändert werden
    } else {
      fill(0, 0, map(nHoehe, 0, meeresspiegel, 0, 140));
      if(energiewert > 0){
        energiewert = 0;
      }
    }
    rect(posX, posY, feldBreite, feldBreite);
  }

  public void setEnergie(int x) {
    energiewert = x;
  }

  // getter(bisher)
  public float getEnergie() {
    return energiewert;
  }

  public float getMaxEnergie() {
    return maxEnergiewert;
  }

  public float getBewachsen() {
    return energiewert/maxEnergiewertAllgemein;
  }
  public void vonWasserBeeinflussen() {
    boolean wasser = false;
    if (arrayPosX > 0 && !wasser) wasser = !map.getFeldInArray(arrayPosX-1, arrayPosY).isLand();
    if (arrayPosY > 0 && !wasser) wasser = !map.getFeldInArray(arrayPosX, arrayPosY-1).isLand();
    if (arrayPosX < weltGroesse -1 && !wasser) wasser = !map.getFeldInArray(arrayPosX+1, arrayPosY).isLand();
    if (arrayPosY < weltGroesse -1 && !wasser) wasser = !map.getFeldInArray(arrayPosX, arrayPosY+1).isLand();
    if (wasser) {
      regenerationsrate = maxRegenerationsrate;
      beeinflussbar = false;
    }
  }

  public void nachbarnBeeinflussen() {
    if (arrayPosX > 0) {
      Feld f = map.getFeldInArray(arrayPosX-1, arrayPosY);
      if (f.beeinflussbar) {
        f.bewachsen[0] = getBewachsen();
      }
    };
    if (arrayPosY > 0) {
      Feld f = map.getFeldInArray(arrayPosX, arrayPosY-1);
      if (f.beeinflussbar) {
        f.bewachsen[1] = getBewachsen();
      }
    };
    if (arrayPosX < weltGroesse -1) {
      Feld f = map.getFeldInArray(arrayPosX+1, arrayPosY);
      if (f.beeinflussbar) {
        f.bewachsen[2] = getBewachsen();
      }
    };
    if (arrayPosY < weltGroesse -1) {
      Feld f = map.getFeldInArray(arrayPosX, arrayPosY+1);
      if (f.beeinflussbar) {
        f.bewachsen[3] = getBewachsen();
      }
    };
  }
}