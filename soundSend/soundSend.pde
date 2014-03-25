import processing.opengl.*;

import javax.swing.JFileChooser;

import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.*;

import oscP5.*;
import netP5.*;

//PitchDetectorAutocorrelation PD; //Autocorrelation
//PitchDetectorHPS PD; //Harmonic Product Spectrum -not working yet-
PitchDetectorFFT PD; // Naive
AudioSource AS;
Minim minim;
//Some arrays just to smooth output frequencies with a simple median.
float []freq_buffer = new float[10];
float []sorted;
int freq_buffer_index = 0;

long last_t = -1;
float avg_level = 0;
float last_level = 0;
String filename;
float begin_playing_time = -1;
OscP5 oscP5;
NetAddress myRemoteLocation;
float [] volumeValues;
int counterVV=0;
static int SAMPLES=4;
static float UMBRAL=0.03;
boolean calladoAhora=false;
float currentVol=0;
void setup()
{
  size(600, 400);
  frameRate(60);
  smooth();
  fill(0); 
  minim = new Minim(this);
  //minim.debugOn();
  volumeValues=new float[SAMPLES];
  AS = new AudioSource(minim);
 
  /*
  // Choose .wav file to analyze
  boolean ok = false;
  while (!ok) {
    JFileChooser chooser = new JFileChooser();
    chooser.setFileFilter(chooser.getAcceptAllFileFilter());
    int returnVal = chooser.showOpenDialog(null);
    if (returnVal == JFileChooser.APPROVE_OPTION) {
    filename = chooser.getSelectedFile().getPath();
      AS.OpenAudioFile(chooser.getSelectedFile().getPath(), 5, 512); //1024 for AMDF
      ok = true;
    }
  }
  */

  // Comment the previous block and uncomment the next line for microphone input
  AS.OpenMicrophone();

  PD = new PitchDetectorFFT();
  PD.ConfigureFFT(2048, AS.GetSampleRate());
   //PD = new PitchDetectorAutocorrelation();  //This one uses Autocorrelation
  //PD = new PitchDetectorHPS(); //This one uses Harmonit Product Spectrum -not working yet-
  PD.SetSampleRate(AS.GetSampleRate());
  AS.SetListener(PD);
  
  //rectMode(CORNERS);
 /* background(0);
  fill(0);
  stroke(255);*/
  oscP5 = new OscP5(this,12001);
  myRemoteLocation = new NetAddress("127.0.0.1",12000);
  
}


void draw()
{
  if (begin_playing_time == -1)
  begin_playing_time = millis();
  float f = 0;
  float level = AS.GetLevel();
  long t = PD.GetTime();
  if (t == last_t) return;
  last_t = t;
  int xpos = (int)t % width;
  if (xpos >= width-1) {
    // rect(0,0,width,height);
  }

  f = PD.GetFrequency();


  pushMatrix();
  stroke(level * 255.0 * 10.0);
  line(xpos, height, xpos, height - f / 5.0f);
  popMatrix();
  avg_level = level;
  last_level = f;

  fill(255); 
  rect(50,50,300,200);
 
 if(frameCount%3==0){
    OscMessage myMessage = new OscMessage("/sonido");  
    myMessage.add(f); /* add an int to the osc message */
    myMessage.add(level); /* add a float to the osc message */    
    volumeValues[counterVV]=level;
    counterVV++; if(counterVV>=SAMPLES) counterVV=0;    
    fill(255);    
    oscP5.send(myMessage, myRemoteLocation);     

  }  
    if(calladoAhora==false){
      fill(0,0,0);
      text ("frecuency: " +f, 100,100);
      text ("Level: " + level, 100,130);
    }

   fill(0,0,0);
   text ("frate: " + frameRate, 100,180);  
 
   if(counterVV==0){
     currentVol=sumVolume();         
     if( currentVol<UMBRAL){ 
       if(calladoAhora==false){
        //Aquí está el cambio de estado
         fill(255,0,0);
         rect(50,50,200,200);                 
        }       
        text ("silencio! ", 100,150); 
        calladoAhora=true;        
     }
     else {
        text ("hablando! ", 100,150);
        //println("hablando");
       calladoAhora=false;
     }
   }
   text ("currentVol: " + currentVol, 100,200); 
 
}

float sumVolume(){
  float sumVol=0;
  for (int i=0; i<volumeValues.length; i++){
    sumVol+=volumeValues[i];
    //println(volumeValues[i]);
  }
  //println("");
  //println(sumVol/SAMPLES);
  return sumVol/SAMPLES;
}


void stop()
{
  AS.Close();

  minim.stop();

  println("Se acabo");

  super.stop();
}


