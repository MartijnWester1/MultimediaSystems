class Slider extends Control {
  //FOR NOW ONLY WORKS FOR 0 AND POSITIVE NUMBERS
  float value;//Holds value
  float min, max;//Holds range of values
  float knobSize = 20.0f;
  float lowerY;
  float sliderY;
  boolean lock = false;
  String Label = ""; 
 
  Slider() { };//empty constructor
 
  Slider(float _x, float _y, float _w, float _h, float _value, float _min, float _max) {
    x=_x; y = _y; w=_w; h=_h;
    min = _min; max = _max;
    lowerY = y + h - knobSize;
    
    SetValue(_value);
    sliderY=_y+(h-knobSize)*((max-value)/(max-min));
  }
  
  public float GetValue() { return value; }  
  public void SetValue(float newVal) { 
    value = constrain(newVal, min, max); 
    sliderY = y+(1-value/(max-min))*(h-knobSize);
  }
 
  void Render() { 
    textSize(12);
    stroke(64);
    fill(32);
    rect(x, y, w, h);    
    float cvalue = map(sliderY, y, lowerY, 255, 64);// map value to change color..
 
    fill(color(0,cvalue/2,cvalue));//set color as it changes  
    rect(x+w/2-2, y, 4, h);// draw base line
    fill(lock||IsOver()?232:200);
    rect(x, sliderY, w, knobSize);// draw knob 
    fill(0);
    text(round(100*value) +"%", x+(value>=1?5:12), sliderY+knobSize/2+4);// display text
    if (Label != "") {
      textSize(28);
      fill(255);
      text(Label, x+11, y+h+28);// display text
    }
 
    //get mouseInput and map it
    if (lock) {
      float mouse_Y = constrain(mouseY, y, lowerY);
      sliderY = mouse_Y;
      float newValue = map(mouse_Y, y, lowerY, max, min);
      if (newValue != value) {
        value = newValue;
        OnChange();
      }
    }
  }
 
  boolean IsOver() {// is mouse over knob?
    return ((mouseX>=x)&&(mouseX<=x+w)&&(mouseY>=sliderY)&&(mouseY<=sliderY+knobSize));
  }
}
