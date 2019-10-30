class Button extends Control {
  String text;
  
  Button(){ };//empty constructor
  
  Button(float _x, float _y, float _w, float _h, String _text){
    x = _x; y = _y; w = _w; h = _h;
    text = _text;
  }  
  void Render(){
    fill(IsOver()?128:64);
    textSize(48);
    text(text, x+w/2-text.length()*19, y+h/2+5);
  }
  void Click(){
    if(IsOver()){
      selectInput("Select audio file (.wav or .mp3)", "AddAudioTrack");
    }
  } 
  
  boolean IsOver(){
    return((mouseX>=x)&&(mouseX<=x+w)&&(mouseY>=y)&&(mouseY<=y+w));
  }
}
