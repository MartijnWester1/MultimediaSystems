class AudioToggle extends PlayPause {
  SoundFile Sound;
  float volLevel = 1.0;
  AudioToggle(float _x, float _y, boolean _isChecked, SoundFile _sound) {
    super(_x, _y, _isChecked);
    Sound = _sound;
    OnChange();
  }
  void OnChange() {
    if (IsChecked) {
      SetVolume();
      Sound.play();
    } else {
      if (Sound.isPlaying())
        Sound.pause();
    }
  }
  void SetVolume() {
    Sound.amp(MasterVol*volLevel);
  }
  void SetVolume(float VolLevel) {
    volLevel = VolLevel;
    Sound.amp(MasterVol*volLevel);
  }  
}
