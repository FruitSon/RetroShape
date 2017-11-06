import netP5.*;
import oscP5.*;
import controlP5.*;
import processing.serial.*;

import java.util.Collections;
import java.util.List;

//CONNECTION udp
//OscP5 oscPC;
//NetAddress PCAddr;
//NetAddress touchAddr;
//NetAddress displayAddr;

//CONNECTION tcp
OscP5 touch_client;
OscP5 display_client;

//CONNECTION STATUS 
boolean armConnected;
boolean touchConnected;
boolean displayConnected;

//EXP SETUP
int cols, rows, repeat;
int tolerance;
TaskAdmin data;

//GLOBAL VAR
Point tarPos, curPos;
float dist;
int delta = 150;

//STATUS
boolean isOverlap;
boolean endOneTrial;
boolean startExp;
boolean endExp;
boolean newExp;
boolean changePinCtl = false;
int cnt, tempCnt, calibrationCnt;
int trial_cnt;
singleTrial t;

//UI
ControlP5 info;
ControlP5 instruction;
ControlP5 inputPreInfo;
ControlP5 calibration;
ControlP5 expMode;
ControlP5 exp;
ControlP5 changePin;

Textfield name,age,gender,wrist_width,size_series;
Textfield pre_reverse_cnt, pre_dist, pre_correct_cnt, pre_status;

Textarea TF;  //the current transformation function
Textarea CP;
Textarea progress;  //the current progress

String[] subInfo;
char[] pinInfo;
int block;
boolean half_exp;
stairCase sc;


//float mmTOpixel = 512/40*1.0;
float mmTOpixel = 12.8;
//Arduino side
Serial port;

//calibration
float kx = 0.1, bx = -210, ky = 0.1, by= 90;

void setup(){
    size(500,500);
    background(120);
    frameRate(40);

    //oscPC = new OscP5(this,12000);
    //PCAddr = new NetAddress("10.0.1.24", 12000);
    ////set1
    //displayAddr = new NetAddress("10.0.1.23", 20000);
    //touchAddr = new NetAddress("10.0.1.21",16000);
    ////set2
    ////displayAddr = new NetAddress("10.0.1.30", 20000);
    ////touchAddr = new NetAddress("10.0.1.26",16000);

    display_client = new OscP5(this,"10.0.1.23",20000,OscP5.TCP);
    //display_client = new OscP5(this,"10.0.1.30",20000,OscP5.TCP);
    touch_client =  new OscP5(this,"10.0.1.21",16000,OscP5.TCP);
    
    //serial port
    String portName = Serial.list()[1];
    print(Serial.list()[1].toString());
    port = new Serial(this, portName, 115200);
    
    port.write("M1 65\n");

    checkConnection();
    sc = new stairCase();
 
    //UI
    int spacing = 60;
    int initialY = 150;
    int initialX = 90;
    PFont font = createFont("arial",14);
    
    info = new ControlP5(this);
    name = info.addTextfield("Name")
                         .setPosition(initialX,initialY)
                         .setSize(150,30)
                         .setFocus(true)
                         .setFont(font)
                         .setColor(color(222,222,222));
    age = info.addTextfield("Age")
                         .setPosition(initialX,initialY+spacing)
                         .setSize(150,30)
                         .setFocus(true)
                         .setFont(font)
                         .setColor(color(222,222,222));
    gender = info.addTextfield("Gender")
                         .setPosition(initialX,initialY+spacing*2)
                         .setSize(150,30)
                         .setFocus(true)
                         .setFont(font)
                         .setColor(color(222,222,222));
    wrist_width = info.addTextfield("Wrist Width")
                         .setPosition(initialX+170,initialY)
                         .setSize(150,30)
                         .setFocus(true)
                         .setFont(font)
                         .setColor(color(222,222,222));
    size_series = info.addTextfield("Size Series")
                         .setPosition(initialX+170,initialY+spacing)
                         .setSize(150,30)
                         .setFocus(true)
                         .setFont(font)
                         .setColor(color(222,222,222));
   
    info.addButton("next")
     .setPosition(width/2-160,3*height/4)
     .setSize(320,40)
     .setFont(font);

    instruction = new ControlP5(this);
    instruction.addTextarea("i1")
               .setPosition(width/4, height/4)
               .setSize(width/2,height/4)
               .setFont(font)
               .setText("Add instruction here later");
    //new exp
    instruction.addButton("understand")
     .setPosition(width/2-100,3*height/4)
     .setSize(200,40)
     .setFont(font);
    instruction.addButton("resumePrevious")
     .setPosition(width/2-100,3*height/4+100)
     .setSize(200,40)
     .setFont(font);
     
    //
    inputPreInfo = new ControlP5(this);
    inputPreInfo.hide();
    
    initialY -= 50;
    pre_reverse_cnt = inputPreInfo.addTextfield("Pre Reverse Cnt")
              .setPosition(width/2-75,initialY)
              .setSize(150,30)
              .setFocus(false)
              .setFont(font)
              .setColor(color(222,222,222));
 
    pre_dist = inputPreInfo.addTextfield("Pre Dist")
              .setPosition(width/2-75,initialY+spacing)
              .setSize(150,30)
              .setFocus(false)
              .setFont(font)
              .setColor(color(222,222,222));
    
    pre_correct_cnt = inputPreInfo.addTextfield("Pre Correct Cnt")
              .setPosition(width/2-75,initialY+spacing*2)
              .setSize(150,30)
              .setFocus(false)
              .setFont(font)
              .setColor(color(222,222,222));
    
    pre_status = inputPreInfo.addTextfield("Pre Status")
              .setPosition(width/2-75,initialY+spacing*3)
              .setSize(150,30)
              .setFocus(false)
              .setFont(font)
              .setColor(color(222,222,222));

    inputPreInfo.addButton("finishInput")
     .setPosition(width/2-100,3*height/4)
     .setSize(200,40)
     .setFont(font);
    
    // 
    calibration = new ControlP5(this);
    
    calibration.setVisible(false);
    TF = calibration.addTextarea("i2")
               .setPosition(width/6, height/4)
               .setSize(width*2/3,height/4)
               .setFont(font)
               .setText("System calibration. press the 'start' button below to start calibration. this process will take around 30 seconds. Press calibrationFinished to contine study when calibration finished.");
    
    CP = calibration.addTextarea("changePin")
               .setPosition(width/6, height/2)
               .setSize(width*2/3,height/4)
               .setFont(font);
    CP.hide();
               
    calibration.addButton("startCalibration")
     .setPosition(width/2-100,3*height/4-50)
     .setSize(200,40)
     .setFont(font)
     .addCallback(
       new CallbackListener(){
         public void controlEvent(CallbackEvent e){
           if(e.getAction()==ControlP5.ACTION_PRESSED){
             changePinCtl = false;
             initialCalibration();
           }
         }
       }
     );
    calibration.addButton("calibrationFinished")
     .setPosition(width/2-100,3*height/4)
     .setSize(200,40)
     .setFont(font);
     
    expMode = new ControlP5(this);
    expMode.addButton("startNewExp")
     .setPosition(width/2-100,3*height/4-50)
     .setSize(200,40)
     .setFont(font);
    expMode.addButton("continuePreviousExp")
     .setPosition(width/2-100,3*height/4)
     .setSize(200,40)
     .setFont(font);
     
    exp = new ControlP5(this);
    progress = exp.addTextarea("cntStatus")
     .setPosition(width/3, height/4)
     .setSize(width,height/4)
     .setFont(font);
     
    exp.addButton("forceStop")
     .setPosition(width/2-100,3*height/4-50)
     .setSize(200,40)
     .setFont(font);
     
    instruction.hide();
    calibration.hide();
    expMode.hide();
    exp.hide();
    
}

void draw(){
  textAlign(CENTER);
  background(120);
  if(endExp){
    textSize(40);
    text("Exp is finished",0,height/2,width,100);
    stop();
  }  
}

void initializeSetup(){
    data = new TaskAdmin();

    //data.setParams(c,r,re);
    cnt = 0;
    calibrationCnt = 0;
    tolerance = 256;
     
    isOverlap = false;
    endOneTrial = true;
    startExp = false;
    endExp = false;  
    newExp = true;
    block = 0;
    
    curPos = new Point();
    tarPos = new Point();
    
    armConnected = false;
    touchConnected = false;
    displayConnected = false;   
    
    println("initialize:"+block+" ,"+pinInfo[block]);
}

//button click
float wrist_width_mm;
int wrist_width_pixel;
int blank_width_half=0;

void next(){    
    subInfo = new String[] {name.getText(),age.getText(),gender.getText()};
    pinInfo = size_series.getText().toCharArray();
    wrist_width_mm = Float.parseFloat(wrist_width.getText());
    wrist_width_pixel = round(wrist_width_mm*mmTOpixel);
    
    if(round(wrist_width_pixel*2/3)<512){
      blank_width_half = round(wrist_width_pixel/6.0);
    }
    
    OscMessage updateWristWidth = new OscMessage("/UPDATE WRIST WIDTH");
    updateWristWidth.setAddrPattern("99");
    updateWristWidth.add(new int[]{wrist_width_pixel});
    display_client.send(updateWristWidth);
    initializeSetup();   
    
    info.setVisible(false);
    instruction.show();    
}

void understand(){  
  instruction.hide();
  calibration.show();
}

void resumePrevious(){
  instruction.hide();
  inputPreInfo.show();
}

int[] pre_info;
boolean is_recover = false;
void finishInput(){
  inputPreInfo.hide();
  calibration.show();
  pre_info = new int[] {Integer.parseInt(pre_reverse_cnt.getText()),Integer.parseInt(pre_dist.getText()),Integer.parseInt(pre_correct_cnt.getText()),Integer.parseInt(pre_status.getText())};
  println("reverse_cnt:"+pre_info[0]+" dist:"+pre_info[1]+" correct_cnt:"+pre_info[2]+" pre_status:"+pre_info[3]);
  is_recover = true;
}

void calibrationFinished(){
  calibration.hide();
  startExp = true;
  if(newExp){
    expMode.get("continuePreviousExp").hide();
    expMode.get("startNewExp").show();
  }
  if(!newExp){
    expMode.get("startNewExp").hide();
    expMode.get("continuePreviousExp").show();
  }
  
  expMode.show();
}

int standardSize = -1;
HashMap<Character,Integer> initialDist = new HashMap<Character,Integer>();
HashMap<Character,Integer> pinSizePixel = new HashMap<Character,Integer>();

void startNewExp(){
  
  if(block==0){
    data.initialize(subInfo[0],subInfo[2],subInfo[1]);
    pinSizePixel.put('1',round(2*mmTOpixel));
    pinSizePixel.put('2',round(6*mmTOpixel));
    pinSizePixel.put('3',round(10*mmTOpixel));
  }
  sc.initialize( 2, 2, delta, blank_width_half);
  sc.newBlock(pinInfo[block]-48);
  dist  = round(random(200,300));
  if(is_recover){
    dist = pre_info[1];
    sc.recover(pre_info[0],pre_info[1],pre_info[2],pre_info[3]);
  }
  
  sc.newTrial();
  
  standardSize = pinSizePixel.get(pinInfo[block]);
  
  lt = new PVector(standardSize/2,standardSize/2);
  rt = new PVector(512-standardSize/2,standardSize/2);
  lb = new PVector(standardSize/2,512-standardSize/2);
  rb = new PVector(512-standardSize/2,512-standardSize/2);

  println("block:"+pinInfo[block]+" varianceDist:"+dist);
  
  trial_cnt = 1;  
  tarPos = new Point((int)random(standardSize/2,512-standardSize/2)+128,(int)random(standardSize/2+blank_width_half,512-standardSize/2-blank_width_half)+384+delta,round(standardSize));
//  tarPos = new Point((int)random(standardSize/2,512-standardSize/2)+128,(int)random(standardSize/2+blank_width_half,512-standardSize/2-blank_width_half)+384+delta,standardSize);
  expMode.hide();
  exp.show();
  startExp = true;
  newExp = false;
  changePinPos();
  
}

void continuePreviousExp(){
  data.restoreStatus();
  cnt = data.task_id;
  startExp = true;
  expMode.hide();
  exp.show();
  tarPos = new Point(tarBuffer.posX,tarBuffer.posY,tarBuffer.size);
  changePinPos();
}

Point tarBuffer;
void forceStop(){
  data.saveStatus();
  tarBuffer = new Point(tarPos.posX,tarPos.posY,tarPos.size);
  pauseDisplay();
  
  port.write("M1 65/n");
  delay(10);
  resetPosition();
  delay(10);
  exp.hide();
  expMode.get("startNewExp").hide();
  startExp = false;
  TF.setText(TF.getText());
  calibration.show();
}


//helper method 
void checkConnection(){
}

Point pin1 = new Point(-280,30,-1);
Point pin2 = new Point(-280,40,-1);
Point pin3 = new Point(-270,40,-1);

Point screen1;
Point screen2;
Point screen3;

void initialCalibration(){
  delay(10);
  println("enter initialCalibration");
  startExp = false;
  calibrationCnt = 0;
  tarPos = new Point();
  String C1 = new String("G1 X"+pin1.posX+" Y"+pin1.posY+"\n");
  port.write(C1);
}

Point screenTOpin(Point p){
  int x = round(kx*p.posX + bx);
  int y = round(ky*p.posY + by);
  return new Point(x,y,-1);
}

void changePinPos(){
  //TODO: 100 SHOULD BE CHANGED TO THE INITIAL SIZE FOR VISUAL SQUARE
    updateCurScreenPos(1);
}

void resetPosition(){
  changePinCtl = true;
  updateCurScreenPos(3);
}

void pauseDisplay(){
  OscMessage pauseDisplay = new OscMessage("/PAUSE THE EXP");
  pauseDisplay.setAddrPattern("98");
  display_client.send(pauseDisplay);
}

void updateDisplay(Point tar, int size){
  OscMessage updateVisual = new OscMessage("/UPDATE DIST");
  updateVisual.setAddrPattern("100");
  updateVisual.add(new int[]{tar.posX, tar.posY, size});
  display_client.send(updateVisual);
}

void updateCurScreenPos(int mode){
  //i==0 calibration
  //i==1 modify
  //i==2 isOverLap
  //i==3 reset position
  String t = "1";
  switch(mode){
    case 0:
      if(calibrationCnt ==0) t = "10";
      if(calibrationCnt ==1) t = "11";
      if(calibrationCnt ==2) t = "12";
      break;
    case 1:
      t = "20";
      break;
    case 2:
      t = "30";
      break;
    case 3:
      t = "40";
      break;
    default:
      t = "1";
      break;
  }
  OscMessage updateScreenPos = new OscMessage(t);
  updateScreenPos.add(new int[] {tarPos.posX, tarPos.posY});

  touch_client.send(updateScreenPos);
}

//OSC event
PVector visualPos,hapticPos;
void oscEvent(OscMessage theOscMessage) { 
  //pattern = -1; no info about cur pin pos
  //pattern = 1; cur pin pos updated
  //pattern = 10/11/12; calibration
  //pattern = 20; modify
  //pattern = 30; isOverlap
  //pattern = 40; reset position
  //pattern = 100: participant's reaction sent back from display
  //pattern = 110: response
  //pattern = 120: rehit
  
  String pattern = theOscMessage.addrPattern().toString();
  int caseNum = Integer.parseInt(pattern);
  int x = -1,y=-1;
  if(!pattern.equals("100") && !pattern.equals("110") && !pattern.equals("120")){
    x = theOscMessage.get(0).intValue();
    y = theOscMessage.get(1).intValue();
    
    curPos.posX = x;
    curPos.posY = y;
    curPos.size = 0;
    //println("(ab)cur screen coordinate: X:"+curPos.posX+" Y:"+curPos.posY);
  }
  switch(caseNum){
    case 10:
      delay(1000);
      screen1 = new Point(x,y,-1);
      println("(ab)screen1:"+screen1.posX+" "+screen1.posY);
      break;
    case 11:
      delay(1000);
      screen2 = new Point(x,y,-1);
      println("(ab)screen2:"+screen2.posX+" "+screen2.posY);
      break;
    case 12:
      delay(1000);
      screen3 = new Point(x,y,-1);
      println("(ab)screen3:"+screen3.posX+" "+screen3.posY);
      kx = 10.0/(screen3.posX - screen1.posX);
      bx = pin1.posX - kx * screen1.posX;
      ky = 10.0/(screen3.posY - screen1.posY);
      by = pin3.posY - ky * screen3.posY;
      String functionX = new String("X: pinX="+kx+"*screenX+"+bx+"\n");
      String functionY = new String("Y: pinY="+ky+"*screenY+"+by+"\n");
      //show calibration on screen
      TF.setText("System calibration. press the 'start' button below to start calibration. this process will take around 30 seconds. Press calibrationFinished to contine study when calibration finished."+"\n"+functionX+functionY);
      break;
    case 20:
      Point realPinPos = screenTOpin(curPos);
      String calCmd = new String("G0 X"+realPinPos.posX+" Y"+realPinPos.posY+"\n");
      //println(calCmd);
      delay(10);
      port.write(calCmd); 
      break;
    case 30:
      //overlap
      boolean res = false;
      float dis2 = pow(curPos.posX-tarPos.posX,2)+pow(curPos.posY-tarPos.posY,2);
      //println("dis2:"+dis2);
      if(curPos.size!= -2 && dis2 <= tolerance) res = true;
      isOverlap = res;
      delay(10);
      if(!res){
          //print("not overlap");
          delay(1000);  
          changePinPos();
      }else{
          port.write("M1 85\n");
          if(!sc.isVariance()){
            visualPos = new PVector(curPos.posX,curPos.posY);
            hapticPos = visualPos;
            updateDisplay(curPos,round(standardSize));
            println("real dist:"+visualPos.dist(hapticPos));

          }
          else{
            hapticPos = new PVector(curPos.posX,curPos.posY);
            if(acceptHaptic(hapticPos)){      
              //println("hapticPos before:"+hapticPos.x+","+hapticPos.y);
              visualPos = sc.nextVisualPosition(hapticPos,dist);
              visualPos = new PVector(visualPos.x+128, visualPos.y+384+delta);
              println("real dist:"+visualPos.dist(hapticPos));
              updateDisplay(new Point(round(visualPos.x),round(visualPos.y),round(standardSize)),round(standardSize));  
  
          }else{
              println("aaaaabug here");
              PVector nextHaptic = sc.nextHapticPosition(hapticPos, dist);
              tarPos.posX = round(nextHaptic.x)+128;
              tarPos.posY = round(nextHaptic.y)+384+delta;
              delay(10);
              changePinPos();
            }
          }
          //println("overlap");
      }
      break;
     case 40:
      Point tempPos = screenTOpin(curPos);
      String initialCmd = new String("G0 X"+tempPos.posX+" Y"+tempPos.posY+"\n");
      //println("(XY)cal Cmd: "+calCmd);
      delay(10);
      port.write(initialCmd);
      delay(10);
      port.write("G28\n");
      break;
     case 100:                        
       port.write("M1 65\n");
       sc.updateHitCnt();
       //hapticPos = new PVector(tarPos.posX,tarPos.posY);
       //println("hapticPos:"+hapticPos.x+", "+hapticPos.y);
       //println("visualPos:"+visualPos.x+", "+visualPos.y);

       singleTrial t = new singleTrial(wrist_width_mm, standardSize, hapticPos, visualPos, trial_cnt, sc.tar_idx, dist, 0);
       data.update(t);       
       cnt++;
       data.task_id = cnt;
       data.saveStatus();      
        
       if(sc.endTrial()){
         OscMessage question = new OscMessage("/REQUEST USER TO REPORT THE INDEX OF THE DIFFERENT CONDITION");
         question.setAddrPattern("110");
         display_client.send(question);
       }else{
         PVector temp_pos = new PVector(curPos.posX, curPos.posY);
         PVector nextHaptic = sc.nextHapticPosition(hapticPos, dist);
         tarPos.posX = round(nextHaptic.x)+128;
         tarPos.posY = round(nextHaptic.y)+384+delta;
         changePinPos();
       }
       break;
    case 110:
      int ans = theOscMessage.get(0).intValue();      
      sc.checkAnswer(ans);
      sc.updateStatus();
      sc.isReverse();    
      data.updateAnswer(ans);
      data.saveStatus();
      if(sc.endBlock()){
        println(block);
        println(pinInfo.length);
        block++;
        if(block==pinInfo.length){
          println("ennnnnnnd");
           resetPosition();
           startExp=false;
           exp.hide();
         
           OscMessage endDisplay = new OscMessage("/END EXP");
           endDisplay.setAddrPattern("-1");
           display_client.send(endDisplay);
           endExp=true;
        }else{
          println("nextblock!");
          //sc.reset(typeInfo[block]);
         newExp = true;
         is_recover = false;
         exp.hide();
         CP.show();
         CP.setText("chage pin to " + pinInfo[block]);
         calibration.show();
         delay(10);
         resetPosition();
         delay(5000);
        }
      }else{
        dist = sc.nextDist(dist);
        println(">>nextDist:"+dist);
        sc.newTrial();
        PVector nextHaptic = sc.nextHapticPosition(hapticPos, dist);
        println("next haptic get");
        tarPos.posX = round(nextHaptic.x)+128;
        tarPos.posY = round(nextHaptic.y)+384+delta;
        trial_cnt++;
        changePinPos();      
      }
      
      break;
    case 120:
       println("rehit required");
       port.write("M1 65\n");
       delay(2000);
       port.write("M1 85\n");
       break;
    default: 
       println("no case matched!");
       break;
  }
}

PVector lt,rt,lb,rb;

boolean acceptHaptic(PVector pos){
  float possible_dist_max = max(max(pos.dist(lt),pos.dist(rt)),max(pos.dist(lb),pos.dist(rb)));
  return possible_dist_max>dist;
  
}

  

//Serial event
void serialEvent(Serial p) {
  String message = p.readStringUntil('\n');
  if(message!=null) {
    message = message.trim();
  }
  if(startExp){
    if(message!=null && message.equals("XY MODIFIED")){
      if(!changePinCtl){
      Point Ttar = screenTOpin(tarPos);
        String moveCmd = new String("G1 X"+Ttar.posX+" Y"+Ttar.posY+"\n");
        //println(moveCmd);
        port.write(moveCmd);
      }
    }
    if(message!=null&&message.equals("G1 EXECUTED")){
      //("stop! check if overlap");
        updateCurScreenPos(2);
    }
  }else{
    if(message!=null&&message.equals("G1 EXECUTED")){
      if(calibrationCnt==0){
        delay(3000);
        updateCurScreenPos(0);
        String C2 = new String("G1 X"+pin2.posX+" Y"+pin2.posY+"\n");
        port.write(C2);
        delay(10);
      }else if(calibrationCnt==1){
        delay(3000);
        updateCurScreenPos(0);
        String C3 = new String("G1 X"+pin3.posX+" Y"+pin3.posY+"\n");
        port.write(C3);
        delay(10);
      }else if(calibrationCnt==2){
        delay(3000);
        updateCurScreenPos(0);
        delay(10);
      }
      calibrationCnt++;
    }
  } 
}