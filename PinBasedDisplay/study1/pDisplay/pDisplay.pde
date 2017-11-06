import netP5.*;
import oscP5.*;
OscP5 oscDisplay;
NetAddress PCAddr;
int X,Y,size;
PVector pos = new PVector(0,0);
int wrist_width = 50 * 512/40;

boolean start;
boolean ref;
boolean terminated;
boolean lock;
boolean change_pin;
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
  start = false;
  terminated = false;
  change_pin = false;
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
    ellipseMode(CENTER);
    ellipse(pos.x,pos.y,size,size);
    //rect(pos.x-size/2,pos.y-size/2,size,size);
  }   
  fill(255);
  textSize(40);

  if(ref){
    fill(255);
    textSize(60);
    text("Reference Stimulus",0, height/5,width,100);
    textSize(40);
    //text("'L'-finish feeling; Space-hit again",0, height/5+70,width,100);
  }else{
    textSize(40);
    //text("Please compare the current feeling with the reference feeling.",0, height/5-100,width,100); 
    textSize(60);
    text("Test Stimulus",0, height/5,width,100);
    textSize(40);
    //text("'J'-Different; 'K'-Same; 'Space'-hit again",0, height/5+70,width,100); 
  }
  fill(200);
  //text(key+" is pressed",0, height/5+120,width,100);
  //text("start:"+start+" lock:"+lock+" changePin:"+change_pin,0, height/5+100,width,100);

}

int delta = 150;

void drawWatchface(){
  int r = 40;
  int d = 2*r;
  
  fill(90);
  rect(width/2-150,0,300,height*2);
  rect(width/2-300,height/2-300+delta,600,600,20);
  //rect(width/2-150-r,height/2-300-r+delta,r,r);
  //rect(width/2+150,height/2-300-r+delta,r,r);
  //rect(width/2-150-r,height/2+300+delta,r,r);
  //rect(width/2+150,height/2+300+delta,r,r);
  //fill(0);
  //ellipse(width/2-150-r,height/2-300-r+delta,d,d);
  //ellipse(width/2+150+r,height/2-300-r+delta,d,d);
  //ellipse(width/2-150-r,height/2+300+r+delta,d,d);
  //ellipse(width/2+150+r,height/2+300+r+delta,d,d);
  
  fill(0);
  rect(width/2-512/2,height/2-512/2+delta,512,512);
}

void keyPressed() {
  if((start && !lock && !ref) && ((key=='k'||key=='K') || (key=='j'||key=='J'))){
    if(key=='k'||key=='K') response = true; //same
    if(key=='j'||key=='J') response = false;  //different
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
  if((start && !lock && ref && (key=='l'||key=='L'))){
    lock = true;
    size = 0;
    OscMessage endRef = new OscMessage("end Ref");
    endRef.setAddrPattern("110");
    oscDisplay.send(endRef,PCAddr);
  }
  
  
  if((start && !lock && key==' ')){
    OscMessage rehit = new OscMessage("rehit");
    rehit.setAddrPattern("120");
    oscDisplay.send(rehit,PCAddr);
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
    println("showStimuli");
    size = theOscMessage.get(2).intValue();
    pos = new PVector(theOscMessage.get(0).intValue(),theOscMessage.get(1).intValue());
    println("pos:"+pos.x+" ,"+pos.y+" size:"+size);
    lock = false;
    start = true;
    ref = false;
  }
  else if(pattern.equals("110")){
    println("showReference");    
    size = theOscMessage.get(2).intValue();
    pos = new PVector(theOscMessage.get(0).intValue(),theOscMessage.get(1).intValue());
    println("pos:"+pos.x+" ,"+pos.y+" size:"+size);
    lock = false;
    start = true;
    ref = true;
  }
 
}