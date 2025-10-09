#include <Arduino.h>
#include <WiFiClientSecure.h>
#include <SPIFFS.h>
#include "at_client.h"
#include <constants.h>



void setup() {
  // put your setup code here, to run once:
  const auto *at_sign = new AtSign("@baksoblue55live");

  //reads the keys on the ESP32
  const auto keys = keys_reader::read_keys(*at_sign);

  //creates the AtClient object (allows us to run operations)
  auto *at_client = new AtClient(*at_sign, keys);

  //pkam authenticate into our atServer
  at_client->pkam_authenticate(SSID, PASSWORD);
}

void loop() {
  // put your main code here, to run repeatedly:
}
