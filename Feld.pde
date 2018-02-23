class Feld {

  private float posX, posY;
  private float nHoehe; //noise-Hoehe
  private float regenerationsrate;
  private float energiewert = 0;
  private float maxEnergiewert;
  private float feldBreite;
  private float maxRegenerationsrate = 1;

  private int arrayPosX;
  private int arrayPosY;

  final public static float maxEnergiewertAllgemein = 120;

  private int meeresspiegel = 45;

  Feld(float x, float y, float h, float fB, int aX, int aY) {
    posX = x;
    posY = y;
    nHoehe = h;
    feldBreite = fB;
    arrayPosX = aX;
    arrayPosY = aY;

    if (this.isLand()) {
      maxEnergiewert = maxEnergiewertAllgemein;
    } else {
      maxRegenerationsrate = 0;
      maxEnergiewert = 0;
    }
  }

  public void wachsen() { // Das ist wahrscheinlich ein Performance-fressendes Monster, sollte man bei Gelegenheit optimieren // btw das ist sehr hässlich geschrieben
    /*
    energiewert += regenerationsrate;
    if (energiewert > maxEnergiewert){
    energiewert = maxEnergiewert;
    }
    */
    boolean skip = false;

    ArrayList<Feld> bewachsen = new ArrayList<Feld>();

    Feld b = map.getFeldInArray(arrayPosX-1, arrayPosY);
    if (b != null) bewachsen.add(b);
    b = map.getFeldInArray(arrayPosX+1, arrayPosY);
    if (b != null) bewachsen.add(b);
    b = map.getFeldInArray(arrayPosX, arrayPosY+1);
    if (b != null) bewachsen.add(b);
    b = map.getFeldInArray(arrayPosX, arrayPosY-1);
    if (b != null) bewachsen.add(b);
    float rest;
    Feld[] bewachseneFelder = bewachsen.toArray(new Feld[bewachsen.size()]);
    for (Feld feld : bewachseneFelder) {
      if (!feld.isLand()) {
        regenerationsrate = maxRegenerationsrate;
        skip = true;
        break;
      }
    }
    if (!skip) {
      while (bewachsen.size() > 0) {
        rest = maxRegenerationsrate - regenerationsrate;

        bewachseneFelder = bewachsen.toArray(new Feld[bewachsen.size()]);
        float[] bewachsenArr = new float[bewachseneFelder.length];

        for (int i=0; i<bewachseneFelder.length; i++) {
          bewachsenArr[i] = bewachseneFelder[i].getBewachsen();
        }
        float temp = max(bewachsenArr);
        if(temp>random(0.5,0.8)) regenerationsrate += temp * rest;
        
        Feld feldToRemove = null;
        for(Feld feld : bewachsen){
          if(feld.getBewachsen() == max(bewachsenArr)) feldToRemove = feld; // mögliche Fehlerquelle
        }
        
        bewachsen.remove(feldToRemove);
      }
    }
    regenerationsrate *= meeresspiegel+20/nHoehe;
    if(regenerationsrate>maxRegenerationsrate)regenerationsrate = maxRegenerationsrate;
    energiewert += regenerationsrate;
    if (energiewert > maxEnergiewert){
    energiewert = maxEnergiewert;
    }
  }

  public boolean isLand() {
    if (nHoehe>meeresspiegel) {
      return true;
    } else return false;
  }
  public int isLandInt(){
    if (nHoehe>meeresspiegel){
      return 1;
    } else return 0;
  }

  public void drawFeld() {
    if (nHoehe>meeresspiegel) {
      fill(map(energiewert, 0, maxEnergiewert, 255, 80), map(energiewert, 0, maxEnergiewert, 210, 140), 20); //muss noch geändert werden
    } else fill(0, 0, map(nHoehe, 0, 45, 0, 140));
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
}