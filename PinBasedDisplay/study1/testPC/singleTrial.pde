
class singleTrial{
  int pinSize;
  int pixelSize;
  PVector position;
  boolean response;
  boolean reverse;
  int wrist;
  char dir;
  
  
  singleTrial(int pinS, int pixelS, PVector p, char d, boolean res, int wrist_w){
    pinSize = pinS;
    pixelSize = pixelS;
    position = p;
    dir = d;
    response = res;
    wrist = wrist_w;
  }
}