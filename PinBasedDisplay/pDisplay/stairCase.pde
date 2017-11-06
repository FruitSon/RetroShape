class stairCase{
  int[] steps; //a series of steps. eg. {10, 5}
  int[] numSteps; //reverse required for each step
  int[] stepSeries; //a series of the step for each reverse
  char direction; //start from small or big visual size
  float minDist; //minimum distance(mm) between the position of two trials
  int minDist_Pixel;
  int flag; //add or reduce
  
  int id;
  int curCnt,reverseCnt,reverseRequired; //reverse cnt start from 0
  ArrayList<singleTrial> record; //save the presented 
  
  stairCase(){
  }
  
  void setParameters(char trend){
    // trend = a: start from small size, flag = 1;
    // trend = d: start from big sime, flag = -1;
    direction = trend;
  }
  
  void initialize(){
    steps = new int[]{10,5};
    numSteps = new int[]{5,10};
    
    reverseRequired = 0;
    for(int i : numSteps){
      reverseRequired += i;
    }
    stepSeries = new int[reverseRequired];
    int temp = 0;
    for(int i = 0; i < numSteps.length; i++){
      for(int j = 0; j < numSteps[i]; j++){
        stepSeries[temp+j] = steps[i];
      }
      temp += numSteps[i];
    }
    
    flag = direction=='A'||direction=='a'?1:-1;
    minDist = 15;
    minDist_Pixel = (int)minDist * 512 / 40;
    
    id = 1;
    curCnt = 0;
    reverseCnt = 0;
    record = new ArrayList<singleTrial>(); //save the presented 
  }
  
  int nextSize(boolean curResponse, int curSize){
    int newSize = curSize;
    isReverse();
    return newSize+flag*stepSeries[reverseCnt];
  }
  
  //return position range from 0-512
  PVector nextPosition(int size){
    PVector curPosition = record.get(curCnt).position;
    float th = 0;
    float x = curPosition.x;
    float y = curPosition.y;
    PVector intersection = curPosition;
    int new_x, new_y;
      new_x =(int)generateRandom(size,512-size);
    float delta2 = pow(minDist,2)-pow(new_x-x,2);
    if(delta2<0){
      new_y = (int)generateRandom(size,512-size);
    }
    else{
      float deltaY = sqrt(delta2);
      int new_y_idx = 0;
      ArrayList<Integer> tempY = new ArrayList<Integer>();
      if(y-deltaY-size>0) tempY.add((int)generateRandom(size,(int)(y-deltaY)));
      if(y+deltaY+size<512) tempY.add((int)generateRandom((int)(y+deltaY),512-size));
      if(tempY.size()>1) new_y_idx = (int)random(0,2);
      tempY.add((int)max(min(y+deltaY,512-size),max(y-deltaY,0)));
      new_y = tempY.get(new_y_idx);
    }
    return new PVector(new_x,new_y);  
  }
  
  int getCurCnt(){
    return curCnt;
  }
  
  void addRecord(int size, PVector pos, boolean res){
    singleTrial newTrial = new singleTrial(size, pos, res);
    record.add(newTrial);
  }
  
  float generateRandom(int a, int b){
    float s;
    if(a<b){
      s = random(a,b);
    }else s = random(b,a);
    return s;
  }
  
  void isReverse(){
    if(curCnt>0){
      if(record.get(curCnt-1).response!=record.get(curCnt).response){
        flag = -flag;
        reverseCnt ++;
      }
      println("curCnt:"+curCnt+" curRes:"+record.get(curCnt).response+" preRes"+record.get(curCnt-1).response);
      println("reverseCnt:"+reverseCnt);
    }else{
      println("curCnt:"+curCnt+" curRes:"+record.get(curCnt).response);
      println("reverseCnt:"+reverseCnt);

    }
  }
  
  boolean isEnded(){
    return reverseCnt >= reverseRequired-1;
  }
}