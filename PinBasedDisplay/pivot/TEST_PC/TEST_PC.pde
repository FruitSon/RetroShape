import netP5.*;
import oscP5.*;

int cnt,id;
int cnt_temp;
int c = 5;
int r_inside = (int)3.5*512/40;
int r_outside = 14*512/40;
Table record;
OscP5 osc;
NetAddress pcAddr;

void setup() {
  size(100,100);
  background(0);
  noStroke();

  frameRate(100);
  osc = new OscP5(this,12000);
  
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
  background(c);
}

void OscEvent(OscMessage m){
  println(1);
  int id = m.get(0).intValue();
  int m_x = m.get(1).intValue();
  int m_y = m.get(2).intValue();
  int x = m.get(3).intValue();
  int y = m.get(4).intValue();
  float dist = dist(x,y,m_x,m_y);
  TableRow newRow = record.addRow();
  
  c = 255-c;
  newRow.setInt("id", id);
  newRow.setInt("tar_x", x);
  newRow.setInt("tar_y", y);
  newRow.setInt("real_x", m_x);
  newRow.setInt("real_y", m_y);
  newRow.setFloat("error_pixel", dist);
  newRow.setFloat("error_mm", dist/512*40);
  
  saveTable(record, "data/record.csv");
}