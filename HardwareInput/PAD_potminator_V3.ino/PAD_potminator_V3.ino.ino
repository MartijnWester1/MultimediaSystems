/*  Libraries  */
#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include <OSCMessage.h>

/*  Wifi configs  */
char ssid[] = "Dollard_2.4GHz";
char pass[] = "ik54j3s94rgq";

/*  OSC configs  */
WiFiUDP Udp;                                // A UDP instance to let us send and receive packets over UDP
const IPAddress outIp(192, 168, 1, 14); // remote IP of your computer
const unsigned int outPort = 1337;          // remote port to receive OSC
const unsigned int localPort = 8888;        // local port to listen for OSC packets (actually not used for sending)
String pleasure = "/pleasure";

/*  Multiplexer configs  */
const int analogInputPin = A0;

const int s0 = 14;
const int s1 = 12;
const int s2 = 13;
const int s3 = 15;

int bitToCh [16] [4] = {
  // s0, s1, s2, s3     channel
  {0,  0,  0,  0}, // 0
  {1,  0,  0,  0}, // 1
  {0,  1,  0,  0}, // 2
  {1,  1,  0,  0}, // 3
  {0,  0,  1,  0}, // 4
  {1,  0,  1,  0}, // 5
  {0,  1,  1,  0}, // 6
  {1,  1,  1,  0}, // 7
  {0,  0,  0,  1}, // 8
  {1,  0,  0,  1}, // 9
  {0,  1,  0,  1}, // 10
  {1,  1,  0,  1}, // 11
  {0,  0,  1,  1}, // 12
  {1,  0,  1,  1}, // 13
  {0,  1,  1,  1}, // 14
  {1,  1,  1,  1}  // 15
};

/*  Variables  */
int P, A, D, Volume, Speed;

void setup() {
  Serial.begin(115200);

  pinMode(analogInputPin, INPUT);
  pinMode(2, OUTPUT);
  digitalWrite(2, HIGH);

  pinMode(s0, OUTPUT);
  pinMode(s1, OUTPUT);
  pinMode(s2, OUTPUT);
  pinMode(s3, OUTPUT);

  /*  Connect to WiFi  */
  Serial.println();
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, pass);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");

  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());

  digitalWrite(2, LOW);

  Serial.println("Starting UDP");
  Udp.begin(localPort);
  Serial.print("Local port: ");
  Serial.println(Udp.localPort());

}

void loop() {
  P = readData(0);
  A = readData(1);
  D = readData(2);
  Volume = readData(3);
  Speed = readData(4);
  OSCMessage msg("/pleasure");
  msg.add(P);
  msg.add(A);
  msg.add(D);
  msg.add(Volume);
  msg.add(Speed);
  Udp.beginPacket(outIp, outPort);
  msg.send(Udp);
  Udp.endPacket();
  msg.empty();
  delay(20);
}

int readData(int pin) {
  channelSelector(pin);
  return analogRead(analogInputPin);
}

void channelSelector(int num) {
  digitalWrite(s0, bitToCh[num][0]);
  digitalWrite(s1, bitToCh[num][1]);
  digitalWrite(s2, bitToCh[num][2]);
  digitalWrite(s3, bitToCh[num][3]);
}
