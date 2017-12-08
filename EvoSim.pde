
// fenstergroesse muss seperat geändert werden, sollte immer gleich sein & einen schönen Wert haben, z.B. 100, 500,...
final int fensterGroesse = 1000;
private int weltGroesse;
  
Welt welt = new Welt(100, 10);

void setup(){
  size(1000,1000);
  welt.showWelt();
  welt.showLebewesen(welt.getLebewesen());
}
void draw(){
}