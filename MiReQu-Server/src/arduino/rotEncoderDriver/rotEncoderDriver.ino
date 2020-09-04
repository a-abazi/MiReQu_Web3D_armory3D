#include <Encoder.h>    // Verwendung der <Encoder.h> Bibliothek 

const byte numChars = 32;
char receivedChars[numChars];
boolean newData = false;

const int CLK00 = A0;      // Definition der Pins. CLK an D6, DT an D5. 
const int DT00 = A1;
const int SW00 = A2;       // Der Switch wird mit Pin D2 Verbunden. ACHTUNG : Verwenden Sie einen interrupt-Pin!
long pos00 = -999;  // Definition der "alten" Position (Diese fiktive alte Position wird benötigt, damit die aktuelle Position später im seriellen Monitor nur dann angezeigt wird, wenn wir den Rotary Head bewegen)

Encoder meinEncoder00(DT00,CLK00);  // An dieser Stelle wird ein neues Encoder Projekt erstellt. Dabei wird die Verbindung über die zuvor definierten Varibalen (DT und CLK) hergestellt.



void setup() {
    Serial.begin(9600);
    Serial.println("<Arduino is ready>");
    
    pinMode(SW00, INPUT);   // Hier wird der Interrupt installiert.
  
    attachInterrupt(digitalPinToInterrupt(SW00), Interrupt, CHANGE); // Sobald sich der Status (CHANGE) des Interrupt Pins (SW = D2) ändern, soll der Interrupt Befehl (onInterrupt)ausgeführt werden.
}

void loop() {
  long neuePosition = meinEncoder00.read();  // Die "neue" Position des Encoders wird definiert. Dabei wird die aktuelle Position des Encoders über die Variable.Befehl() ausgelesen. 

  if (neuePosition != pos00)  // Sollte die neue Position ungleich der alten (-999) sein (und nur dann!!)...
  {     
    pos00 = neuePosition;       
  }
    
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
