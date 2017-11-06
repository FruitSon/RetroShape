class singleTrial{
  int pin_size;
  float th,wrist;
  int dist;
  PVector haptic_pos, visual_pos;
  int trial_id, tar_id, ans;
  
  singleTrial(float wrist_w, int pin_s, PVector h_pos, PVector v_pos, int trial_idx, int tar_idx, float m_dist, int answer){
    wrist = wrist_w;
    pin_size = pin_s;
    haptic_pos = h_pos;
    visual_pos = v_pos;
    trial_id = trial_idx;
    tar_id = tar_idx;
    ans = answer;
    dist = round(m_dist);
  }
}