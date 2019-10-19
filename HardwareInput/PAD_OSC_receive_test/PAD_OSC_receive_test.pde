import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;
final int port = 1337;

int P, A, D, Volume, Speed;

void setup() {
  size(400, 400);
  frameRate(1000);

  oscP5 = new OscP5(this, port);
}


void draw() {
  background(0);
  rect(0,20,map(P,0,1024,0,width),20);
  text("Pleasure: " + P,20,60);
  rect(0,80,map(A,0,1024,0,width),20);
  text("Arousal: " + A,20,120);
  rect(0,140,map(D,0,1024,0,width),20);
  text("Dominance: " + D,20,180);
  rect(0,200,map(Volume,0,1024,0,width),20);
  text("Volume: " + Volume,20,240);
  rect(0,260,map(Speed,0,1024,0,width),20);
  text("Speed: " + Speed,20,300);
}

void oscEvent(OscMessage theOscMessage) {
  P = theOscMessage.get(0).intValue();
  A = theOscMessage.get(1).intValue();
  D = theOscMessage.get(2).intValue();
  Volume = theOscMessage.get(3).intValue();
  Speed = theOscMessage.get(4).intValue(); 
}
