#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

#define SERVICE_UUID "e0cfbdd4-3367-4242-a6e6-0ff0d10021af"
#define CHARACTERISTIC_UUID "12846e86-430a-45e8-890b-ae81d3bc49d3"
BLECharacteristic *pCharacteristic = NULL;


// put function declarations here:
int myFunction(int, int);

void setup() {
  Serial.begin(115200);
  Serial.println("Starting the BLE server creation work!");

  BLEDevice::init("ESP32_ROB");
  BLEServer *pServer = BLEDevice::createServer();
  BLEService *pService = pServer->createService(SERVICE_UUID);
  pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_READ |
    BLECharacteristic::PROPERTY_WRITE |
    BLECharacteristic::PROPERTY_NOTIFY);
  
  pCharacteristic->setValue("Hello World, it's Sylfie!");
  pService->start();

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
  Serial.println("Chraracteristic defined! Now you can read it in your phone!");

  
}

void loop() {
  // put your main code here, to run repeatedly:
  pCharacteristic->notify();
  delay(2000);
}

// put function definitions here:
int myFunction(int x, int y) {
  return x + y;
}