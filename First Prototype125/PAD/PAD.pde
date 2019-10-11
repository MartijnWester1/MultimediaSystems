import processing.sound.*;

final float MIN = 0.0001;

ArrayList<PosSound> sounds = new ArrayList<PosSound>();
PVector mPos;
float volMult = 1;
PVector pointerPos = new PVector();
int POINTER_SPEED = 3;
float masterVol = 0;
float targetMasterVol = 0;
int tSize = 16;

boolean LOADAUDIO = true;
Slider EaseSlider, DominanceSlider;
int ScrollSpeed = 10;//"Pixels" / scroll tick

void setup() {
  size(860, 440);  
  
  if (LOADAUDIO)
    for (int p = 0; p < 5; p++)
      for (int a = 0; a < 5; a++)
        for (int d = 0; d < 5; d++)
          loadSound("..\\..\\..\\First Prototype\\PAD\\data\\mix0" + a + "" + d + ".wav", p, a, d);
      
  EaseSlider = new Slider(680, 20, 40, 400, float(POINTER_SPEED), 1f, 10f);
  DominanceSlider = new Slider(760, 20, 40, 400, 0f, 0f, 1f);
  DominanceSlider.Disabled(true);//Gives other appearance

  mPos = new PVector(0,0,0);
  pointerPos = new PVector(0,0,0);
  textSize(tSize);
}

void draw() {
  translate(20, 20);
  background(0);
  stroke(200);
  strokeWeight(1);
  for (int x = 0; x < 500; x+=100) {
    line(x, 0, x, 400);
    line(0, x, 400, x);
  }
  strokeWeight(2);
  noFill();
  rect(0, 0, 400, 400);
  mPos.x = constrain(mouseX - 20, 0, 400);
  mPos.y = constrain(mouseY - 20, 0, 400);
  //mPos.z is set within mousewheel function

  float dx, dy, dz, dist;
  fill(255, 0, 0);
  noStroke();
  float totalVolFr = 0;
  if (LOADAUDIO)
    for (PosSound s : sounds) {
      s.update();
      dx = min(pointerPos.x, 401) - (s.vec.x * 100);
      dy = min(pointerPos.y, 401) - (s.vec.y * 100);
      dz = min(pointerPos.z, 401) - (s.vec.z * 100);
      dist = sqrt(dx * dx + dy * dy + dz * dz);
      float ratio = map(dist, 0, 145, 1, 0);
      s.setVolume(ratio);
      float radius = s.vol * 30;
      ellipse(s.vec.x * 100, s.vec.y * 100, radius, radius);
      totalVolFr += s.getVolume();
      
      //Set dominance slider
      DominanceSlider.SetValue(getDominance());
    }
  
  PVector diff = PVector.sub(mPos, pointerPos);
  diff.limit(POINTER_SPEED);
  pointerPos.add(diff);
  
  fill(0, 255, 0);
  ellipse(pointerPos.x, pointerPos.y, 10, 10);
  
  volMult = 1 / totalVolFr;
  masterVol += (targetMasterVol - masterVol) * 0.05;
  if(abs(targetMasterVol - masterVol) < 0.005) masterVol = targetMasterVol;
  
  fill(255);
  text(masterVol > 0.01 ? "Click to MUTE" : "Click to Start", 420, rule(1));  
  
  textFont(createFont("MonoSpaced", 14));
  text("Master Volume      " + (int(masterVol * 100) / 100f), 420, rule(3));
  text("Pleasure (X-Axis)  " + getPleasure(), 420, rule(4));  
  text("Arousal (Y-Axis)   " + getArousal(), 420, rule(5));
  text("Dominance (Scroll) " + nf(getDominance(), 0, 2), 420, rule(6));
  text("Ease Speed [1-10]  " + POINTER_SPEED, 420, rule(7));
  
  translate(-20, -20);
  EaseSlider.Render();
  DominanceSlider.Render();
}

void loadSound(String url, float p, float a, float d) {
  sounds.add(new PosSound(this, url, p, a, d));
}

float getPleasure(){
  return int((pointerPos.x / 400) * 100) / 100f;
}

float getArousal(){
  return int((pointerPos.y / 400) * 100) / 100f;
}

float getDominance(){
  return int((pointerPos.z / 400) * 100) / 100f;
}

float rule(int nr){
  return (nr + 0.25) * tSize;
}

boolean playing = false;
void mousePressed() {
  if ((mouseX>=20)&&(mouseX<=420)&&(mouseY>=20)&&(mouseY<=420)) {
    if(targetMasterVol == 1) targetMasterVol = 0;
    else targetMasterVol = 1;
  }
  
  if (!playing) {
    playing = true;
    for (PosSound s : sounds) {
      s.f.loop();
    }
  }
  
  if (EaseSlider.IsOver())
    EaseSlider.lock = true;//lock if clicked
}

void mouseReleased() {
  EaseSlider.lock = false;//unlock
}

void mouseWheel(MouseEvent event){
  if(event.getCount() != 0)
    mPos.z += ScrollSpeed*event.getCount();
  mPos.z = constrain(mPos.z, 0, 400);
}

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
    f.amp(max(MIN, min(vol * masterVol, 1)));
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
