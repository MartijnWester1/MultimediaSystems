class Checkbox extends Button {
  public boolean IsChecked;
  
  Checkbox(){ };//empty constructor
  
  Checkbox(float _x, float _y, boolean _isChecked){
    x = _x; y = _y;
    w = 20f;
    IsChecked = _isChecked;
  }
  void Render(){
    stroke(192);
    fill(IsOver()?128:64);
    rect(x, y, w, w);
    if(IsChecked){//Draw cross
      line(x, y, x+w, y+w);
      line(x, y+w, x+w, y);
    }
  }
  void Click(){
    if(IsOver()){
      IsChecked=!IsChecked;
    }
    OnChange();
  }
}
