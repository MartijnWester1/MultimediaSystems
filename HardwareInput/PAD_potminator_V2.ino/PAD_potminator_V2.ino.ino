#include <ArduinoOSC.h>
#include <ESP8266WiFi.h>

OscWiFi osc;
const char* host = "192.168.43.67";
const int send_port = 1337;

const int pleasurePot = A0;

int P;

void setup()
{
  pinMode(pleasurePot, INPUT);
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH);
  Serial.begin(115200);
  Serial.println();

  WiFi.begin("interwebs", "Wachtwoord");

  Serial.print("Connecting");
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    Serial.print(".");
  }
  Serial.println();

  Serial.print("Connected, IP address: ");
  Serial.println(WiFi.localIP());
  digitalWrite(LED_BUILTIN, LOW);
}

void loop()
{
  readData();
  //osc.parse(); // should be called
  sendData();
}

void readData() {
  P = analogRead(pleasurePot);
  Serial.print("Pleasure: ");
  Serial.print("\t");
  Serial.println(P);
}

void sendData() {
  osc.send(host, send_port, "/pleasure", P);
}
