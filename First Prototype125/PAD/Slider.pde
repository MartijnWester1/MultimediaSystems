class Slider extends Control {
  //FOR NOW ONLY WORKS FOR 0 AND POSITIVE NUMBERS
  float value;//Holds value
  float min, max;//Holds range of values
  float knobSize = 20.0f;
  float lowerY;
  float sliderY;
  boolean lock = false;
  boolean disabled = false;
 
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
    sliderY = h-newVal/(max-min)*(h-knobSize);
  }
 
  void Render() {
    if (!disabled){  
      textFont(createFont("Lucida Sans", 12));
      stroke(128);
      fill(64);
      rect(x, y, w, h);    
    }
    float cvalue = map(sliderY, y, lowerY, 255, 120);// map value to change color..
 
    fill(color(cvalue));//set color as it changes  
    rect(x+w/2-2, y, 4, h);// draw base line
    fill(200);
    rect(x, sliderY, w, knobSize);// draw knob 
    fill(0);
    if (!disabled) {
      text(round(value), x+(round(value)>=10?12:17), sliderY+knobSize/2+4);// display text
 
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
  }
 
  void Disabled(boolean _Disabled) {
    disabled = _Disabled;
  }
  
  void OnChange() {
    POINTER_SPEED = constrain(int(value), 1, 10);
  }  
 
  boolean IsOver() {// is mouse over knob?
    return ((mouseX>=x)&&(mouseX<=x+w)&&(mouseY>=sliderY)&&(mouseY<=sliderY+knobSize));
  }
}
