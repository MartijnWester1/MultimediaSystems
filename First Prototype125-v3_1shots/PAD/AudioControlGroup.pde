class AudioControl{
  SoundFile sound;
  AudioToggle toggleCtrl;
  Inputbox trackName;
  float x, y, w, h;
  
  AudioControl(float _x, float _y, float _w, float _h, SoundFile _sound, String _name) {//Constructor
    sound = _sound;
    x = _x; y = _y; w = _w; h = _h;
    
    trackName = new Inputbox(x+10,y+10,w-50,20,_name);
    toggleCtrl = new AudioToggle(x+w-30, y+10, false, sound);
  }
  
  void KeyInput() {
    trackName.KeyInput();
  }
  void MousePress() {
    if (trackName.IsOver())
      trackName.Click();//Check / uncheck
    else
      trackName.UndoSelect();//Undo selection
      
    if (toggleCtrl.IsOver())
      toggleCtrl.Click();//Check / uncheck
  }
  
  void update(){
    //Listens if audio file is done playing
    if (toggleCtrl.IsChecked && !sound.isPlaying())
      toggleCtrl.IsChecked = false;
  }
  void Render() {    
    update();
    fill(64);
    stroke(1);
    rect(x,y,w,h);
    
    trackName.Render();
    toggleCtrl.Render();
  }
}
