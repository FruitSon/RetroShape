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
      data.addColumn("x"); 
      data.addColumn("y"); 
      data.addColumn("physical_pin"); // pin size
      data.addColumn("visual_pin");
      data.addColumn("type"); // task type: ascending or descending
      data.addColumn("response"); // estimated value

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
    //println(task_id);
    TableRow row = data.getRow(task_id);
    row.setInt("id",task_id);    
    row.setString("name",participant_name);
    row.setString("age",participant_age);
    row.setString("gender",participant_gender);
    row.setInt("wrist_width",t.wrist);    
    row.setInt("x",(int)t.position.x);
    row.setInt("y",(int)t.position.y);
    row.setString("type",t.dir+"");
    row.setInt("physical_pin", t.pinSize-48);
    row.setInt("visual_pin", t.pixelSize);
    row.setInt("response", t.response?1:0);
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