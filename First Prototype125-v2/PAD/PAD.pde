import processing.sound.*;

final float MIN = 0.0001;
final int sc = 100;//Cube scale

ArrayList<PosSound> sounds = new ArrayList<PosSound>();
float volMult = 1f;
PVector listenPos = new PVector();
float POINTER_SPEED = 0.02;
float MasterVol = 0;
boolean isPlaying = false;

int cv_Width = 720, cv_Height = 620;
Slider P_Slider, A_Slider, D_Slider, EaseSlider, VolSlider;
Slider[] Sliders = new Slider[5];

boolean LoadAudio = true;
float ScrollSpeed = .1;//Amount / scroll steps
PImage Sound, NoSound;


void setup() {
  size(1270, 680);
  surface.setTitle("MS Audio Mixer");
  surface.setResizable(true);  
  Sound = loadImage("AudioG.png");
  NoSound = loadImage("NoAudioG.png");
  
  if (LoadAudio)
    for (int p = 0; p < 5; p++)
      for (int a = 0; a < 5; a++)
        for (int d = 0; d < 5; d++)
          loadSound("..\\..\\..\\First Prototype\\PAD\\data\\mix0" + a + "" + d + ".wav", p, a, d);
      
  P_Slider = new Slider(780, 220, 40, 360, 0f, 0f, 1f); P_Slider.Label = "P";
  A_Slider = new Slider(880, 220, 40, 360, 0f, 0f, 1f); A_Slider.Label = "A";
  D_Slider = new Slider(980, 220, 40, 360, 0f, 0f, 1f); D_Slider.Label = "D";
  VolSlider = new Slider(1100, 60, 40, 270, 0f, 0f, 1f);  
  EaseSlider = new Slider(1170, 60, 40, 270, POINTER_SPEED, .01f, .1f);
  
  Sliders[0] = P_Slider;
  Sliders[1] = A_Slider;
  Sliders[2] = D_Slider;
  Sliders[3] = VolSlider;
  Sliders[4] = EaseSlider;


  listenPos = new PVector(0f,0f,0f);
  textSize(24);
  delay(1000);
}

float map2X (float x, float z) { return (x+.5*z)*sc; }
float map2Y (float y, float z) { return (y-.25*z+1)*sc; }

void draw() {
  if (VolSlider.GetValue() > 0.01)
    Play();
  
  drawCube();
  calcVolumes();//Determines the amplitude of every sound
  handleSoundPointer();
  
  for (Slider sl:Sliders)
    sl.Render();

  //Other text drawing
  fill(255);
  textFont(createFont("MonoSpaced", 20));
  text("Master Volume      " + nf(MasterVol, 0, 2), 760, rule(2)+20);
  text("Ease Speed         " + nf(POINTER_SPEED, 0, 2), 760, rule(3)+20);
  text("Pleasure (X-Axis)  " + nf(getPleasure(), 0, 2), 760, rule(5)+20);  
  text("Arousal (Y-Axis)   " + nf(getArousal(), 0, 2), 760, rule(6)+20);
  text("Dominance (Z-Axis) " + nf(getDominance(), 0, 2), 760, rule(7)+20);

  fill(255);//Labels
  textFont(createFont("MonoSpaced", 16)); 
  text("Vol", 1107, 350);
  text("Ease", 1171, 350);
  
  //Sound mute button
  image(VolSlider.GetValue() > 0.01 ? Sound : NoSound, cv_Width-70, cv_Height-70, 48, 48);
}



void drawCube() {
  background(0);
  stroke(64);
  fill(32);
  rect(0,0,cv_Width,cv_Height);
  
  translate(60, 60);
  stroke(200);
  strokeWeight(1);
  
  //Draw cube
  line(0, sc, 2*sc, 0);//Z-axis
  line(0, sc, 0, 5*sc);//Y-axis
  line(0, sc, 4*sc, sc);//X-axis
  for (int x = 1; x < 5; x++) {
    line(0, (x+1)*sc, 4*sc, (x+1)*sc);//Front horizontal    
    line(x*sc, sc, x*sc, 5*sc);//Front vertical
    line(6*sc, x*sc, 4*sc, (x+1)*sc);//Side horizontal
    line((.5*x+4)*sc, (-.25*x+1)*sc, (.5*x+4)*sc, (-.25*x+5)*sc);//Side vertical
    line((.5*x)*sc, (-.25*x+1)*sc, (0.5*x+4)*sc, (-.25*x+1)*sc);//Top horizontal
    line(x*sc, sc, (x+2)*sc, 0);//Top vertical
  }
}
  
void calcVolumes(){
  noFill();
  noStroke();
  float dx, dy, dz, dist;
  float totalVolFr = 0;
  if (LoadAudio)
    for (PosSound s : sounds) {
      s.update();
      dx = min(listenPos.x, 4f) - (s.vec.x);
      dy = min(listenPos.y, 4f) - (s.vec.y);
      dz = min(listenPos.z, 4f) - (s.vec.z);
      dist = sqrt(dx * dx + dy * dy + dz * dz);
      if (dist>4) continue;
      
      float ratio = map(dist, 0, 4, 1, 0);
      s.setVolume(ratio);
      if (s.vec.x==4 || s.vec.y==0 || s.vec.z==0){
        float radius = pow(ratio, 0.65) * 42;
        fill(0, 0, 255, 38+3*radius);
        ellipse(map2X(s.vec.x, s.vec.z), map2Y(s.vec.y, s.vec.z), radius, radius);
      }
      totalVolFr += s.getVolume();
    }

  volMult = 1 / totalVolFr;
  MasterVol += (VolSlider.GetValue() - MasterVol) * 0.05;
  if(abs(VolSlider.GetValue() - MasterVol) < 0.005)
    MasterVol = VolSlider.GetValue();
}
  
  
void handleSoundPointer() {
  //Moves sound pointer
  POINTER_SPEED = EaseSlider.GetValue();
  PVector desiredPos = new PVector(4*P_Slider.GetValue(), 4*A_Slider.GetValue(), 4*D_Slider.GetValue());
  PVector diff = PVector.sub(desiredPos, listenPos);
  diff.limit(POINTER_SPEED);
  listenPos.add(diff);
  
  //Draw sound pointer
  float screenX = map2X(listenPos.x, listenPos.z);
  float screenY = map2Y(listenPos.y, listenPos.z);
  //Draw indicator lines
  stroke(25, 255, 65, 192);
  strokeWeight(2);
  line(screenX, screenY, 660, screenY);//Draw X-axis indicator
  line(screenX, screenY, screenX, -60);//Draw Y-axis indicator
  //Draw Z-axis indicator
  if (listenPos.x*sc-1120+2*sc + listenPos.y*sc*2 >= -60)
    line(screenX, screenY, listenPos.x*sc-1120+2*sc + listenPos.y*sc*2, 560);
  else
    line(screenX, screenY, -60, listenPos.x*.5*sc+sc+30 + listenPos.y*sc);
    
  fill(255, 25, 25);
  noStroke();  
  ellipse(screenX, screenY, 15, 15);//Draw sound pointer dot
  strokeWeight(1);
  stroke(255, 25, 25, 90);
  fill(255, 25, 25, 55);
  //Draw desired pointer position
  ellipse(map2X(4*P_Slider.GetValue(),4*D_Slider.GetValue()), map2Y(4*A_Slider.GetValue(),4*D_Slider.GetValue()), 15, 15);
  translate(-60, -60);
}


void mousePressed() {
  if ((mouseX>=cv_Width-80)&&(mouseX<=cv_Width)&&(mouseY>=cv_Height-80)&&(mouseY<=cv_Height)) {
    if(VolSlider.GetValue() > 0.01) VolSlider.SetValue(0f);
    else VolSlider.SetValue(1f);
  }
  for (Slider sl:Sliders)
    if (sl.IsOver())
      sl.lock = true;
}
void mouseReleased() {
  EaseSlider.lock = false;//unlock
  
  for (Slider sl:Sliders)
      sl.lock = false;//unlock
}
void mouseWheel(MouseEvent event){
  if(event.getCount() != 0)
    VolSlider.SetValue(ScrollSpeed*-event.getCount()+VolSlider.GetValue());
}



float getPleasure(){ return (listenPos.x/4); }
float getArousal(){ return (listenPos.y/4); }
float getDominance(){ return (listenPos.z/4); }

float rule(int nr){ return (nr+0.25)*textAscent(); }


void loadSound(String url, float p, float a, float d) {
  sounds.add(new PosSound(this, url, p, a, d));
}

void Play(){
  if (!isPlaying) {
    isPlaying = true;
    for (PosSound s : sounds) {
      s.f.loop();
    }
  }
}
