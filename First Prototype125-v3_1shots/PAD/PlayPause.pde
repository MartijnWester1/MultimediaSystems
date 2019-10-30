class PlayPause extends Checkbox {
  PlayPause(){ };//empty constructor
  
  PlayPause(float _x, float _y, boolean _isPlaying){
    super(_x, _y, _isPlaying);
  }
  void Render(){
    stroke(192);
    fill(IsOver()?128:64);
    
    if(IsChecked){//Draw cross
      rect(x, y, w, w);
    } else {
      triangle(x,y,x,y+w,x+w,y+w/2);
    }
  }
}
