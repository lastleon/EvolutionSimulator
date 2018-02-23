class Plot{
   FloatList xs;
   FloatList ys;
   float X;
   float Y;
   float posX;
   float posY;
   float W;
   float H;
   float pWidth;
   float pHeight;
   
   Plot(float x,float y,float w,float h){
     xs = new FloatList();
     ys = new FloatList();
     X = x;
     Y = y;
     W = w;
     H = h;
   }
   
   void show(){
     
     posX = map.weltX + X/skalierungsfaktor;
     posY = map.weltY + Y/skalierungsfaktor;
     
     pWidth = (W)/skalierungsfaktor;
     pHeight = (H)/skalierungsfaktor;
     
     fill(255,200);
     rect(posX,posY,pWidth,pHeight);
     stroke(0);
     strokeWeight(1/skalierungsfaktor);
     
     line(posX+1,posY,posX+1,posY+pHeight);
     line(posX+1,posY+pHeight-1,posX+pWidth,posY+pHeight-1);

     if(xs.size() > 1){
       noFill();
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