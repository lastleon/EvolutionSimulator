class Matrix {
  // Implementation von Matrizen
  
  int rows;
  int cols;
  float[][] m;

  Matrix(int r, int c) {
    rows = r;
    cols = c;
    m = new float[r][c];
    
  }
  


  void mult(Matrix m1, Matrix m2) {
    assert(m1.cols == m2.rows);
    for(int i=0; i<m1.rows; i++){
      for(int j=0; j<m2.cols; j++){
        this.set(i, j, mult(m1.getRow(i), m2.getCol(j)));
      }
    }
  }
  float mult(float[] i, float[] j) {
    float result = 0;
    for (int x = 0; x < i.length; x++) {
      result += i[x] * j[x];
    }
    return result;
  }

  float get(int r, int c) {
    return m[r][c];
  }
  void set(int r, int c, float v) {
    m[r][c] = v;
  }
  
  void set(float[][] v) {
    m = v;
  }
  
  void setRandom(float v1, float v2){
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        m[i][j] = random(v1,v2);
      }
    }
  }
  
  void printMatrix(){
    print("[");
    for(int i=0; i<this.rows; i++){
      if(!(i==0)){
        print(" [");
      } else {
        print("[");
      }
      for(int j=0; j<this.cols; j++){
        print(" " + m[i][j] + " ");
      }
      if(!(i==this.rows-1)){
        println("]");
      } else {
        print("]");
      }
    }
    println("]");
  }
  
  void copyM(Matrix m2){
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        m[i][j] = m2.m[i][j];
      }
    }
  }
  float[] getRow(int r) {
    return m[r];
  }
  float[] getCol(int j) {
    float[] result = new float[rows];
    for (int i=0; i<rows; i++) {
      result[i] = m[i][j];
    }
    return result;
  }

  void sigmoid() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        m[i][j] = Activationfunction.sigmoid(m[i][j]);
      }
    }
  }
  void tanh() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        m[i][j] = Activationfunction.tanh(m[i][j]);
      }
    }
  }
  

}