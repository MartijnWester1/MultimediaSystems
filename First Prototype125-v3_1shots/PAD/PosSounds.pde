class PosSound {
  float d = 0;
  PVector vec;
  SoundFile f;
  float vol = MIN;
  float volFr = 0;
  float targetVol = 0;
  int beatTime = 0;
  final int UPDATE_TIME = 1;

  PosSound(PApplet app, String url, float p, float a, float d) {
    vec = new PVector(p, a, d);
    f = new SoundFile(app, url);
    f.amp(vol);
  }
  void update() {
    volFr = targetVol;
    vol = volFr * volMult;
    vol = constrain(vol, 0, 1);
    f.amp(max(MIN, min(vol * MasterVol, 1)));
    beatTime -= UPDATE_TIME;
  }

  void setVolume(float v) {
    if (v < 0) v = 0;
    if (v > 1) v = 1;
    targetVol = v;
  }

  float getVolume() {
    return volFr;
  }
}
