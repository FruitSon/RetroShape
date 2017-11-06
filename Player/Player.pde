
import controlP5.*;
import processing.video.*;

ControlP5 ctr;
Button select_csv,select_mov,play,pause;

Movie mov;
int cur_frame, total_frame, frame_for_update;
Table data;
TableRow cur_row;
String csv_name, mov_name;
boolean mov_selected, csv_selected, mov_play;

int[] height_val;

void setup(){
  size(400,500);
  ctr = new ControlP5(this);
  select_csv = ctr.addButton("select_csv",1,width/2-150,450,145,20);
  select_mov = ctr.addButton("select_mov",2,width/2+5,450,145,20);

  play = ctr.addButton("play",3,width/2-150,420,145,20);
  pause = ctr.addButton("pause",4,width/2+5,420,145,20);
  
  cur_frame = 0;
  frame_for_update = 10;
  frameRate(10);
}

void draw(){
  if(mov_selected){
    image(mov, 0, 0,400,400); 
  }
}

void select_csv(){
  selectInput("Select a file to process:","CsvSelected");  
}

void select_mov(){
  selectInput("Select a file to process:","MovSelected");  
}
 
void play(){
  if(mov_selected && csv_selected){
    if(!mov_play){
      mov.play();
      mov_play = true;
    }
  }
}

void pause(){
  if(mov_selected && csv_selected){
    if(mov_play){
      mov.pause();
      mov_play = false;
    }
  }
}
 
void CsvSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("csv selected");
    csv_selected = true;
    String path = selection.getAbsolutePath();
    String[] split_path = path.split("/");
    csv_name= split_path[split_path.length-1];
    data = loadTable(csv_name,"header");
    checkFrameCnt();
  }
}

void MovSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("Movie selected");
    String[] split_path = selection.getAbsolutePath().split("/");
    mov_name= split_path[split_path.length-1];
    mov = new Movie(this, mov_name);
    mov.play();
    mov.pause();
    mov_play = false;
    mov_selected = true;
    checkFrameCnt();
  }
}

int csv_cnt,mov_cnt;
void movieEvent(Movie m) { 
  m.read(); 
  cur_frame++;
  if(cur_frame < min(csv_cnt,mov_cnt) && cur_frame%frame_for_update==0){
    println("updatePin");
    height_val= new int[16];
    cur_row = data.getRow(cur_frame);
    for(int i =0; i< 16; i++){
      //println(cur_row.getInt("cell"+i));
      height_val[i] = int(map(cur_row.getInt("cell"+i),0,256,0,140));
    }
    updatePin(height_val);
  }
  else{
    //mov.stop();
    if(csv_cnt*csv_cnt!=0 && !(cur_frame < min(csv_cnt,csv_cnt)))
    println("the ennnnnnnnnnd :)");
  }
} 

int offset;
void checkFrameCnt(){
  if(mov!=null && data!=null){
    mov_cnt = round(mov.duration()*10/10 * mov.frameRate);
    csv_cnt = data.getRowCount();
    println("movie frame cnt:"+mov_cnt+" csv frame cnt:"+csv_cnt);

    if(abs(mov_cnt-csv_cnt)<10) offset = mov_cnt-csv_cnt;
    else {
      println("not match! plz select the input again");
      mov_selected = false;
      csv_selected = false;
      data = null;
      mov = null;
    }
  }
}

void updatePin(int[] height_value){
}