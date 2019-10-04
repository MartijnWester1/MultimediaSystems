class AudioControl{
  SoundFile sound;
  AudioVolumeSlider volumeCtrl;
  AudioRateSlider rateCtrl;
  AudioToggle toggleCtrl;
  Inputbox trackName;
  float x, y, w, h;
  
  AudioControl(float _x, float _y, float _w, float _h, SoundFile _sound, String _name) {//Constructor
    sound = _sound;
    x = _x; y = _y; w = _w; h = _h;
    
    volumeCtrl = new AudioVolumeSlider(x+10, y+10, 40, 360, 1.0f, sound, 0.0f, 1.0f);
    rateCtrl = new AudioRateSlider(x+70, y+10, 40, 360, 1.0f, sound, 0.1f, 2.0f);
    toggleCtrl = new AudioToggle(x+50, y+380, false, sound);
    trackName = new Inputbox(x+10,y+405,w-20,20,_name);
  }
  
  void KeyInput() {
    trackName.KeyInput();
  }
  void MousePress() {
    if (volumeCtrl.IsOver())
      volumeCtrl.lock = true;//lock if clicked
    if (rateCtrl.IsOver())
      rateCtrl.lock = true;//lock if clicked
    if (toggleCtrl.IsOver())
      toggleCtrl.Click();//Check / uncheck
    if (trackName.IsOver())
      trackName.Click();//Check / uncheck
    else
      trackName.UndoSelect();//Undo selection
  }
  void MouseRelease() {
    volumeCtrl.lock = false;//unlock
    rateCtrl.lock = false;
  }
  
  void update(){
    
  }
  void Render() {    
    update();
    fill(128);
    stroke(1);
    rect(x,y,w,h);
    
    volumeCtrl.Render();
    rateCtrl.Render();
    toggleCtrl.Render();
    trackName.Render();
  }
}
