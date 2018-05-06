class QuadTree {
  int maxPopulation = 5;
  ArrayList<Creature> treePop = new ArrayList<Creature>();
  boolean divided = false;
  QuadTree[] subTrees = new QuadTree[4];
  float posX, posY;
  float qWidth, qHeight;


  QuadTree(float x, float y, float w, float h) {
    posX = x;
    posY = y;
    qWidth = w;
    qHeight = h;
  }

  void addCreature(Creature c) {
    if (containsCreature(c)) {
      if (!divided && treePop.size() < maxPopulation) {
        treePop.add(c);
      } else {
        if (!divided) {
          divided = true;
          subTrees[0] = new QuadTree(posX, posY, qWidth/2, qHeight/2);
          subTrees[1] = new QuadTree(posX+qWidth/2, posY, qWidth/2, qHeight/2);
          subTrees[2] = new QuadTree(posX+qWidth/2, posY+qHeight/2, qWidth/2, qHeight/2);
          subTrees[3] = new QuadTree(posX, posY+qHeight/2, qWidth/2, qHeight/2);
          for (Creature cr : treePop) {
            for (QuadTree q : subTrees) {
              q.addCreature(cr);
            }
          }
          treePop.clear();
        }
        for (QuadTree q : subTrees) {
          q.addCreature(c);
        }
      }
    }
  }
  
  void removeCreature(Creature c){
    if(containsCreature(c)){
      if(divided){
        for (QuadTree q : subTrees) {
          q.removeCreature(c);
        }
      }else{
        treePop.remove(c);
      }
    }
  }
  
  void query(float x,float y,float r, ArrayList<Creature> creaturesInArea){
    if(!containsCircle(x,y,r)){
      return;
    } else {
      if(divided){
        for(QuadTree tree : subTrees){
          tree.query(x, y, r, creaturesInArea);
        }
      } else {
        for(Creature c : treePop){
          if(circleContainsCreature(x, y, r, c)){
            creaturesInArea.add(c);
            return;
          }
        }
      }
    }
  }
  
  boolean circleContainsCreature(float x, float y, float r, Creature c){
    return sqrt(sq(c.position.x - x) + sq(c.position.y - y)) <= r;
  }
  
  boolean containsCreature(Creature c) {
    return (posX < c.position.x && posX + qWidth > c.position.x && posY < c.position.y && posY + qHeight > c.position.y);
  }
  
  boolean containsCircle(float x,float y, float r){
    if(posX < x && posX+qWidth > x) return(posY+qHeight > y-r || posY < y+r);
    if(posY < y && posY+qHeight > y) return(posX+qWidth > x-r || posX < x+r);
    return(dist(x,y,posX,posY) < r || dist(x,y,posX+qWidth,posY) < r || dist(x,y,posX+qWidth,posY+qHeight) < r || dist(x,y,posX,posY+qHeight) < r);
  }
}
