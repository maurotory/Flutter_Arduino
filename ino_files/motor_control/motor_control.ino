#include <SoftwareSerial.h>
#include <math.h> 


//bluetooth
SoftwareSerial hc06(2,3);// in the hc06 Tx=2, Rx=3 (meaning in arduino Tx=3, Rx=2)
char data_hc06;
String cmd;
int power = 255;


//Distance Sensor
int sensorpin = A0;                
int distance = 0;
bool reading = false;
bool automatic = false;
int counter =0;


//Motor controler
 

int enA = 5;
int enB = 6;
int In1 = 8;
int In2 = 9;
int In3 = 10;
int In4 = 11;



void setup() {
  
  Serial.begin(9600);
  hc06.begin(57600);
  pinMode(enA, OUTPUT);
  pinMode(In1, OUTPUT);
  pinMode(In2, OUTPUT);
  pinMode(In3, OUTPUT);
  pinMode(In4, OUTPUT);

  digitalWrite(In1, LOW);
  digitalWrite(In2, LOW);
  digitalWrite(In3, LOW);
  digitalWrite(In4, LOW);
  analogWrite(enA, 0);
  analogWrite(enB, 0);

  cmd = "";
               
}
 
void loop(){
  
  if (automatic == false){
      distance = analogRead(sensorpin);

      if (distance > 500 ){
        analogWrite(enA, 0);
        Serial.println(distance);
        _stop();
      }
  
      while(hc06.available()>0){
        
              data_hc06 = hc06.read();
              //Serial.print("Data received: ");
              //Serial.println(data_hc06);

                  if(reading == false){
                    
                        if (data_hc06 == 'p'){
                          Serial.println("p");
                          reading = true;
                          cmd ="";
                        }
                         
                        else if ( data_hc06 == 'f'){
                          goForward(power);
                          Serial.println("f");
                        }
          
                        else if ( data_hc06 == 'b'){
                          goBackwards(power);
                          Serial.println("b");
                        }
                    
                        else if ( data_hc06 == 's'){
                          _stop();
                          Serial.println("s");
                              
                        }
                    
                        else if ( data_hc06 == 'l'){
                          turnLeft(power);
                          Serial.println("l");
                        }
                    
                        else if ( data_hc06 == 'r'){
                          turnRight(power);
                          Serial.println("r");
                        }
                        else if(data_hc06 == 'a'){
                          automatic = true;
                          Serial.println("a");
                        }
                
                    }

                    else if(reading == true){
                      Serial.print("reading");
                        if (data_hc06 == 'o'){
                          reading = false;
                          
                          Serial.print("Data receiverd: ");
                          Serial.print("o");
                          power = cmd.toInt();
                          Serial.print(power);
                          goForward(power);
                          cmd="";
                        }
                    
                        else {
                          
                          Serial.println(data_hc06);
                          cmd = cmd+data_hc06;
                          Serial.println(cmd);
                        }

                     
                    }
               
      }
  }
  
  else if(automatic == true){
    goForward(power);
      while(hc06.available()>0){
        
              data_hc06 = hc06.read();
             if (data_hc06 == 'c'){
              Serial.println("c");
                automatic = false;
                                          Serial.print("Data receiverd: ");
                          Serial.println(data_hc06);
                          goForward(power);
                
             }
      }

      
      distance = analogRead(sensorpin);
      if (distance > 500 ){
        analogWrite(enA, 0);
        Serial.println(distance);
        goBackwards(power);
        delay(2000);
        counter = counter + 1;
        

        if(pow(-1.0, counter) == 1.0){
          turnRight(power);
          delay(2000);
        }
        else if(pow(-1.0, counter) == -1.0){
          turnLeft(power);
          delay(2000);
        }
      
        
      }
  
  }

 
}





void goForward(int power){
      analogWrite(enA, power);
      analogWrite(enB, power);
      digitalWrite(In1, HIGH);
      digitalWrite(In2, LOW);
      digitalWrite(In3, LOW);
      digitalWrite(In4, HIGH);


}


void goBackwards(int power){
      analogWrite(enA, power);
      analogWrite(enB, power);
      digitalWrite(In1, LOW);
      digitalWrite(In2, HIGH);
      digitalWrite(In3, HIGH);
      digitalWrite(In4, LOW);
}


void turnRight(int power) {
      analogWrite(enA, power);
      analogWrite(enB, power);
      digitalWrite(In1, LOW);
      digitalWrite(In2, HIGH);
      digitalWrite(In3, LOW);
      digitalWrite(In4, HIGH);
  

}


void turnLeft(int power) {
      analogWrite(enA, power);
      analogWrite(enB, power);
      digitalWrite(In1, HIGH);
      digitalWrite(In2, LOW);
      digitalWrite(In3, HIGH);
      digitalWrite(In4, LOW);
  

}


void _stop(){
      analogWrite(enA, 0);
      analogWrite(enB, 0);
      digitalWrite(In1, LOW);
      digitalWrite(In2, LOW);
      digitalWrite(In3, LOW);
      digitalWrite(In4, LOW);
}
