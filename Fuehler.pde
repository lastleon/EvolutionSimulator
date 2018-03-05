class Fuehler{
  
  private float abstand;
  
  private PVector position;
  private PVector ausrichtung;
  
  private Lebewesen lw;
  
  Fuehler(Lebewesen l){
    lw = l;
    abstand = lw.getDurchmesser()*1.25;
    ausrichtung = new PVector(cos(lw.geschwindigkeit.heading())*abstand,sin(lw.geschwindigkeit.heading())*abstand);
    position = new PVector(0,0);
  }
  
  //updated und malt den Fühler
  public void drawFuehler(){
    abstand = lw.getDurchmesser();
    // Fühlerposition wird erstellt
    position.set(lw.position.x, lw.position.y); //                               lw.position.copy() wurder manchmal null, keine Ahnung wieso
    ausrichtung.setMag(lw.getDurchmesser());
    position.add(ausrichtung);
    
    // Fuehler werden auf die gegenüberliegende Seite teleportiert, wenn sie außerhalb der Map sind
    if (position.x > fensterGroesse){ // wenn zu weit rechts        
      position.set(position.x-fensterGroesse, position.y);
    }
    if (position.x < 0){ // wenn zu weit links       
      position.set(fensterGroesse+position.x, position.y); // + position.x, weil es immer ein negativer Wert ist
    }
    if (position.y > fensterGroesse){ // wenn zu weit unten
      position.set(position.x, position.y-fensterGroesse);
    }
    if (position.y < 0){ // wenn zu weit oben
      position.set(position.x, fensterGroesse+position.y); // + position.y, weil es immer ein negativer Wert ist
    }
    
    // Falls Fuehler auf anderer Seite der Map sind, werden die Linien nicht mehr gemalt
    if(!(position.dist(lw.getPosition()) > abstand)){
      line(position.x, position.y, lw.position.x, lw.position.y);
    }
    
    ellipse(position.x, position.y, lw.getDurchmesser()/4, lw.getDurchmesser()/4);
  }
  
  public void fuehlerRotieren(float angle){
    ausrichtung.rotate(radians(angle));
  }
  
  ////getter
  
  //gibt die Energie vom feld des Fühlers
  public float getFuehlerFeldEnergie(){
    Feld feld = map.getFeld((int)position.x, (int)position.y);
    return feld.getEnergie();
  }
  
  //gibt,wenn Gegner vorhanden, dessen Energie aus // muss effizienter gemacht werden
  public float getFuehlerGegnerEnergie(){ /////////////   aus irgend einem Grund kann position null werden
    Lebewesen lw = map.getTier(position);
    if(lw != null){
      return lw.getEnergie();
    } else {
      return 0;
    }
  }
  
  public Lebewesen getFuehlerPartner(){
    return map.getTier(position);
  }
  
  public float getRichtung(){
    return degrees(ausrichtung.heading());
  }
  public float getFuehlerFeldArt(){
    return map.getFeld((int)position.x, (int)position.y).isLandInt();
  }
  
}