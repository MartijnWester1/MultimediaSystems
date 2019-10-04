class AudioRateSlider extends Slider {
  SoundFile Sound;
  AudioRateSlider(float _x, float _y, float _w, float _h, float _value, SoundFile _sound, float _min, float _max) {
    super(_x, _y, _w, _h, _value, _min, _max);
    Sound = _sound;
    OnChange();
  }
  void OnChange() {
    Sound.rate(Value);
  }  
}
class AudioVolumeSlider extends Slider {
  SoundFile Sound;
  AudioVolumeSlider(float _x, float _y, float _w, float _h, float _value, SoundFile _sound, float _min, float _max) {
    super(_x, _y, _w, _h, _value, _min, _max);
    Sound = _sound;
    OnChange();
  }
  void OnChange() {
    Sound.amp(Value);
  }  
}
class AudioToggle extends PlayPause {
  SoundFile Sound;
  AudioToggle(float _x, float _y, boolean _isChecked, SoundFile _sound) {
    super(_x, _y, _isChecked);
    Sound = _sound;
    OnChange();
  }
  void OnChange() {
    if (IsChecked)
        Sound.loop();
    else
      if (Sound.isPlaying())
        Sound.pause();
  }
}
