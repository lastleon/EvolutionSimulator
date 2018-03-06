class Matrix {
  int rows;
  int cols;
  float[][] m;

  Matrix(int r, int c) {
    rows = r;
    cols = c;
    m = new float[r][c];
    
  }

  void mult(Matrix m1,Matrix m2) {
    assert(m2.cols == m1.rows);
    for (int x = 0; x < m2.rows; x++) {
      for (int y = 0; y < m1.cols; y++) {
        set(x, y, mult(m2.getRow(x), m1.getCol(y)));
      }
    }
  }
  float mult(float[] i1, float[] i2) {
    float result = 0;
    for (int x = 0; x < i1.length; x++) {
      result += i1[x] * i2[x];
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
    for (int x = 0; x < rows; x++) {
      for (int y = 0; y < cols; y++) {
        m[x][y] = random(v1,v2);
      }
    }
  }
  
  void printMatrix(){
    print("[");
    for(int x=0; x<this.rows; x++){
      if(!(x==0)){
        print(" [");
      } else {
        print("[");
      }
      for(int y=0; y<this.cols; y++){
        print(" " + m[x][y] + " ");
      }
      if(!(x==this.rows-1)){
        println("]");
      } else {
        print("]");
      }
    }
    println("]");
  }
  
  void copyM(Matrix m2){
    for (int x = 0; x < rows; x++) {
      for (int y = 0; y < cols; y++) {
        m[x][y] = m2.m[x][y];
      }
    }
  }
  float[] getRow(int r) {
    return m[r];
  }
  float[] getCol(int c) {
    float[] result = new float[rows];
    for (int x=0; x<rows; x++) {
      result[x] = m[x][c];
    }
    return result;
  }

  void sigmoid() {
    for (int x = 0; x < rows; x++) {
      for (int y = 0; y < cols; y++) {
        m[x][y] = Activationfunction.sigmoid(m[x][y]);
      }
    }
  }
}