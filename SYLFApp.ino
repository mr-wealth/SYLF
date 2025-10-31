#include <QTRSensors.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

QTRSensors qtr;
const uint8_t sensorCount = 3;
uint16_t sensorValues[sensorCount];
#define LED_BUILTIN 27

#define SERVICE_UUID "6c8efc7e-2877-453b-b989-701aa7daa2a6"
#define CHARACTERISTIC_UUID "d6188064-6d49-4cbe-baa7-36efa04354c9"

BLECharacteristic *pCharacteristic;
bool deviceConnected = false;

class CommandCallbacks : public BLECharacteristicCallbacks{
  void onWrite(BLECharacteristic *pCharacteristic) override{
    std::string rxValue = pCharacteristic->getValue().c_str();

    if (rxValue.length() > 0){
      Serial.println("Received Command: " + String(rxValue.c_str()));

      //simple command parsing example
      if(rxValue.find("LED ON") != std::string::npos){
        digitalWrite(LED_BUILTIN, HIGH);
        Serial.println("LED turned ON");
      }
      else if(rxValue.find("LED OFF") != std::string::npos){
        digitalWrite(LED_BUILTIN, LOW);
        Serial.println("LED turned OF");
      }
      else{
        Serial.println("Unknown command");
      }
    }
  }
};

class ServerCallbacks : public BLEServerCallbacks{
  void onConnect(BLEServer *pServer){
    deviceConnected = true;
    Serial.println("Client connected");
  }

  void onDisconnect(BLEServer *pServer){
    deviceConnected = false;
    Serial.println("Client disconnected");
  }
};

void setup() {
  //qtr8 sensor setup
  qtr.setTypeRC();
  qtr.setSensorPins((const uint8_t[]){ 32, 33, 25 }, sensorCount);
  qtr.setEmitterPin(26);
  delay(500);

  pinMode(LED_BUILTIN, OUTPUT);

  //calibrate once
  digitalWrite(LED_BUILTIN, HIGH);
  for (uint16_t i = 0; i < 400; i++) {
    qtr.calibrate();
  }
  digitalWrite(LED_BUILTIN, LOW);

  //print minimum calibrated sensor values
  for (uint8_t i = 0; i < sensorCount; i++) {
    Serial.print(qtr.calibrationOn.minimum[i]);
    Serial.print(' ');
  }
  Serial.println();

  //print maximum calibrated values
  for (uint8_t i = 0; i < sensorCount; i++) {
    Serial.print(qtr.calibrationOn.maximum[i]);
    Serial.print(' ');
  }
  Serial.println();
  Serial.println();
  
  //BLE Server setup
  Serial.begin(115200);
  BLEDevice::init("Roboto");  //device name - robot
  BLEServer *pServer = BLEDevice::createServer();
  BLEService *pService = pServer->createService(SERVICE_UUID);

  pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_READ |
    BLECharacteristic::PROPERTY_NOTIFY |
    BLECharacteristic::PROPERTY_WRITE
  );

  pCharacteristic->setCallbacks(new CommandCallbacks());

  pCharacteristic->setValue("Ready");
  pService->start();

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->start();

  Serial.println("Waiting for a client to connect...");
}

void loop() {
  // Periodically send sensor data if connected

  if (deviceConnected) {
    // Simulate sensor data; replace with real sensor readings
    static int counter = 0;
    String sensorString = "Sensor Value: " + String(counter++);
    pCharacteristic->setValue(sensorString.c_str());
    pCharacteristic->notify();

    Serial.println("Sent: " + sensorString);

    delay(1000);
  } else {
    delay(500);
  }
}
