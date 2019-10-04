class Inputbox extends Control {
  String text;
  String prevText;  
  boolean KeyState = false;  
  
  Inputbox(){ };//empty constructor
  
  Inputbox(float _x, float _y, float _w, float _h, String _text){
    x = _x; y = _y; w = _w; h = _h;
    text = _text;
  }  
  void Render(){
    textFont(createFont("Lucida Sans", 12));
    fill((KeyState ? color(128,128,255):color(64)));
    rect(x,y,w,h);
    fill(255);
    
    if (textWidth(text) > w-12) {
      int nChars = 8;
      while(textWidth(text.substring(0,nChars)) <= w-12)
        nChars++;
      text = text.substring(0, nChars-1)+"..";
    }
    text(text, x+6, y+15);// display name
  }
  void Click(){
    if(IsOver()){
      if (!KeyState) {
        prevText = text;
        text = "";
      }
      KeyState = !KeyState;
    }
  } 
  void KeyInput() {
    textFont(createFont("Lucida Sans", 12));
    if (KeyState)
      if (key==ENTER||key==RETURN||(textWidth(text) >= w-16))
        KeyState = false;
      else if ((keyCode>=40 && keyCode <=90) || (keyCode==32))
        text = text + key;
  }  
  
  void UndoSelect() {
    if (text=="")
      text = prevText;
    KeyState = false;
  }
  
  boolean IsOver(){
    return((mouseX>=x)&&(mouseX<=x+w)&&(mouseY>=y)&&(mouseY<=y+w));
  }
}
