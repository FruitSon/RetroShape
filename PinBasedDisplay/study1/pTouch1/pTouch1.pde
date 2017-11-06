import netP5.*;
import oscP5.*;
OscP5 oscTouch;
NetAddress PCAddr;
boolean touched;
int tarX = 0;
int tarY = 0;

int p1x=0, p1y=0, p2x=0, p2y=0, p3x=0, p3y=0;


void setup() {
  fullScreen();
  background(0);
  noStroke();

  frameRate(100);

  //communication
  oscTouch = new OscP5(this,16000);
  PCAddr = new NetAddress("10.0.1.24", 12000);
  touched = false;
  orientation(PORTRAIT);
}

void draw(){
  background(0);
  drawWatchface();

  fill(255);
  textSize(40);
  textAlign(CENTER);
  text("curPos:("+mouseX+","+mouseY+")",0, height/5,width,100);
  
  //CUR TOUCH POINT
  fill(color(255,0,0));
  rect(width-tarX-5,tarY-5,10,10);
  if(mouseX>=width/2-512/2+5 && mouseX<=width/2+512/2-10-5
      && mouseY>=height/2-512/2+5+delta && mouseY<=height/2+512/2-5+delta){
    fill(255);
    rect(mouseX-5,mouseY-5,10,10);
  }
  fill(color(255,0,0));
  if(p1x*p1y!=0){
    rect(p1x-5,p1y-5,10,10);
  }
  if(p2x*p2y!=0){
    rect(p2x-5,p2y-5,10,10);
  }
  if(p3x*p3y!=0){
      rect(p3x-5,p3y-5,10,10);
  }
}

int delta = 150;

void drawWatchface(){
  int r = 40;
  int d = 2*r;
  
  fill(90);
  rect(width/2-150,0,300,height*2);
  rect(width/2-300,height/2-300+delta,600,600,20);
  rect(width/2-150-r,height/2-300-r+delta,r,r);
  rect(width/2+150,height/2-300-r+delta,r,r);
  rect(width/2-150-r,height/2+300+delta,r,r);
  rect(width/2+150,height/2+300+delta,r,r);
  fill(0);
  ellipse(width/2-150-r,height/2-300-r+delta,d,d);
  ellipse(width/2+150+r,height/2-300-r+delta,d,d);
  ellipse(width/2-150-r,height/2+300+r+delta,d,d);
  ellipse(width/2+150+r,height/2+300+r+delta,d,d);
  
  fill(120);
  rect(width/2-512/2,height/2-512/2+delta,512,512);
}

void oscEvent(OscMessage theOscMessage) {
  String pattern = theOscMessage.addrPattern().toString();
  tarX = theOscMessage.get(0).intValue();
  tarY = theOscMessage.get(1).intValue();
  
  OscMessage rep = new OscMessage("/REPLY FROM TOUCH");
  
  rep.setAddrPattern(pattern);
  if(pattern.equals("10")){p1x=mouseX;p1y=mouseY;}
  else if(pattern.equals("11")){p2x=mouseX;p2y = mouseY;}
  else if(pattern.equals("12")){p3x=mouseX;p3y = mouseY;}
  
  //println("received pattern:"+pattern);
  //println("the cur touch pos: X-"+mouseX+" Y-"+mouseY);
  
  rep.add(new int[] {width-mouseX, mouseY});
  oscTouch.send(rep,PCAddr);
}