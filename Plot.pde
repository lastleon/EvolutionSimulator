class Plot{
   FloatList xs;
   FloatList ys;
   float posX;
   float posY;
   float pWidth;
   float pHeight;
   
   Plot(float x,float y,float w,float h){
     xs = new FloatList();
     ys = new FloatList();
     posX = x;
     posY = y;
     pWidth = w;
     pHeight = h;
   }
   
   void show(){
     
     
     fill(255,200);
     rect(posX,posY,pWidth,pHeight);
     stroke(0);
     strokeWeight(2);
     
     line(posX+1,posY,posX+1,posY+pHeight);
     line(posX+1,posY+pHeight-1,posX+pWidth,posY+pHeight-1);

     if(xs.size() > 1){
       pushMatrix();
       translate(posX,posY+pHeight);
       float scaleX = pWidth/max(xs.array());
       float scaleY =pHeight/ max(ys.array());
       beginShape();
       for(int i = 0;i<xs.size();i++){
         vertex(xs.get(i)*scaleX,- ys.get(i)*scaleY); //<>//
       }
       endShape();
       popMatrix();
     }
     noStroke();
    }
   
   void addValues(float x,float y){
     xs.append(x);
     ys.append(y);
   }
}
