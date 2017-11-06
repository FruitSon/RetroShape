class stairCase{
  //k-interval 1-up-n-down staircase
  //m step size, li reversals required for each step
  int interval_required, correct_required;
  int tar_idx, correct_cnt, hit_cnt;
  int reverse_cnt,reverse_required; //reverse cnt start from 0

  float[] steps,stepSeries; //a series of steps. eg. {10, 5}
  int[] numSteps; //reverse required for each step
  int curPinSize;
  int lower_y, higher_y;
  int blank_width_half, min_haptic_dist, max_dist;  
  int flag; //add or reduce
  
  PVector pre_pos,cur_pos;
  boolean pre_response, cur_response;
  boolean pre_status, cur_status;
  
  boolean startNew;
  
  int delta;
  
  PVector lt,rt,lb,rb;


  stairCase(){
  }
  
  void initialize(int m_interval_required, int m_correct_required, int d, int bwh){
    interval_required = m_interval_required;
    correct_required = m_correct_required;
    
    correct_cnt = 0;
    tar_idx = -1;
    hit_cnt = 0;
    
    delta = d;
    min_haptic_dist = 192; //15mm
    steps = new float[]{1,0.5,0.25};
    //numSteps = new int[]{2,1,1};
    numSteps = new int[]{5,5,5};
    
    reverse_required = 0;
    for(int i : numSteps){
      reverse_required += i;
    }
    
    stepSeries = new float[reverse_required];
    int temp_count = 0;
    for(int i = 0; i < numSteps.length; i++){
      for(int j = 0; j < numSteps[i]; j++){
        stepSeries[temp_count+j] = steps[i];
      }
      temp_count += numSteps[i];
    }
    
    blank_width_half = bwh;

    pre_pos = new PVector();
    cur_pos = new PVector();
   
  }
  
   
  void reset(){
  }
  
  //function called when enter a new block
  //start far away from the touch point, 1-up-1-down until reach the first reverse
  void newBlock(int pinInfo){
    curPinSize = -1;
    if(pinInfo == 1) curPinSize = round(2 * 12.8);
    else if(pinInfo == 2) curPinSize = round(6 * 12.8);
    else if(pinInfo == 3) curPinSize = round(10 * 12.8);
    //println("pinInfo:"+pinInfo+" curSize:"+curPinSize);
    
    lower_y = curPinSize/2+blank_width_half;
    higher_y = 512-(curPinSize/2+blank_width_half);
    max_dist = floor(sqrt(pow(512-curPinSize,2)+pow(512-curPinSize-blank_width_half,2)));

    lt = new PVector(curPinSize/2,curPinSize/2);
    rt = new PVector(512-curPinSize/2,curPinSize/2);
    lb = new PVector(curPinSize/2,512-curPinSize/2);
    rb = new PVector(512-curPinSize/2,512-curPinSize/2);

    println("max_dist:"+max_dist);
  
    reverse_cnt = 0;
    correct_cnt = 0;
    
    startNew = true;
  }

  void newTrial(){
    tar_idx = floor(random(0,interval_required)+1);
    hit_cnt = 0;
    if(!startNew && dist==0){tar_idx = -1;}
    println("____________________");
    println("tar_idx is "+tar_idx);
  }

  boolean endBlock(){
    return reverse_required == reverse_cnt;
  }
  
  boolean endTrial(){
   return hit_cnt==interval_required;
  }
  
  void updateHitCnt(){
    hit_cnt++;
  }

  float nextDist(float pre_dist){
    if(correct_cnt == correct_required){
      dist = pre_dist-curPinSize*stepSeries[reverse_cnt];
      //dist = pre_dist-77*stepSeries[reverse_cnt];

      correct_cnt = 0;
    }else if(ans_right && correct_cnt < correct_required){
      dist = pre_dist;
    }else{
      dist = pre_dist+curPinSize*stepSeries[reverse_cnt];
      //dist = pre_dist+77*stepSeries[reverse_cnt];
  
  }    
    
    if(dist<0){
      dist = 0;
    }
    else if(dist > max_dist){
      dist = max_dist;
    }
    return dist;
  }
  
  boolean isVariance(){
    return hit_cnt==tar_idx-1;
  }
  
  //return position range from 0-512
  
  PVector new_haptic= new PVector(-1, -1);
  PVector pre_new_haptic = new PVector(-1, -1);
  float x_nhp, y_nhp, y1, y2, temp;
  
  PVector nextHapticPosition(PVector cur, float dist){
    PVector curPosition = cur;
    x_nhp = curPosition.x-128;
    y_nhp = curPosition.y-delta-384;

    int new_x = 0, new_y = 0;
    new_x = round(random(512));
    
    if(abs(new_x-x_nhp)>min_haptic_dist) new_y = round(random(512));
    else{
      temp = sqrt(pow(min_haptic_dist,2)-pow(new_x-x_nhp,2));
      y1 = y_nhp - temp;
      y2 = y_nhp + temp;
      if(y1< lower_y && y2>higher_y){ 
        return nextHapticPosition(cur, dist);
      }
      else if(y1 > lower_y && y2 > higher_y){
        new_y = round(random(lower_y,y1));
      }
      else if(y1 < lower_y && y2 < higher_y){
        new_y = round(random(y2,higher_y));
      }
      else{
        int rand = floor(random(2));
        if(rand==0){
          new_y = round(random(lower_y,y1));
        }else{
          new_y = round(random(y2,higher_y));
        } 
      }
    }
    
    new_haptic.x = new_x;
    new_haptic.y = new_y;
    pre_new_haptic.x = new_x;
    pre_new_haptic.y = new_y;
    while(!insideWrist(new_haptic) || !distOK(new_haptic,dist)){
      //println("modify haptic pos");
      pre_new_haptic = new_haptic;
      new_haptic = modifyHapticPos(new_haptic);
      if(new_haptic.dist(pre_new_haptic)<5){
        break;
      }
    }
    //println("pos:"+new_haptic.x+", "+new_haptic.y);

    return new_haptic;
  }
  
  PVector modified_pos = new PVector(-1,-1);
  PVector modifyHapticPos(PVector pos){
    if(pos.x<256) modified_pos.x = random(curPinSize/2,pos.x);
    else modified_pos.x = random(pos.x,512-curPinSize/2);
    if(pos.y<256) modified_pos.y = random(lower_y,pos.y);
    else modified_pos.y = random(pos.y,higher_y);
    return modified_pos;
  }
  
  //return position range from 0-512
  PVector new_visual= new PVector(-1, -1);
  PVector pre_new_visual = new PVector(-1, -1);
  float x_nvp, y_nvp;
  
  PVector nextVisualPosition(PVector haptic_pos, float dist){
    //println("haptic_pos in nextVisualPos function:"+haptic_pos.x+","+haptic_pos.y+"dist:"+dist);
    
    new_visual.x = -1;
    new_visual.y = -1;
    if(dist<max_dist){
      //out of watch face
      x_nvp = haptic_pos.x-128;
      y_nvp = haptic_pos.y-delta-384;
      float th= -1;
      //while(!insideWatch(new_visual)){
      //  th = getTheta(haptic_pos);
      //  new_visual.x = x_nvp + dist * cos(th);
      //  new_visual.y = y_nvp + dist * sin(th);
      //}  
      th = getTheta(haptic_pos);
      float degree_th = degrees(th);
      new_visual.x = x_nvp + dist * cos(th);
      new_visual.y = y_nvp + dist * sin(th);
      int random_cnt = 0;
      println("before loop");
      while(!insideWatch(new_visual)){
        degree_th = degree_th+1;
        th = radians(degree_th);
        random_cnt++;
        new_visual.x = x_nvp + dist * cos(th);
        new_visual.y = y_nvp + dist * sin(th);
      } 
      println("after:"+random_cnt);

      //println("dist:"+dist+"th:"+th+" cos(th):"+cos(th)+" sin(th):"+sin(th));
      //println("deltaX:"+(dist * cos(th))+"deltaY:"+(dist * sin(th)));
      //println("new x:"+new_visual.x+"new y:"+new_visual.y);
      //println("dist is:"+new_visual.dist(new PVector(x_nvp,y_nvp)));
    }else{
      int q = getQuad(haptic_pos);
      //println("q:"+q);
      switch(q){
        case 1:
          new_visual.x = curPinSize/2;
          new_visual.y = 512-curPinSize/2;
        break;
        case 2:
          new_visual.x = 512-curPinSize/2;
          new_visual.y = 512-curPinSize/2;
        break;        
        case 3:
          new_visual.x = 512-curPinSize/2;
          new_visual.y = curPinSize/2;
        break;        
        case 4:
          new_visual.x = curPinSize/2;
          new_visual.y = curPinSize/2;
        break; 
        default:
        break;
      }
    }
    println("finish update");
    return new_visual;
  }
  
  int getQuad(PVector pos){
    int q = -1;
    if(pos.x<=256 && pos.y>256) q = 3;
    else if(pos.x<256 && pos.y<=256) q = 2;
    else if(pos.x>256 && pos.y>=256) q = 4;
    else if(pos.x>=256 && pos.y<256) q = 1;
    return q;
  }
  
  float getTheta(PVector pin_pos){
    float th = 0;
    if(pin_pos.x<=256 && pin_pos.y>256) th = random(3*HALF_PI,4*HALF_PI);
    else if(pin_pos.x<256 && pin_pos.y<=256) th = random(0,HALF_PI);
    else if(pin_pos.x>256 && pin_pos.y>=256) th = random(PI,3*HALF_PI);
    else if(pin_pos.x>=256 && pin_pos.y<256) th = random(HALF_PI,PI);
    return th;
  }
  
  //check visual pos
  boolean insideWatch(PVector pos){
    if(curPinSize/2<pos.x && pos.x< 512-curPinSize/2 
        && curPinSize/2<pos.y && pos.y< 512-curPinSize/2){
      return true;
    }
    return false;
  }
  
  //check haptic pos
  boolean insideWrist(PVector pos){
    if(curPinSize/2<pos.x && pos.x< 512-curPinSize/2 
        && lower_y<pos.y && pos.y< higher_y){
      return true;
    }
    return false;
  }
  
 
  boolean distOK(PVector pos, float dist){
    float possible_dist_max = max(max(pos.dist(lt),pos.dist(rt)),max(pos.dist(lb),pos.dist(rb)));
    return possible_dist_max>dist;
  }
  
  boolean ans_right =false;
  int trans_ans;
  boolean checkAnswer(int ans){
    ans_right = false;
    if(ans == 1) trans_ans = 2;
    else if(ans == 2) trans_ans = 1;
    
    if(trans_ans == tar_idx){
      ans_right = true;
      correct_cnt++;
    }else{
      correct_cnt = 0;
    }
    println("isCorrected:"+ans_right+" correct_cnt:"+correct_cnt);
    return ans_right;
  }
  
  void updateStatus(){
    pre_status = cur_status;
    //println("ans_right:"+ans_right);
    if(!ans_right){
      cur_status = false;
    }else{
      if(correct_cnt == correct_required){
        cur_status = true;
      }else if(correct_cnt < correct_required){
        cur_status = pre_status;
      }
    }
    //println("in updatestatus, pre_status:" + pre_status+" cur_status:"+cur_status+" reverse_cnt"+reverse_cnt);
  }
  
  void isReverse(){
    if(startNew){
      startNew = false;
      reverse_cnt  = 0;
      pre_status = ans_right;
      cur_status = ans_right;
    }
    else{
      //println("in isReverse function: pre_status:"+pre_status+" cur_status"+cur_status);
      if(pre_status != cur_status){
        reverse_cnt++;
      }
    }
    println("cur_status:"+cur_status+" reverse_cnt"+reverse_cnt);

  }
  
  void recover(int pre_reverse_cnt, int pre_dist, int pre_correct_cnt, int pre_status_recorded){
    reverse_cnt = pre_reverse_cnt;
    dist = pre_dist;
    correct_cnt = pre_correct_cnt;
    
    if(pre_status_recorded==0){
      cur_status = false;
    }
    else{
      cur_status = true;
    }
    startNew = false;
  }
  
}