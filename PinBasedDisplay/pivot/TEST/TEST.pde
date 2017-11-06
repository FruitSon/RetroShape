import netP5.*;
import oscP5.*;

int cnt,id;
int cnt_temp;
PVector c;
int x,y;
int r_inside = (int)3.5*512/40;
int r_outside = 14*512/40;
Table record;
OscP5 osc;
NetAddress pcAddr;
void setup() {
  fullScreen();
  background(0);
  noStroke();

  frameRate(100);
  orientation(PORTRAIT);
  osc = new OscP5(this,12000);
  pcAddr = new NetAddress("10.0.1.24",12000);
  cnt = 0;
  id = 1;
  cnt_temp = 0;
  
  oneTrial();
  
  record = new Table();
  record.addColumn("#");
  record.addColumn("tar_x");
  record.addColumn("tar_y");
  record.addColumn("real_x");
  record.addColumn("real_y");
  record.addColumn("error_pixel");
  record.addColumn("error_mm");
}

void draw(){
  if(cnt<10){
  background(0);
  ellipseMode(CENTER);
  fill(255,0,0,120);
  ellipse(x,y,r_outside,r_outside);
  fill(255,255,255);
  ellipse(x,y,r_inside,r_inside);
  }else{
  background(120);
  text("exp terminate",width/2,height/2);
  }
}

void mousePressed(){
  int x_m = mouseX;
  int y_m = mouseY;
  if(mouseOver(x_m,y_m)){
    cnt_temp++;
    id++;
    addRecord(x_m,y_m);
    if(cnt_temp==10){
      cnt++;
      oneTrial();
    }
  }
}

void oneTrial(){
  c = new PVector((int)(random(512)+128),(int)(random(512)+384));
  x = (int)c.x;
  y = (int)c.y;
  cnt_temp = 0;
}

boolean mouseOver(int x_m, int y_m){
  if(abs(x_m-x)<r_inside&&abs(y_m-y)<r_inside){
    return true;
  }
  return false;
}

void addRecord(int x_m,int y_m){
  OscMessage sendback = new OscMessage("/NEW RECORD");
  sendback.setAddrPattern("1");
  sendback.add(new int[]{id, x_m, y_m});
  osc.send(sendback,pcAddr);
  println("++");
}