abstract class Control {
  float x, y, w, h;
  Control(){ }
  
   void OnChange() { };
   
   abstract boolean IsOver();
  
}
