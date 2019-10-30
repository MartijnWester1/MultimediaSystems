import processing.sound.*;
import oscP5.*;
import netP5.*;
import java.io.*;

OscP5 oscP5;
NetAddress myRemoteLocation;
final int port = 1337;
final boolean OSC_Overrules_Control = true;

PrintStream Console;//Stores console stream
boolean ConsoleEnabled = true;

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

final boolean RemoteControl = false;
final boolean LoadAudio = false;
float ScrollSpeed = .1;//Amount / scroll steps
PImage Sound, NoSound;
PFont myFont;

//Stores .ini file content
String[][] iniLines_Split;
boolean iniLoaded = false;

//One-shot controls
AudioControl[] Audio_1_shot_Controls;
Button AddTrack;

void setup() {
  size(1280, 680);
  surface.setTitle("MS Audio Mixer");
  surface.setResizable(true);  
  if (RemoteControl)
    oscP5 = new OscP5(this, port);
  
  //Load one-shot audio files
  java.io.File folder = new java.io.File(dataPath(""));
  File [] Files = folder.listFiles(new FilenameFilter() {// list the files in the data folder
      @Override
      public boolean accept(File dir, String name) {
          return name.toLowerCase().endsWith(".mp3") 
          || name.toLowerCase().endsWith(".wav")
          ;
      }
  });
  //Load control images
  Sound = loadImage("AudioG.png");
  NoSound = loadImage("NoAudioG.png");
  myFont = createFont("Orbitron.ttf", 24);
  
  if (LoadAudio)
    for (int p = 0; p < 5; p++)
      for (int a = 0; a < 5; a++)
        for (int d = 0; d < 5; d++)
          loadSound("..\\..\\..\\First Prototype\\PAD\\data\\mix0" + a + "" + d + ".wav", p, a, d);
      
  P_Slider = new Slider(770, 220, 40, 360, 0f, 0f, 1f); P_Slider.Label = "P";
  A_Slider = new Slider(870, 220, 40, 360, 0f, 0f, 1f); A_Slider.Label = "A";
  D_Slider = new Slider(970, 220, 40, 360, 0f, 0f, 1f); D_Slider.Label = "D";
  VolSlider = new Slider(1100, 60, 40, 220, 0f, 0f, 1f);  
  EaseSlider = new Slider(1170, 60, 40, 220, POINTER_SPEED, .01f, .1f);
  
  Sliders[0] = P_Slider;
  Sliders[1] = A_Slider;
  Sliders[2] = D_Slider;
  Sliders[3] = VolSlider;
  Sliders[4] = EaseSlider;


  //Init one-shot sound buttons
  optimizeScreenSize(Files.length+1);
  Audio_1_shot_Controls = new AudioControl[Files.length];
  for (int i = 0; i < Files.length; i++)
      Audio_1_shot_Controls[i] = new AudioControl(1050, 350+50*i, 200, 40, new SoundFile(this, Files[i].getName()), 
      Files[i].getName().substring(0, Files[i].getName().indexOf(".")));
  AddTrack = new Button(1050 + 40, 350+50*Files.length, 120, 60, "+");//add + button  

  println("One-shots sounds loaded: " + Audio_1_shot_Controls.length);
  
  //Load .ini file
  loadIniParams();
  if (!iniLoaded)
    println("Error while loading sound parameters, close program to see details.");

  listenPos = new PVector(0f,0f,0f);
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
    
  for (AudioControl ac:Audio_1_shot_Controls)
    ac.Render();
  AddTrack.Render();

  //Other text drawing
  fill(255);
  textSize(20);
  text("Master Volume", 756, rule(2)+20); text(nf(MasterVol, 0, 2), 980, rule(2)+20);
  text("Ease Speed", 756, rule(3)+20); text(nf(POINTER_SPEED, 0, 2), 980, rule(3)+20);
  text("Pleasure (X-Axis)", 756, rule(5)+20); text(nf(getPleasure(), 0, 2), 980, rule(5)+20);
  text("Arousal (Y-Axis)", 756, rule(6)+20); text(nf(getArousal(), 0, 2), 980, rule(6)+20);
  text("Dominance (Z-Axis)", 756, rule(7)+20); text(nf(getDominance(), 0, 2), 980, rule(7)+20);

  fill(255);//Labels
  textSize(16);
  text("Volume", 1091, 52);
  text("Ease", 1174, 52);
  text("> One-shot sounds <", 1066, 342);
  
  tint(255, isOverMuteButton() ? 255:192); 
  
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



void AddAudioTrack(File selected) {
  if (selected == null || selected.getAbsolutePath().length() <= 4) {
    println("Bad selection");
    return;
  }
  
  String selectedPath = selected.getAbsolutePath();
  println("FILE SELECTED: " + selectedPath);
  if (selectedPath.length()>4) {
    String extension = selectedPath.substring(selectedPath.length()-4, selectedPath.length()).toLowerCase();
    if (extension.equals(".mp3") || extension.equals(".wav")) {
      int size = Audio_1_shot_Controls.length;
      
      SoundFile newFile;
      try {newFile = new SoundFile(this, selected.getAbsolutePath()); }
      catch(Exception e) {
        System.err.print("CAN'T LOAD AUDIO FILE: ");
        System.err.println(e);
        return;
      }
      
      Audio_1_shot_Controls = (AudioControl[]) expand(Audio_1_shot_Controls, size+1);//Resize array
      Audio_1_shot_Controls[size] = new AudioControl(1050, 350+50*size, 200, 40, newFile, 
        selected.getName().substring(0, selected.getName().indexOf(".")));
      AddTrack = new Button(1050 + 40, 320+50*(size+1), 120, 120, "+");//add + button
      
      println("Audio source succesfully added.");
      optimizeScreenSize(Audio_1_shot_Controls.length+1);
      setIniParams();//Load possible parameters belonging to this file from the ini database
    } else {
      println(extension + " is not a valid extension");
    }
  }
}


void loadIniParams() {
  int numParams = 4;//Number of parameters excl. name
  
  try {//Loading .ini file 
    String[] iniLines = loadStrings("sound_parameters.ini");
    iniLines_Split = new String[iniLines.length][];
    for (int i=0; i<iniLines.length; i++) {
      iniLines_Split[i] = splitTokens(iniLines[i], ",/ \t");
      if (iniLines_Split[i].length<=numParams) {
          System.err.print("Corrupt .ini-file :: Invalid number of arguments");
          return;
      }
      for (int j=1; j<min(iniLines_Split[i].length,numParams+1); j++)
        try { Float.parseFloat(iniLines_Split[i][j]); }//Type checking
        catch (Exception e){
          System.err.print("Corrupt .ini-file: \n" + e);
          return;
        }
    }
    iniLoaded = true;
    println("Sound parameters successfully loaded from file.\n");
  }
  catch(Exception e) {
    System.err.print("Cannot find any .ini-file: \n" + e);
    return;
  }
  
  setIniParams();
}

void setIniParams() {
  if (!iniLoaded)
    return;
  
  //Temporarily disable console output to prevent annoying warnings 
  ToggleConsoleOutput();

  //Set one shot parameters to .ini values
  for (AudioControl ac:Audio_1_shot_Controls) {
    for (int f = 0; f<iniLines_Split.length; f++)
      if (ac.trackName.text.equals(iniLines_Split[f][0])) {
        ac.toggleCtrl.SetVolume(Float.parseFloat(iniLines_Split[f][1]));
        ac.sound.rate(Float.parseFloat(iniLines_Split[f][2]));
        
        // <TODO> Add more functions to ini parameters ...
        
        //println("Params loaded for file: " + iniLines_Split[f][0]);
      }
  }
  //Re-enable console output 
  ToggleConsoleOutput();
}

void oscEvent(OscMessage theOscMessage) {
  if (OSC_Overrules_Control) {
    P_Slider.SetValue(map(theOscMessage.get(0).intValue(),0,1024,P_Slider.min,P_Slider.max));
    A_Slider.SetValue(map(theOscMessage.get(1).intValue(),0,1024,A_Slider.min,A_Slider.max));
    D_Slider.SetValue(map(theOscMessage.get(2).intValue(),0,1024,D_Slider.min,D_Slider.max));
    VolSlider.SetValue(map(theOscMessage.get(3).intValue(),0,1024,VolSlider.min,VolSlider.max));
    EaseSlider.SetValue(map(theOscMessage.get(4).intValue(),0,1024,EaseSlider.min,EaseSlider.max));
  }
}

//Allows to temporarily disable console output to prevent annoying warnings (uses global printstream Console)
void ToggleConsoleOutput() {
  if (ConsoleEnabled) {
    Console = System.out;//Store original stream
    System.setOut(new PrintStream(new OutputStream() {
        public void write(int b) { }
  }));       
 } else {
    System.setOut(Console);
 }
 ConsoleEnabled = !ConsoleEnabled;
}

void optimizeScreenSize(int nControls) {
  surface.setSize(1280, max(352+50*nControls, 680));
}

boolean isOverMuteButton() {
 return (mouseX>=cv_Width-80)&&(mouseX<=cv_Width)&&(mouseY>=cv_Height-80)&&(mouseY<=cv_Height); 
}

void mousePressed() {
  //Mute button functionality
  if (isOverMuteButton()) {
    if(VolSlider.GetValue() > 0.01) VolSlider.SetValue(0f);
    else VolSlider.SetValue(1f);
  }
  for (Slider sl:Sliders)
    if (sl.IsOver())
      sl.lock = true;
  for (AudioControl ac:Audio_1_shot_Controls)
    ac.MousePress();
  
  AddTrack.Click();          
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
void keyPressed() {
  for (AudioControl ac:Audio_1_shot_Controls)
        ac.KeyInput();
}


float getPleasure(){ return (listenPos.x/4); }
float getArousal(){ return (listenPos.y/4); }
float getDominance(){ return (listenPos.z/4); }

float rule(int nr){ return (1.2*nr+0.25)*textAscent(); }


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
