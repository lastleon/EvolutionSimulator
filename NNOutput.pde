class NNOutput{
  int[] deviation = new int[10000];
  
  NNOutput(){
    deviation = new int[10000];
  }
  
  void addValue(int i){
    deviation[i]++;
  }
}