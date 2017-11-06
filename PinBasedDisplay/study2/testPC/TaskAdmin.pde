import java.util.Collections;


class TaskAdmin {
  String participant_name;
  String participant_gender;
  String participant_age;
  
  String date = "02"+String.valueOf(day());

  int task_id;
  int task_num;
  
  int delta=250;

  
  Table data;
  
  int cells_width_num;
  int cells_height_num;
  int cells_width;
  int cells_height;
  int repetition;
  
  TaskAdmin() {
    //do nothing.
  }

  void setParams(int w_num, int h_num, int rep) {
    cells_width_num = w_num;
    cells_height_num = h_num;
    cells_width = 512/cells_width_num;
    cells_height = 512/cells_height_num;
    repetition = rep;
  }
  
  void initialize(String name, String gender, String age) {
    participant_name = name;
    participant_gender = gender;
    participant_age = age;
    
    data = new Table();
    task_id = 0;

    //initialize the csv file
    File f = new File(sketchPath("") + "data/" +  date + "_" + participant_name + "_" + participant_age  + "_data.csv");
    println(f.getAbsolutePath());
    
    if(!f.exists()) {
      //create table and assign column names
      data = new processing.data.Table();
      data.addColumn("id"); // task id
      data.addColumn("name");
      data.addColumn("age");
      data.addColumn("gender");
      data.addColumn("wrist_width");
      data.addColumn("physical_pin"); // pin size
      data.addColumn("haptic_x"); 
      data.addColumn("haptic_y");
      data.addColumn("visual_x"); 
      data.addColumn("visual_y"); 
      data.addColumn("dist");
      data.addColumn("trial_id");
      data.addColumn("expected_ans");
      data.addColumn("ans"); // estimated value

      saveTable(data, "data/" +  date + "_" + participant_name + "_" + participant_age  + "_data.csv");
    }
    
    //generate and save status
    f = new File(sketchPath("") + "data/" +  date + "_" + participant_name + "_" + participant_age  + "_status.txt");
    if(!f.exists()) {
      PrintWriter output = createWriter("data/" +  date + "_" + participant_name + "_" + participant_age  + "_status.txt");
      output.println(participant_name);
      output.println(participant_gender);
      output.println(participant_age);
      output.println(task_id);
      output.flush();
      output.close();
    }
  }
  
  void saveStatus() {
    saveTable(data, "data/" +  date + "_" + participant_name + "_" + participant_age  + "_data.csv");
    PrintWriter output = createWriter("data/" +  date + "_" + participant_name + "_" + participant_age  + "_status.txt");
    output.println(participant_name);
    output.println(participant_gender);
    output.println(participant_age);
    output.println(task_id);
    output.flush();
    output.close();
  }
  
  void restoreStatus() {
    data = loadTable("data/" +  date + "_" + participant_name + "_" + participant_age  + "_data.csv","header");
    String lines[] = loadStrings("data/" +  date + "_" + participant_name + "_" + participant_age  + "_status.txt");

    participant_name = lines[0];
    participant_gender = lines[1];
    participant_age = lines[2];
    task_id = Integer.parseInt(lines[3]);  
    //println(lines);
  }

  void update(singleTrial t) {
    //println("enter update:"+task_id);
    TableRow row = data.getRow(task_id);
    row.setInt("id",task_id);    
    row.setString("name",participant_name);
    row.setString("age",participant_age);
    row.setString("gender",participant_gender);
    row.setFloat("wrist_width",t.wrist);    
    row.setInt("physical_pin", t.pin_size-48);
    row.setInt("haptic_x",round(t.haptic_pos.x));
    row.setInt("haptic_y",round(t.haptic_pos.y));
    row.setInt("visual_x",round(t.visual_pos.x));
    row.setInt("visual_y",round(t.visual_pos.y));
    row.setInt("dist",t.dist);
    row.setInt("trial_id",t.trial_id);
    row.setInt("expected_ans", t.tar_id);
  }
  
  void updateAnswer(int i){
    //println("update answer is:"+i);
    //println("the row idx:"+(task_id-1));
    TableRow row = data.getRow(task_id-1);
    row.setInt("ans",i);
  }
  
  boolean goTo(int id) {
    if (task_id > 0 && task_id < (task_num - 1)) {
      task_id = id;
      return true;
    }
    else {
      return false;
    }
  } 
  
  boolean previous() {
    if(task_id > 0) {
      task_id--;
      return true;
    }
    else
      return false;
  } 

  boolean next() {
    if(task_id < task_num -1) {
      task_id++;
      return true;
    }
      return false;
  }
  
  boolean isEnded() {
    return task_id == (task_num-1);
  }
}