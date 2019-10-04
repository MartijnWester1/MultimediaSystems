class Slider extends Control {
  //FOR NOW ONLY WORKS FOR 0 AND POSITIVE NUMBERS
  public float Value;//Holds value
  float min, max;//Holds range of values
  float knobSize = 20.0f;
  float lowerY;
  float sliderY;
  boolean lock = false;
 
  Slider() { };//empty constructor
 
  Slider(float _x, float _y, float _w, float _h, float _value, float _min, float _max) {
    x=_x; y = _y; w=_w; h=_h;
    min = _min; max = _max;
    lowerY = y + h - knobSize;
    
    Value = constrain(_value, min, max);
    sliderY=_y+(h-knobSize)*((max-Value)/(max-min));
  }
 
  void Render() {
    textFont(createFont("Lucida Sans", 12));
    stroke(128);
    fill(64);
    rect(x, y, w, h);    
    float value = map(sliderY, y, lowerY, 255, 120);// map value to change color..
 
    fill(color(value));//set color as it changes  
    rect(x+w/2-2, y, 4, h);// draw base line
    fill(200);
    rect(x, sliderY, w, knobSize);// draw knob
    fill(0);
    text(round(100*Value) +"%", x+(Value>=1?5:12), sliderY+knobSize/2+4);// display text
 
    //get mouseInput and map it
    if (lock) {
      float mouse_Y = constrain(mouseY, y, lowerY);
      sliderY = mouse_Y;
      float newValue = map(mouse_Y, y, lowerY, max, min);
      if (newValue != Value) {
        Value = newValue;
        OnChange();
      }
    }
  }
 
  boolean IsOver() {// is mouse over knob?
    return ((mouseX>=x)&&(mouseX<=x+w)&&(mouseY>=sliderY)&&(mouseY<=sliderY+knobSize));
  }
}
