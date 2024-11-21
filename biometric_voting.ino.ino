#include <Adafruit_Fingerprint.h>
#include <SoftwareSerial.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <ctype.h>

SoftwareSerial mySerial(2, 3); // RX, TX pins for the fingerprint sensor
Adafruit_Fingerprint finger = Adafruit_Fingerprint(&mySerial);



//int userID = 1; // Starting ID; can be retrieved dynamically if needed

bool isNumber(const char *str) {
    if (*str == '\0') {
        return false; // Empty string is not a number
    }

    // Check for optional sign
    if (*str == '+' || *str == '-') {
        str++;
    }

    // Check for digits
    bool hasDigit = false;
    while (isdigit(*str)) {
        hasDigit = true;
        str++;
    }

    // Check for optional decimal point
    if (*str == '.') {
        str++;

        // Check for digits after decimal point
        while (isdigit(*str)) {
            hasDigit = true;
            str++;
        }
    }

    // Check if the entire string was processed
    if (*str != '\0') {
        return false; // Invalid characters found
    }

    return hasDigit;
}
void clearFingerprintDatabase() {
  if (finger.emptyDatabase()) {
    Serial.println("Sensor database cleared.");
  } else {
    Serial.println("Failed to clear sensor database.");
  }
}
void processCommand(String command) {
  if (isNumber(command.c_str())) {
    // Extract the user ID from the command
    int userID = command.toInt();
    if (enrollFingerprint(userID)) {
      Serial.println("Enrollment_Done");
      Serial.println("registration_success");  // Send success response to Raspberry Pi
    } else {
      Serial.println("Enrollment_not_done");
      Serial.println("registration_failed");   // Send failure response to Raspberry Pi
    }
  } else if (command.startsWith("verify")){
    if (verifyFingerprint()) {
        Serial.println("approved");
      } else {
        Serial.println("denied");
      }
  }else if (command.startsWith("clear_all_users")) {
      clearFingerprintDatabase();
    }
}
void setup() {
  Serial.begin(9600);
  finger.begin(57600);
  if (finger.verifyPassword()) {
    //Serial.println("Fingerprint sensor detected!");
  } else {
    //Serial.println("Fingerprint sensor not found :(");
    while (1);
  }
}

void loop() {
  if (Serial.available() > 0) {
    String command = Serial.readStringUntil('\n');
    processCommand(command);
  }
}

// Enroll fingerprint with unique ID
bool enrollFingerprint(int userID) {
  Serial.print("Enrolling fingerprint for UserID #");
  Serial.println(userID);

  Serial.println("Place finger on sensor...");
  while (finger.getImage() != FINGERPRINT_OK);

  if (finger.image2Tz(1) != FINGERPRINT_OK) {
    Serial.println("Failed to convert first image.");
    return false;
  }

  Serial.println("Remove finger...");
  delay(2000);
  while (finger.getImage() != FINGERPRINT_NOFINGER);
  Serial.println("Place the same finger again...");

  while (finger.getImage() != FINGERPRINT_OK);

  if (finger.image2Tz(2) != FINGERPRINT_OK) {
    Serial.println("Failed to convert second image.");
    return false;
  }

  if (finger.createModel() != FINGERPRINT_OK) {
    Serial.println("Fingerprint does not match.");
    return false;
  }

  if (finger.storeModel(userID) != FINGERPRINT_OK) {
    Serial.println("Failed to store fingerprint.");
    return false;
  }

  Serial.println("Fingerprint enrolled successfully!");
  return true;
}

// Verify fingerprint for voting
bool verifyFingerprint() {
  Serial.println("Place finger to verify...");

  if (finger.getImage() != FINGERPRINT_OK) {
    Serial.println("No fingerprint detected.");
    return false;
  }

  if (finger.image2Tz(1) != FINGERPRINT_OK) {
    Serial.println("Failed to convert fingerprint.");
    return false;
  }

  int fingerprintID = finger.fingerSearch();
  if (fingerprintID == FINGERPRINT_OK) {
    //Serial.print("Fingerprint verified with ID #"); 
    Serial.println(finger.fingerID);
    return true;
  } else {
    //Serial.println("Fingerprint not recognized.");
    return false;
  }
}