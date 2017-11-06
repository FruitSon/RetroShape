import netP5.*;
import oscP5.*;

OscP5 display_server;
int X,Y,size;
PVector pos = new PVector(0,0);
int wrist_width = 50 * 512/40;
int temp_cnt = 1 ;
boolean start, terminated, lock;
boolean ans, response;
boolean showWristShadow = false;

void setup() {
  fullScreen();
  background(0);
  noStroke();
  frameRate(40);
  
  textAlign(CENTER);
  drawWatchface();
  
  //communication
  //oscDisplay = new OscP5(this,20000);
  //PCAddr = new NetAddress("10.0.1.24", 12000);
  display_server =  new OscP5(this,20000,OscP5.TCP);
  start = false;
  terminated = false;
  orientation(PORTRAIT);    

}

void draw(){
  background(0);
  
  if(showWristShadow){
    fill(255,189,122);  
    rect(0,640+delta-wrist_width/2,width,wrist_width);
  }
  drawWatchface();

  fill(0);

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

  if(ans){
    fill(255);
    textSize(50);
    text("Which Stimulus is colocated?",0, height/5,width,100);
  }else{
    textSize(40);
    //text("Please compare the current feeling with the reference feeling.",0, height/5-100,width,100); 
    textSize(60);
    text("Stimulus "+(temp_cnt%2+1),0, height/5,width,100);
    textSize(40);
    //text("'Space'-hit again",0, height/5+70,width,100); 
  }
  fill(200);
  //text(key+" is pressed",0, height/5+120,width,100);
  //text("start:"+start+" lock:"+lock+" changePin:"+change_pin,0, height/5+100,width,100);

}

int delta = 150;

void drawWatchface(){
  int r = 40;  
  fill(90);
  rect(width/2-150,0,300,height*2);
  rect(width/2-300,height/2-300+delta,600,600,20);
  
  fill(0);
  rect(width/2-512/2,height/2-512/2+delta,512,512);
}
int res=0;
void keyPressed() {
  if(start && !lock && ans && key!='L' && key!='l'){
    if(key=='j' || key=='J' ||key =='k' || key == 'K' ){
      
      if(key=='j' || key=='J'){
        res = 1;
        temp_cnt = 1;
      }
      else if(key =='k' || key == 'K' ){
        res =2;
        temp_cnt = 1;
      }
      lock = true;
      size = 0;
      OscMessage result = new OscMessage("/RESPONSE");
      result.setAddrPattern("110");
      result.add(new int[]{res});
      display_server.send(result,display_server.tcpServer().getClients()[0]);
    }
  }  
  if(key=='s'||key=='S'){
    showWristShadow = true;
  }
  if(key=='h'||key=='H'){
    showWristShadow = false;
  }
  
  if((start && !lock && !ans && (key=='l'||key=='L'))){
    lock = true;
    size = 0;
    if(temp_cnt!=2){
      temp_cnt++;
    }
    OscMessage endRef = new OscMessage("100");
    display_server.send(endRef);
  }
  
  
  if((start && !lock && key==' ')){
    OscMessage rehit = new OscMessage("120");
    display_server.send(rehit);
  }
}

void oscEvent(OscMessage theOscMessage) {
  String pattern = theOscMessage.addrPattern();
  println("m received:"+pattern);
  
  if(pattern.equals("-1")){
    terminated = true;
  }

  if(pattern.equals("98")){
    println("pause exp");
    start = false;
    temp_cnt--;
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
    ans = false;
    temp_cnt++;
  }
  else if(pattern.equals("110")){
    lock = false;
    start = true;
    ans = true;
  }
 
}