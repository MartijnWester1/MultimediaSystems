#include <ArduinoOSC.h>
#include <ESP8266WiFi.h>

// WiFi stuff
const char* ssid = "interwebs";
const char* pwd = "Wachtwoord";

// for ArduinoOSC
OscWiFi osc;
const char* host = "192.168.43.67";
const int send_port = 1337;

// Potmeter
const int pleasurePot = A0;
const int arousalPot = 39;
const int dominancePot = 34;
const int valuePot = 35;
const int speedPot = 32;

int P, A, D, volume, speed;

void setup()
{
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH);
  Serial.begin(115200);

  // WiFi stuff
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, pwd);
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }
  Serial.print("WiFi connected, IP = "); Serial.println(WiFi.localIP());
  digitalWrite(LED_BUILTIN, LOW);
}

void loop()
{
  readData();
  osc.parse(); // should be called
  sendData();
}

void readData() {
  P = analogRead(pleasurePot);
  A = analogRead(arousalPot);
  D = analogRead(dominancePot);
  volume = analogRead(valuePot);
  speed = analogRead(speedPot);
  Serial.println("Pleasure: " + P);
}

void sendData() {
  osc.send(host, send_port, "/pleasure", P);
  osc.send(host, send_port, "/arousal", A);
  osc.send(host, send_port, "/dominance", D);
  osc.send(host, send_port, "/volume", volume);
  osc.send(host, send_port, "/speed", speed);
}
