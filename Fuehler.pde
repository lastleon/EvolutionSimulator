class Fuehler{
  
  private PVector position;
  
  private int abstand = 15;
  private Lebewesen lw;
  
  Fuehler(Lebewesen l){
    position = new PVector(abstand,0);
    position.limit(abstand);
    lw = l;
  }
  
  //updated und malt den Fühler
  public void drawFuehler(){
    
    //println(degrees(position.heading()));
    
    // Fühlerposition wird erstellt
    position.x = lw.position.x + abstand*cos(position.heading());
    position.y = lw.position.y + abstand*sin(position.heading());
    
    
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
    
    ellipse(position.x, position.y, lw.durchmesser/2, lw.durchmesser/2);
  }
  
  public void fuehlerRotieren(float angle){
    position.rotate(radians(angle));
  }
  
  ////getter
  //gibt die Energie vom feld des Fühlers
  public float getFuehlerRichtung(){
    return degrees(position.heading());
  }
  
  public float getFuehlerFeldEnergie(){
    Feld feld = map.getFeld((int)position.x, (int)position.y);
    return feld.getEnergie();
  }
  
  //gibt,wenn Gegner vorhanden, dessen Energie aus // muss effizienter gemacht werden
  public float getFuehlerGegnerEnergie(){
    Lebewesen lw = map.getTier((int)position.x,(int)position.y);
    if(lw != null){
      return lw.getEnergie();
    } else {
      return 0;
    }
  }
  
  public float getFuehlerFeldArt(){
    return map.getFeld((int)position.x, (int)position.y).isLandInt();
  }
  
  public PVector getPosition(){
    return position;
  }
  
  
}