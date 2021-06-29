/*
    MrHeadTracker Switchable based on the BNO055 sensor
    Copyright (C) 2016-2017  Michael Romanov, Daniel Rudrich

  CHANGELOG
      2017-06-20: - initial release

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <Adafruit_BNO055.h>
#include <Adafruit_Sensor.h>
#include <Arduino.h>
#include <Bounce.h>
#include <EEPROM.h>

// BNO055 Instance
Adafruit_BNO055 bno = Adafruit_BNO055();

#define DEBUG false

// Pins and Settings
#define LED 13
#define button 3
#define invSwitch 4
#define quatSwitch 5
#define pi 3.1415926536
#define radTo14 2607.594587617613379
#define oneTo14 8191
#define qCalAddr 0 // EEPROM qCal address
#define debounceDelay 50

/* enum ButtonAction { StartCalibration,  } */

volatile unsigned long lastChangeTime, lastPressTime, lastReleaseTime = 0;
volatile bool buttonState = 1;
volatile bool newButtonState = 0;
int action = 0;
int calibrationState = 0;

Bounce mainButton(button, debounceDelay);

uint16_t lastW = 63;
uint16_t newW = 63;
uint16_t lastX = 63;
uint16_t newX = 63;
uint16_t lastY = 63;
uint16_t newY = 63;
uint16_t lastZ = 63;
uint16_t newZ = 63;

enum MidiSendMode { Quaternion, YawPitchRoll };
auto midiMode = MidiSendMode::Quaternion;

// Quaternions and Vectors
imu::Quaternion qCal, qCalLeft, qCalRight, qIdleConj = {1, 0, 0, 0};
imu::Quaternion qGravIdle, qGravCal, quat, steering, qRaw;

imu::Vector<3> gRaw; //
const imu::Vector<3> refVector = {1, 0, 0};
imu::Vector<3> vGravIdle, vGravCal;
imu::Vector<3> ypr; // yaw pitch and roll angles

imu::Vector<3> getGravity();

void blink(int delayTime, size_t numBlinks = 4) {
  for (size_t blink_num = 0; blink_num < numBlinks; blink_num++) {
    digitalWrite(LED, HIGH);
    delay(delayTime / 2);
    digitalWrite(LED, LOW);
    delay(delayTime / 2);
  }
}

void buttonChange() {
  lastChangeTime = millis();
  mainButton.update();
  buttonState = mainButton.read();
  /* buttonState = digitalRead(button); */
  newButtonState = 1;
}

void resetOrientation() {
  qCalLeft = qCal.conjugate();
  qCalRight = qCal;
}

imu::Vector<3> getGravity() {
  imu::Vector<3> gravity = bno.getVector(Adafruit_BNO055::VECTOR_GRAVITY);
  gravity = gravity.scale(-1);
  gravity.normalize();
  return gravity;
}

void calibrate() {
  imu::Vector<3> g, gCal, x, y, z;
  // g = refVector.getRotated(&qGravIdle); //g =
  // qGravIdle.rotateVector(refVector);
  g = vGravIdle;
  z = g.scale(-1);
  z.normalize();

  // gCal = refVector.getRotated(&qGravCal); //gCal =
  // qGravCal.rotateVector(refVector);
  gCal = vGravCal;
  y = gCal.cross(g);
  y.normalize();

  x = y.cross(z);
  x.normalize();

  imu::Matrix<3> rot;
  rot.cell(0, 0) = x.x();
  rot.cell(1, 0) = x.y();
  rot.cell(2, 0) = x.z();
  rot.cell(0, 1) = y.x();
  rot.cell(1, 1) = y.y();
  rot.cell(2, 1) = y.z();
  rot.cell(0, 2) = z.x();
  rot.cell(1, 2) = z.y();
  rot.cell(2, 2) = z.z();

  qCal.fromMatrix(rot);
  EEPROM.put(qCalAddr, qCal);

  resetOrientation();

  if (DEBUG)
    Serial.println("done calibrating");
}

// ================================================================
// ===                      INITIAL SETUP                       ===
// ================================================================

void setup() {
  if (DEBUG) {
    while (!Serial)
      ;
  }

  if (!bno.begin(bno.OPERATION_MODE_IMUPLUS)) {
    /* There was a problem detecting the BNO055 ... check your connections */
    Serial.print(
        "Ooops, no BNO055 detected ... Check your wiring or I2C ADDR!");
    while (1)
      ;
  }

  pinMode(button, INPUT_PULLUP);
  pinMode(invSwitch, INPUT_PULLUP);
  pinMode(quatSwitch, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(button), buttonChange, CHANGE);

  pinMode(LED, OUTPUT);
  digitalWrite(LED, LOW);
  EEPROM.get(qCalAddr, qCal); // read qCal from EEPROM and print values
  resetOrientation();

  bno.setExtCrystalUse(true);
  delay(1000);
}

// ================================================================
// ===                    MAIN PROGRAM LOOP                     ===
// ================================================================

void loop() {
  // ============== BUTTON CHECK ROUTINE ==========================
  action = 0; // do nothing, just chill... for now!

  if (newButtonState) {
    if (!buttonState) {
      // pressed
      if (DEBUG)
        Serial.println("Pressed");

      blink(25);

      lastPressTime = lastChangeTime;
      /* if (millis() - lastPressTime > 1000) { */
      /*   if (DEBUG) */
      /*     Serial.println("Long press"); */
      /*   action = 2;         // held longer than ^ ms */
      /*   newButtonState = 0; // only once! */
      /* } */
    }
    {
      // released
      newButtonState = 0;
      lastReleaseTime = lastChangeTime;
      action = 1; // short button click
      if (DEBUG)
        Serial.println("released");

      blink(10);

      if (lastReleaseTime - lastPressTime > 1000) {
        action = 2; // release after hold > ^ ms

        if (DEBUG)
          Serial.println("long press release");
      }
    }
  }

  // ============== QUATERNION DATA ROUTINE ======================

  imu::Quaternion qRaw = bno.getQuat(); // get sensor raw quaternion data

  steering = qIdleConj * qRaw; // calculate relative rotation data
  quat = qCalLeft * steering;  // transform it to calibrated coordinate system
  quat = quat * qCalRight;

  if (digitalRead(invSwitch) == LOW) {
    quat = quat.conjugate();
  }

  // ============== SEND MIDI ROUTINE ===========================
  /* midiMode = digitalRead(quatSwitch); */
  switch (midiMode) {
  case MidiSendMode::Quaternion: // send quaternion data
    newW = (uint16_t)(oneTo14 * (quat.w() + 1));
    newX = (uint16_t)(oneTo14 * (quat.x() + 1));
    newY = (uint16_t)(oneTo14 * (quat.y() + 1));
    newZ = (uint16_t)(oneTo14 * (quat.z() + 1));

    if (newW != lastW) {
      usbMIDI.sendControlChange(48, newW & 0x7F, 1);
      usbMIDI.sendControlChange(16, (newW >> 7) & 0x7F, 1);
    }
    if (newX != lastX) {
      usbMIDI.sendControlChange(49, newX & 0x7F, 1);
      usbMIDI.sendControlChange(17, (newX >> 7) & 0x7F, 1);
    }
    if (newY != lastY) {
      usbMIDI.sendControlChange(50, newY & 0x7F, 1);
      usbMIDI.sendControlChange(18, (newY >> 7) & 0x7F, 1);
    }
    if (newZ != lastZ) {
      usbMIDI.sendControlChange(51, newZ & 0x7F, 1);
      usbMIDI.sendControlChange(19, (newZ >> 7) & 0x7F, 1);
    }

    lastW = newW;
    lastX = newX;
    lastY = newY;
    lastZ = newZ;
    break;

  case MidiSendMode::YawPitchRoll:
    ypr = quat.toEuler();
    newZ = (uint16_t)(radTo14 * ((ypr[0] + pi)));
    newY = (uint16_t)(radTo14 * ((ypr[1] + pi)));
    newX = (uint16_t)(radTo14 * ((ypr[2] + pi)));

    if (newZ != lastZ) {
      usbMIDI.sendControlChange(48, newZ & 0x7F, 1);
      usbMIDI.sendControlChange(16, (newZ >> 7) & 0x7F, 1);
    }
    if (newY != lastY) {
      usbMIDI.sendControlChange(49, newY & 0x7F, 1);
      usbMIDI.sendControlChange(17, (newY >> 7) & 0x7F, 1);
    }
    if (newX != lastX) {
      usbMIDI.sendControlChange(50, newX & 0x7F, 1);
      usbMIDI.sendControlChange(18, (newX >> 7) & 0x7F, 1);
    }
    lastX = newX;
    lastY = newY;
    lastZ = newZ;
    break;
  };

  // ============== BUTTON ACTION ROUTINE ======================
  switch (action) {
  case 1: // short button click
    if (calibrationState == 1) {
      vGravCal = getGravity();
      calibrate();
      calibrationState = 0;

    } else {
      qIdleConj = qRaw.conjugate();
    }
    break;
  case 2: // long hold
    if (!calibrationState) {
      calibrationState = 1;
      qIdleConj = qRaw.conjugate();
      vGravIdle = getGravity();
    }
  }
}
