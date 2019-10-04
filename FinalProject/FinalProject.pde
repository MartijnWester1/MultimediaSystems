import processing.sound.*;
import java.io.*;

AudioControl[] AudioControls;
Button AddTrack;

void setup() {
  size(600, 480);
  surface.setTitle("MMS Audio Mixer");
  surface.setResizable(true);
  background(255);
  noStroke();
  
  java.io.File folder = new java.io.File(dataPath(""));
  File [] Files = folder.listFiles(new FilenameFilter() {// list the files in the data folder
      @Override
      public boolean accept(File dir, String name) {
          return name.toLowerCase().endsWith(".mp3") 
          || name.toLowerCase().endsWith(".wav")
          ;
      }
  });
  
  optimizeScreenSize(Files.length+1);
  AudioControls = new AudioControl[Files.length];
  for (int i = 0; i < Files.length; i++)
      AudioControls[i] = new AudioControl(20 + (120+20)*i, 20, 120, 440, new SoundFile(this, Files[i].getName()), Files[i].getName());
  AddTrack = new Button(20 + (120+20)*Files.length, 240-60, 120, 120, "+");//add + button
}      

void update() {
  
}
void draw() {
  update();
  background(100);

  for (AudioControl ac:AudioControls)
      ac.Render();
  AddTrack.Render();
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
      int size = AudioControls.length;
      
      SoundFile newFile;
      try {newFile = new SoundFile(this, selected.getAbsolutePath()); }
      catch(Exception e) {
        //  Block of code to handle errors
        System.err.print("CAN'T LOAD AUDIO FILE: ");
        System.err.println(e);
        return;
      }
      
      AudioControls = (AudioControl[]) expand(AudioControls, size+1);//Resize array
      AudioControls[size] = new AudioControl(20 + (120+20)*size, 20, 120, 440, newFile, selected.getName());
      AddTrack = new Button(20 + (120+20)*(size+1), 240-60, 120, 120, "+");//add + button    
      println("Audio source succesfully added.");
      optimizeScreenSize(AudioControls.length+1);
    } else {
      println(extension + " is not a valid extension");
    }
  }
}


void optimizeScreenSize(int nControls) {
  surface.setSize(140*(nControls)+40, 480);
}


void mousePressed() {
  for (AudioControl ac:AudioControls)
    ac.MousePress();
  if (AddTrack.IsOver())
    AddTrack.Click();
}
void mouseReleased() {
  for (AudioControl ac:AudioControls)
    ac.MouseRelease();
}

void keyPressed() {
  for (AudioControl ac:AudioControls)
        ac.KeyInput();
}




 
