import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.opengl.*; 
import javax.swing.JFileChooser; 
import ddf.minim.analysis.*; 
import ddf.minim.effects.*; 
import ddf.minim.signals.*; 
import ddf.minim.*; 
import ddf.minim.*; 
import ddf.minim.analysis.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class PitchProject extends PApplet {












//PitchDetectorAutocorrelation PD; //Autocorrelation
//PitchDetectorHPS PD; //Harmonic Product Spectrum -not working yet-
PitchDetectorFFT PD; // Naive
AudioSource AS;
Minim minim;
pong myPong;
//Some arrays just to smooth output frequencies with a simple median.
float []freq_buffer = new float[10];
float []sorted;
int freq_buffer_index = 0;

long last_t = -1;
float avg_level = 0;
float last_level = 0;
String filename;
float begin_playing_time = -1;

public void setup()
{
  size(600, 400);
    smooth();
  fill(0); 
  minim = new Minim(this);
  minim.debugOn();
  
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
}


public void draw()
{
   
   
   
   //pushMatrix();
   //translate(0,600);
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

  /*freq_buffer[freq_buffer_index] = f;
  freq_buffer_index++;
  freq_buffer_index = freq_buffer_index % freq_buffer.length;
  sorted = sort(freq_buffer);

  f = sorted[5];*/

pushMatrix();
  stroke(level * 255.0f * 10.0f);
  line(xpos, height, xpos, height - f / 5.0f);
  popMatrix();
  avg_level = level;
  last_level = f;
  if(level>0.12f){  
    print ("frecuency: " +f);
    print ("Level: " +level);
  }
 // popMatrix();
}



public void stop()
{
  AS.Close();

  minim.stop();

  println("Se acabo");

  super.stop();
}






class AudioSource
{
  Minim minim;
  AudioPlayer wav_file;
  AudioInput microphone;
  Boolean reading_file;


  AudioSource(Minim m) {
    this.minim = m;
    reading_file = false;
  }  
  
  public void Close() {
    if (reading_file)
      wav_file.close();
    else
      microphone.close();
  }
  
  public void SetListener(AudioListener listener) {
    if (reading_file)
      wav_file.addListener (listener);
    else
      microphone.addListener (listener);
  }
  
  public void OpenAudioFile(String filename, int loops, int buffersize) {
    reading_file = true;
    wav_file = minim.loadFile(filename, buffersize);
    wav_file.loop(loops);  
  }
  
  public void OpenMicrophone () {
    microphone = minim.getLineIn(Minim.MONO, 2048, 44100);
  }
  
  public float GetSampleRate() {
    if (reading_file)
      return wav_file.sampleRate();
    else
      return microphone.sampleRate();
  }
  
  public float GetLevel() {
    if (reading_file)
      return wav_file.mix.level();
    else
      return microphone.mix.level();
  }
};
/* R2D2 Pitch Processing
 * 
 * Audio analysis for pitch extraction
 * 
 * TODO: Both PitchDetectorHPS and this class should inherit from a base PitchDetector class...
 *
 * L. Anton-Canalis (info@luisanton.es) 
 */

class PitchDetectorAutocorrelation implements AudioListener { 
  float sample_rate = 0;
  float last_period = 0;
  float current_frequency = 0;
  long t;
  
   final float F0min = 50;
   final float F0max = 400;
   int min_shift;
   int max_shift;
   
   
  PitchDetectorAutocorrelation () {
    t = 0;
  }
  
  // We could as well store a vector with frequencies and return a smoothed value. 
  public synchronized void StoreFrequency(float f) {
    current_frequency = f;
  }
  
  public synchronized float GetFrequency() {
    return current_frequency;
  }
  
  public void SetSampleRate(float s) {
     sample_rate = s;
     float tmin = 1.0f / F0max;
     float tmax = 1.0f / F0min;
     min_shift = PApplet.parseInt( tmin * sample_rate ); 
     max_shift = PApplet.parseInt( tmax * sample_rate );
     System.out.println(min_shift + " " + max_shift);
     last_period = max_shift;
     t = 0;
  }
  
  public synchronized void samples(float[] samp) {
    AMDF(samp);
  }
  
  public synchronized void samples(float[] sampL, float[] sampR) {
    AMDF(sampL);
  }
  
  public synchronized long GetTime() {
    return t;
  }
 
  public void AMDF (float []audio) {
    t++;
    int buffer_index = 0;
				
    float max_sum = 0;   
    int period = 0;
    for (int shift = min_shift; shift < max_shift; shift++)
    {  
      // Assigh higher weights to lower frequencies
      // and even higher to periods that are closer to the last period (quick temporal coherence hack)
      float mod = (float)(shift - min_shift) / (float)(max_shift - min_shift);
      mod *= 1.0f - 1.0f / (1.0f + abs(shift - last_period));
      
      // Compare samples with shifted samples using autocorrelation
      float dif = 0;
      for (int i = shift; i < audio.length; i++)
        dif += audio[i] * audio[i - shift];		
        
      // Apply weight
      dif *= 1.0f + mod;
     
      if (dif > max_sum)
      {
        max_sum = dif;			 
        period = shift;
      }
    }	
    
    if (period != 0)
    {
      last_period = period;
      float freq = 1.0f / (float)period;
      freq *= (float)sample_rate;			  
      StoreFrequency(freq);
      buffer_index += period + min_shift;		  
    }
    else {
      last_period = (max_shift + min_shift) / 2;
      StoreFrequency(0);
      buffer_index += min_shift;
    }
  }
};
/* R2D2 Pitch Processing
 * 
 * Audio analysis for pitch extraction 
 * 
 * Looks for FFT bin with highest energy. Quite naive...
 *
 * L. Anton-Canalis (info@luisanton.es) 
 */

class PitchDetectorFFT implements AudioListener { 
  float sample_rate = 0;
  float last_period = 0;
  float current_frequency = 0;
  long t;
  
  FFT fft;
  
  final float F0min = 50;
  final float F0max = 400;
   
   
  PitchDetectorFFT () {
  }
  
  public void ConfigureFFT (int bufferSize, float s) {
       fft = new FFT(bufferSize, s); 
       fft.window(FFT.HAMMING);
       SetSampleRate(s);
  }
  
  public synchronized void StoreFrequency(float f) {
    current_frequency = f;
  }
  
  public synchronized float GetFrequency() {
    return current_frequency;
  }
  
  public void SetSampleRate(float s) {
     sample_rate = s;
     t = 0;
  }
  
  public synchronized void samples(float[] samp) {
    FFT(samp);
  }
  
  public synchronized void samples(float[] sampL, float[] sampR) {
    FFT(sampL);
  }
  
  public synchronized long GetTime() {
    return t;
  }
 
  public void FFT (float []audio) {
    t++;
    float highest = 0;
    int highest_bin = 0;
    fft.forward(audio);
    int max_bin =  fft.freqToIndex(10000.0f);

    for (int n = 0; n < max_bin; n++) {
       if (fft.getBand(n) > highest) {
         highest = fft.getBand(n);
         highest_bin = n;
       }

      // if (fft.getBand(n)/(n+1) > fft.getBand(highest)/(highest+1))
      //   highest = n;
    }


    /* for(int n = fft.specSize()-1; n > 0; n--) {
       float current_frec = n * 0.5 * sample_rate / float(audio.length);
       float bin_sum = fft.getBand(n);
       int multiple_bin = fft.freqToIndex(current_frec * 0.5f);
       int last_bin = multiple_bin;
       
       if (bin_sum > highest) {
         highest_bin = n;
         highest = (int)bin_sum;
       }
         
       
      // if (fft.getBand(n)/(n+1) > fft.getBand(highest)/(highest+1))
      //   highest = n;
    }*/
    
    
    
    float freq = highest_bin * 0.5f * sample_rate / PApplet.parseFloat(audio.length);
    StoreFrequency(freq);
  }
};
/* R2D2 Pitch Processing
 * 
 * Audio analysis for pitch extraction 
 * 
 * TODO: Both PitchDetectorHPS and this class should inherit from a base PitchDetector class...
 *
 * L. Anton-Canalis (info@luisanton.es) 
 */



class PitchDetectorHPS implements AudioListener { 
  float sample_rate = 0;
  float last_frequency = 0;
  float last_period = 0;
  float current_frequency = 0;
  long t;
  FFT fft;
  float [] x2;
  float [] x3;
  float [] x4;
  float [] x5;

  PitchDetectorHPS () {
    t = 0;
    fft = null;
  }
  
  public void SetSampleRate(float s) {
	sample_rate = s;
  }
  
  public synchronized void StoreFrequency(float f) {
    last_frequency = current_frequency;  
    current_frequency = f;
  }
  
  
  public synchronized float GetFrequency() {
	return current_frequency;
  }
  
  public synchronized void samples(float[] samp) {
    HSP(samp);
  }
  
  public synchronized void samples(float[] sampL, float[] sampR) {
    HSP(sampL);
  }
  
  public synchronized long GetTime() {
    return t;
  }
 
  public void HSP (float []audio) {
    t++;
    
    // Create fft and support arrays if they don't exist.
    if (fft == null) {
       fft = new FFT(audio.length, sample_rate);
       x2 = new float[fft.specSize()];
       x3 = new float[fft.specSize()];
       x4 = new float[fft.specSize()];
       x5 = new float[fft.specSize()];
    }
    
    fft.forward(audio);
    
    // Downsample power spectrum
    for(int i = 0; i < fft.specSize(); i++)
    {
       if (i % 2 == 0) x2[i/2] = fft.getBand(i);
       if (i % 3 == 0) x3[i/3] = fft.getBand(i);
       if (i % 4 == 0) x4[i/4] = fft.getBand(i);
       if (i % 5 == 0) x5[i/5] = fft.getBand(i);
    }
    
    // Multiply original and downsampled version.
    // Find index of maximum product (HSP)
    float hps = 0;
    int bin = 0;
    for(int i = 0; i < fft.specSize()/5; i++)
    {
      float sum = 0;
      sum = fft.getBand(i) * x2[i] * x3[i] * x4[i] * x5[i];
      
      if (sum > hps) {
        hps = sum;
        bin = i;
      }
    }
    
    
    StoreFrequency(bin * fft.getBandWidth());	
  }	  
};
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--hide-stop", "PitchProject" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
