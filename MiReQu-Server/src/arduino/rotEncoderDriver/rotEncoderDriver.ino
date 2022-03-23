#include <Encoder.h>    // Verwendung der <Encoder.h> Bibliothek 

const byte numChars = 32;
char receivedChars[numChars];
boolean newData = false;

const int ChA00 = 5;      // Definition der Pins
const int ChB00 = 12;
const int ChA01 = 8;      // Definition der Pins
const int ChB01 = 9;
const int ChA02 = 11;      // Definition der Pins
const int ChB02 = 6;



long pos00 = -999;  // Definition der "alten" Position (Diese fiktive alte Position wird benötigt, damit die aktuelle Position später im seriellen Monitor nur dann angezeigt wird, wenn wir den Rotary Head bewegen)
long pos02 = -999;  // Definition der "alten" Position (Diese fiktive alte Position wird benötigt, damit die aktuelle Position später im seriellen Monitor nur dann angezeigt wird, wenn wir den Rotary Head bewegen)
long pos01 = -999;  // Definition der "alten" Position (Diese fiktive alte Position wird benötigt, damit die aktuelle Position später im seriellen Monitor nur dann angezeigt wird, wenn wir den Rotary Head bewegen)

int sensorValue1 = 0;
int sensorValue2 = 0;

Encoder meinEncoder00(ChA00,ChB00);  // An dieser Stelle wird ein neues Encoder Projekt erstellt. Dabei wird die Verbindung über die zuvor definierten Varibalen (DT und CLK) hergestellt.
Encoder meinEncoder01(ChA01,ChB01);  // An dieser Stelle wird ein neues Encoder Projekt erstellt. Dabei wird die Verbindung über die zuvor definierten Varibalen (DT und CLK) hergestellt.
Encoder meinEncoder02(ChA02,ChB02);  // An dieser Stelle wird ein neues Encoder Projekt erstellt. Dabei wird die Verbindung über die zuvor definierten Varibalen (DT und CLK) hergestellt.



void setup() {
    Serial.begin(9600);
    Serial.println("<Arduino is ready>");
    analogReference(INTERNAL);
}

void loop() {
  long neuePosition00 = meinEncoder00.read();  // Die "neue" Position des Encoders wird definiert. Dabei wird die aktuelle Position des Encoders über die Variable.Befehl() ausgelesen. 
  long neuePosition01 = meinEncoder01.read();  // Die "neue" Position des Encoders wird definiert. Dabei wird die aktuelle Position des Encoders über die Variable.Befehl() ausgelesen. 
  long neuePosition02 = meinEncoder02.read();  // Die "neue" Position des Encoders wird definiert. Dabei wird die aktuelle Position des Encoders über die Variable.Befehl() ausgelesen. 
  
  if (neuePosition00 != pos00)  // Sollte die neue Position ungleich der alten (-999) sein (und nur dann!!)...
  {     
    pos00 = neuePosition00;       
  }

  if (neuePosition01 != pos01)  // Sollte die neue Position ungleich der alten (-999) sein (und nur dann!!)...
  {     
    pos01 = neuePosition01;       
  }

  if (neuePosition02 != pos02)  // Sollte die neue Position ungleich der alten (-999) sein (und nur dann!!)...
  {     
    pos02 = neuePosition02;       
  }

  sensorValue1 = analogRead(A2);
  sensorValue2 = analogRead(A1);
  
  recvWithStartEndMarkers();
  showNewData();

    
}

void recvWithStartEndMarkers() {
    static boolean recvInProgress = false;
    static byte ndx = 0;
    char startMarker = '<';
    char endMarker = '>';
    char rc;
 
    while (Serial.available() > 0 && newData == false) {
        rc = Serial.read();

        if (recvInProgress == true) {
            if (rc != endMarker) {
                receivedChars[ndx] = rc;
                ndx++;
                if (ndx >= numChars) {
                    ndx = numChars - 1;
                }
            }
            else {
                receivedChars[ndx] = '\0'; // terminate the string
                recvInProgress = false;
                ndx = 0;
                newData = true;
            }
        }

        else if (rc == startMarker) {
            recvInProgress = true;
        }
    }
}

void showNewData() {
    if (newData == true) {
        if (receivedChars[0]=='g'){
          if (receivedChars[4]=='0') {
          Serial.println(pos00);
          }
          if (receivedChars[4]=='1') {
          Serial.println(pos01);
          }
          if (receivedChars[4]=='2') {
          Serial.println(pos02);
          }
        }        
        if (receivedChars[0]=='a'){
          if (receivedChars[4]=='1') {
          Serial.println(sensorValue1);
          }
          if (receivedChars[4]=='2') {
          Serial.println(sensorValue2);
          }
        }

        
        if (receivedChars[0]=='c'){ // used as check for connection
          Serial.println("ready");
          
        }
        
        newData = false;
    }
}

void Interrupt() // Beginn des Interrupts. Wenn der Rotary Knopf betätigt wird, springt das Programm automatisch an diese Stelle. Nachdem...

{
  Serial.println("Switch betaetigt"); //... das Signal ausgegeben wurde, wird das Programm fortgeführt.

}
