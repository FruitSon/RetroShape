class Point{
  int posX;
  int posY;
  int size;
  
  Point(){
    posX = -1;
    posY = -1;
    size = -1;
  }
  Point(int X, int Y, int S){
    posX = X;
    posY = Y;
    size = S;
  }
  
  void displayVS(Point p, int newsize){
    p.size = newsize;
    stroke(0);
    fill(0);
    rect(p.posX,p.posY,p.size,p.size);
  }
  
  boolean isEmpty(){
    return size!=-1;
  }
}