
// fenstergroesse muss seperat geändert werden, sollte immer gleich sein & einen schönen Wert haben, z.B. 100, 500,...
final int fensterGroesse = 1000;
private int weltGroesse;

Welt map = new Welt(100, 10);

void setup(){
  size(1000,1000);
  map.showWelt();
  map.showLebewesen(map.getLebewesen());
  
}
void draw(){
  for(Lebewesen lw : map.getLebewesen()){
    lw.bewegen(20.0,18.0); // Ort dieser Methoden wird noch umgelagert && input kommt von NN
  }
  map.showWelt();
  map.showLebewesen();
}