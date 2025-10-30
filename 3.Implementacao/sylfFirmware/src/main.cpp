#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

#define SERVICE_UUID "e0cfbdd4-3367-4242-a6e6-0ff0d10021af"
#define CHARACTERISTIC_UUID "12846e86-430a-45e8-890b-ae81d3bc49d3"


// put function declarations here:
int myFunction(int, int);

void setup() {
  Serial.begin(115200);
  Serial.println("Starting the BLE server creation work!");

  BLEDevice::init("ESP32_ROB");
  BLEServer *pServer = BLEDevice::createServer();
  BLEService *pService = pServer->createService(SERVICE_UUID);
  BLECharacteristic *pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_READ |
    BLECharacteristic::PROPERTY_WRITE);
  
  pCharacteristic->setValue("Hello World, it's Sylfie!");
  pService->start();

  BLEAdvertising *pAdevertising = BLEDevice::getAdvertising();
  
}

void loop() {
  // put your main code here, to run repeatedly:
}

// put function definitions here:
int myFunction(int x, int y) {
  return x + y;
}