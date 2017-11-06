import netP5.*;
import oscP5.*;
OscP5 oscDisplay;
NetAddress PCAddr;
int X,Y,size;
PVector pos = new PVector(0,0);
int wrist_width = 50 * 512/40;

boolean start = false;
boolean terminated = false;
boolean lock = true;
boolean change_pin = false;
boolean response;
boolean showWristShadow = false;

void setup() {
  fullScreen();
  background(0);
  noStroke();
  frameRate(40);
  
  textAlign(CENTER);
  drawWatchface();
  
  //communication
  oscDisplay = new OscP5(this,20000);
  PCAddr = new NetAddress("10.0.1.24", 12000);

  orientation(PORTRAIT);    
}

void draw(){
  background(0);

  if(showWristShadow){
    fill(255,189,122);  
    rect(0,640+delta-wrist_width/2,width,wrist_width);
  }
  drawWatchface();

  if(terminated){
    background(120);
    fill(120);
    textSize(32);
    textAlign(CENTER);
    fill(255);
    text("the exp is terminated, thanks for your participation",0,height/2,width,100);
  }
  else if(start){
    fill(255);
    //text(X+","+Y,0, height/5,width,100);
    //text(key+" is pressed",0, height/5+50,width,100);
    //text("start:"+start+" lock:"+lock,0, height/5+100,width,100);

    fill(255);
    textSize(40);
    rect(pos.x-size/2,pos.y-size/2,size,size);
  }    
  fill(255);
  textSize(40);
  text(X+","+Y,0, height/5,width,100);
  text(key+" is pressed",0, height/5+50,width,100);
  text("start:"+start+" lock:"+lock+" changePin:"+change_pin,0, height/5+100,width,100);

}

int delta = 150;

void drawWatchface(){
  int r = 40;
  int d = 2*r;
  
  fill(90);
  rect(width/2-150,0,300,height*2);
  rect(width/2-300,height/2-300+delta,600,600,20);
 
  fill(0);
  rect(width/2-512/2,height/2-512/2+delta,512,512);
}

void keyPressed() {
  if((start && !lock) && ((key=='k'||key=='K') || (key=='j'||key=='J'))){
    if(key=='k'||key=='K') response = true;
    if(key=='j'||key=='J') response = false;
    int res = response?1:0;
    lock = true;
    size = 0;
    OscMessage result = new OscMessage("RESPONSE");
    result.setAddrPattern("100");
    result.add(new int[]{res});    
    oscDisplay.send(result,PCAddr);
  }  
  if(key=='s'||key=='S'){
    showWristShadow = true;
  }
  if(key=='h'||key=='H'){
    showWristShadow = false;
  }
}

void oscEvent(OscMessage theOscMessage) {
  String pattern = theOscMessage.addrPattern();


  
  if(pattern.equals("-1")){
    terminated = true;
  }

  if(pattern.equals("98")){
    println("pause exp");
    start = false;
  }
  else if(pattern.equals("99")){
    wrist_width = theOscMessage.get(0).intValue();
    println("wrist width received:"+wrist_width);
  
  }
  else if(pattern.equals("100")){
    size = theOscMessage.get(2).intValue();
    pos = new PVector(theOscMessage.get(0).intValue(),theOscMessage.get(1).intValue());
    lock = false;
    start = true;
  }
 
}