class Sensor{
  
  float distance;
  
  PVector position;
  PVector orientation;
  
  Creature c;
  
  Sensor(Creature creature){
    c = creature;
    distance = c.getDiameter()*1.25;
    orientation = new PVector(cos(c.velocity.heading())*distance,sin(c.velocity.heading())*distance);
    position = new PVector(0,0);
  }
  
  //updated und malt den Fühler
  public void drawSensor(){
    distance = c.getDiameter();
    // Fühlerposition wird erstellt
    position.set(c.position.x, c.position.y); // c.position.copy() funktioniert manchmal nicht // Position ausgehend von Kreaturenposition gesetzt
    orientation.setMag(c.getDiameter());
    position.add(orientation);
    
    // Fühler wird auf die gegenüberliegende Seite teleportiert, wenn er außerhalb der Map ist
    if (position.x > windowSize){ // wenn zu weit rechts        
      position.set(position.x-windowSize, position.y);
    }
    if (position.x < 0){ // wenn zu weit links       
      position.set(windowSize+position.x, position.y); // + position.x, weil es immer ein negativer Wert ist
    }
    if (position.y > windowSize){ // wenn zu weit unten
      position.set(position.x, position.y-windowSize);
    }
    if (position.y < 0){ // wenn zu weit oben
      position.set(position.x, windowSize+position.y); // + position.y, weil es immer ein negativer Wert ist
    }
    
    // Falls Fühler auf anderer Seite der Map sind, werden die Linien nicht mehr gemalt
    if(!(position.dist(c.getPosition()) > distance)){
      line(position.x, position.y, c.position.x, c.position.y);
    }
    // Körper
    ellipse(position.x, position.y, c.getDiameter()/4, c.getDiameter()/4);
  }
  
  public void rotateSensor(float angle){
    orientation.rotate(radians(angle));
  }
  
  ////getter
  
  // gibt die Energie vom Feld des Fühlers
  public float getSensorFieldEnergy(){
    Field field = map.getField((int)position.x, (int)position.y);
    return field.getEnergy();
  }
  
  // gibt, wenn Gegner vorhanden, dessen Energie aus
  public float getSensorEnemyEnergy(){
    Creature c = map.getCreature(position);
    if(c != null){
      return c.getEnergy();
    } else {
      return 0;
    }
  }
  
  public Creature getSensorPartner(){
    return map.getCreature(position);
  }
  
  public float getDirection(){
    return degrees(orientation.heading());
  }
  public float getSensorFieldType(){
    return map.getField((int)position.x, (int)position.y).isLandInt();
  }
  
}