const byte numPins = 8; // how many bits
byte pins[] = {2, 3, 4, 5, 6, 7, 8, 9};
byte bits[] = {0, 0, 0, 0, 0, 0, 0, 0};

int dataIn = 0;
int dataRecorded = 0;

void setup(){
  /* we setup all led pins as OUTPUT */
  for(int i = 0; i < numPins; i++) {
    pinMode(pins[i], OUTPUT);
    digitalWrite(pins[i], LOW);
  }
  
  Serial.begin(9600);
//  Serial.println("Hello World");
}
void loop(){

  if(Serial.available() > 0){
    dataIn = Serial.read();
    Serial.print("Recieved data = ");
    Serial.println(dataIn);
    displayBinary(dataIn);
    //dataRecorded=0;
  }

}

void displayBinary(byte numToShow)
{
  for (int i =0;i<numPins;i++)
  {
    Serial.print("bit read = ");
    Serial.println(bitRead(numToShow, i)==1);
    
    if (bitRead(numToShow, i)==1)
    {
      digitalWrite(pins[i], HIGH); 
      
    }
    else
    {
      digitalWrite(pins[i], LOW); 
    }
  }

}
