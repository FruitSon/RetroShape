class stairCase{
  float[] steps; //a series of steps. eg. {10, 5}
  int[] numSteps; //reverse required for each step
  float[] stepSeries; //a series of the step for each reverse
  int curPinSize;
  
  char direction; //start from small or big visual size
  float minDist; //minimum distance(mm) between the position of two trials
  int minDist_Pixel;
  int blank_width_half;
  int flag; //add or reduce
  
  PVector pre_pos;
  PVector cur_pos;
  int pre_size;
  int cur_size;
  boolean pre_response;
  boolean cur_response;
  
  int reverseCnt,reverseRequired; //reverse cnt start from 0
  ArrayList<singleTrial> record; //save the presented 
  int delta;

  stairCase(){
  }
  
  void setParameters(int pinInfo, int bwh, int d, char dir){
    // trend = a: start from small size, flag = 1;
    // trend = d: start from big sime, flag = -1;
    curPinSize = -1;
    if(pinInfo == 1) curPinSize = round(2 * 12.8);
    else if(pinInfo == 2) curPinSize = round(6 * 12.8);
    else if(pinInfo == 3) curPinSize = round(10 * 12.8);
    //println("pinInfo:"+pinInfo+" curSize:"+curPinSize);
    direction = dir;
    blank_width_half = bwh;
    delta = d;
  }
  
  void initialize(){
    steps = new float[]{0.15,0.1,0.05};
    //numSteps = new int[]{2,1,1};
    numSteps = new int[]{5,5,5};
    
    reverseRequired = 0;
    for(int i : numSteps){
      reverseRequired += i;
    }
    stepSeries = new float[reverseRequired];
    int temp = 0;
    for(int i = 0; i < numSteps.length; i++){
      for(int j = 0; j < numSteps[i]; j++){
        stepSeries[temp+j] = steps[i];
      }
      temp += numSteps[i];
    }
    
    //flag = direction=='A'||direction=='a'?1:-1;
    minDist = 15;
    minDist_Pixel = (int)minDist * 512 / 40;
    
    pre_pos = new PVector();
    cur_pos = new PVector();
   
    cur_size = -1;
    pre_size = -1;
    
    reverseCnt = 0;
    record = new ArrayList<singleTrial>(); //save the presented 
  }
  
  int nextSize(int curSize){
    int newSize = curSize+(int)(flag*stepSeries[reverseCnt]*curPinSize);
    println("curPinsize:"+curPinSize+" newSize:"+newSize);
    if(newSize<0) newSize = 0;
    if(newSize>512) newSize =512;
    if((direction=='a'||direction=='A')&&(newSize>curPinSize)){
      newSize = curPinSize;
      reverseCnt ++;
    }
    if((direction=='d'||direction=='D')&&(newSize<curPinSize)){
      newSize = curPinSize;
      reverseCnt ++;
    }
    return newSize;
  }
  
  //return position range from 0-512
  PVector nextPosition(int size){
    PVector curPosition = cur_pos;

    float x = curPosition.x-128;
    float y = curPosition.y-delta-384;
    int new_x, new_y;
    new_x =(int)generateRandom(size/2,512-size/2);
        
    float delta2 = pow(minDist_Pixel,2)-pow(new_x-x,2);
    if(delta2<0){
      new_y = (int)generateRandom(size/2+blank_width_half,512-size/2-blank_width_half);
    }
    else{
      float deltaY = sqrt(delta2);
      int new_y_idx = 0;
      ArrayList<Integer> tempY = new ArrayList<Integer>();
     
      if(y-deltaY>=size/2+blank_width_half) tempY.add((int)generateRandom(size/2+blank_width_half,(int)(y-deltaY)));
      if(y+deltaY<=512-size/2-blank_width_half) tempY.add((int)generateRandom((int)(y+deltaY),512-size/2-blank_width_half));
      
      new_y = (int)max(min(y+deltaY,512-size/2-blank_width_half),max(y-deltaY,0));
      if(tempY.size()>1){
        new_y_idx = (int)random(0,2);
        new_y = tempY.get(new_y_idx);
      }
      else if(tempY.size()==1){
        new_y = tempY.get(0);
      }
    }
    if(new_y<0) new_y = abs(new_y);
    if(new_y>(512-size/2-blank_width_half)) new_y = 512-size/2-blank_width_half;
    //println("blank_width_half:"+blank_width_half+" pos:"+new_x+","+new_y);
    return new PVector(new_x,new_y);  
  }
  

  void addRecord(PVector pos, int size, boolean response){
    if(cur_size<0){
      cur_size = size;
      cur_pos = pos;
      cur_response = response;
    }else{
      pre_pos = cur_pos;
      cur_pos = pos;
      pre_size = cur_size;
      cur_size = size;
      pre_response = cur_response;
      cur_response = response;
    }
  }
  
  void reset(char d){
    cur_size = -1;
    reverseCnt = 0;
    
    minDist = 15;
    minDist_Pixel = (int)minDist * 512 / 40;
    
    pre_pos = new PVector();
    cur_pos = new PVector();
   
    cur_size = -1;
    pre_size = -1;    
  }
  
  float generateRandom(int a, int b){
    float s;
    if(a<b){
      s = random(a,b);
    }else s = random(b,a);
    return s;
  }
  
  boolean isReverse(boolean cur_response){
    if(pre_size!=-1){
      if(cur_response != pre_response){
        flag = -flag;
        reverseCnt ++;
      }
      println("reverseCnt:"+reverseCnt);
      return true;
    }else{
      //println("curCnt:"+curCnt+" curRes:"+record.get(curCnt).response);
      //println("reverseCnt:"+reverseCnt);
      if((direction=='a'||direction=='A')&& cur_response==true) flag = -1;
      else if((direction=='a'||direction=='A')&& cur_response==false) flag = 1;
      else if((direction=='d'||direction=='D')&& cur_response==true) flag = 1;
      else if((direction=='d'||direction=='D')&& cur_response==false) flag = -1;
    }
    return false;
  }
  
  boolean isEnded(){
    return !(reverseCnt != reverseRequired);
  }
}