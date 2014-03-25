
import java.util.List;
import oscP5.*;
import netP5.*;
import controlP5.*;

ControlP5 cp5;
/**
 * Loading XML Data
 * by Daniel Shiffman.  
 * 
 * This example demonstrates how to use loadJSON()
 * to retrieve data from a JSON file and make objects 
 * from that data.
 *
 * Here is what the JSON looks like (partial):
 *
 {
 "bubbles": [
 {
 "position": {
 "x": 160,
 "y": 103
 },
 "diameter": 43.19838,
 "label": "Happy"
 },
 {
 "position": {
 "x": 372,
 "y": 137
 },
 "diameter": 52.42526,
 "label": "Sad"
 }
 ]
 }
 */

static int DISPARO = 0;
static int HABLANDO = 1;
static int SALVAPANTALLAS = 2;

float [] volumeValues;
int counterVV=0;
static int SAMPLES=4;
float UMBRAL=0.1;
boolean calladoAhora=false;
float currentVol=0;
boolean acabaDeCallarse=false;
String[] ordenPaneles = {
  "patilla", "morro", "cuello", "panza", "miembro1", "miembro3", "miembro2"
};
int panelActual = 0;

OscP5 oscP5;
NetAddress myRemoteLocation;
Polygon[] polygons;
// A JSON object
JSONObject json;
int mode = 0;
float volume = 0;
float pitch = 0;
int modoFuncionamiento = 1;
public void setup() {
  size(1024, 768, P3D);
  loadData();
  
  oscP5 = new OscP5(this, 12000);
  volumeValues=new float[SAMPLES];
  cp5 = new ControlP5(this);
  
  // add a horizontal sliders, the value of this slider will be linked
  // to variable 'sliderValue' 
  cp5.addSlider("UMBRAL")
     .setPosition(100,50).setSize(300,30)
     .setRange(0,0.3).setValue(0.03);
}

public void draw() {
  println(UMBRAL);
  update();
  if(silencio){
    background(255);
    silencio = false;
  } else {
   background(0); 
  }
  
  
  
  
  if (modoFuncionamiento == DISPARO) {
    for (Polygon p : polygons) {
      p.c = color( map(pitch, 20, 800, 0, 255), 200, map(volume, 0.0, 1.0, 0, 255));
      p.draw(g);
    }
  }
  else if (modoFuncionamiento == HABLANDO) {
    for (int i = 0; i< panelActual;i++)
      for (Polygon p : polygons) {
        if ( p.name.equals(ordenPaneles[i])){
          p.c = color( map(pitch, 20, 800, 0, 255),  map(volume, 0.2, 1.0, 0, 255), 200);
          p.draw(g);
        }
      }
  }  
  else if(modoFuncionamiento == SALVAPANTALLAS) {
     for (Polygon p : polygons) {
      p.c = color( 200, 200, 200);
      p.draw(g);
    }   
  }
  
  if(!calladoAhora){
  stroke(255);
  fill(255,255,0);
  rect(10,10,volume*width,20);
  fill(255,0,255);
  rect(10,50,pitch,20);
   fill(0,255,255);
  rect(10,80,currentVol,20);
  
  }
}

boolean silencio = false;
int lastDisparoMillis = 0;
int disparoPeriodMillis = 5000;


void update() {
 
  //println(counterVV);
  if(counterVV==0){
     currentVol=sumVolume();         
     if( currentVol<UMBRAL){ 
       if(calladoAhora==false){
        //Aquí está el cambio de estado  
          acabaDeCallarse=true;
       }       
        calladoAhora=true;
     }
     else {
       calladoAhora=false;
     }
   }
   
   if (modoFuncionamiento == HABLANDO) {
      if(acabaDeCallarse == true){
         modoFuncionamiento = DISPARO; 
         acabaDeCallarse = false;
         lastDisparoMillis = millis() + disparoPeriodMillis;
       }
   /*
    if (frameCount % 60 == 0) {
      panelActual = (panelActual + 1) % ordenPaneles.length;
      if (panelActual == 0)
        modoFuncionamiento = DISPARO;
    }
    */
  } else if (modoFuncionamiento == DISPARO) {
    if(lastDisparoMillis > millis()){
      modoFuncionamiento = SALVAPANTALLAS;
    }
  } else if(modoFuncionamiento == SALVAPANTALLAS) {
    if(!calladoAhora){
      modoFuncionamiento = HABLANDO;
    }
  }
  
   println("modoFuncionamiento " + modoFuncionamiento);

}

public void loadData() {
  // Load JSON file
  // Temporary full path until path problem resolved.
  json = loadJSONObject("data.json");

  JSONArray bubbleData = json.getJSONArray("polygons");

  // The size of the array of Bubble objects is determined by the total
  // XML elements named "bubble"
  polygons = new Polygon[bubbleData.size()];

  for (int i = 0; i < bubbleData.size(); i++) {
    // Get each object in the array
    JSONObject polygonData = bubbleData.getJSONObject(i);
    // Get a position object
    JSONArray points = polygonData.getJSONArray("points");
    String name = polygonData.getString("name");
    Polygon polygon = new Polygon(name);
    for (int j = 0; j < points.size(); j++) {
      JSONObject pointData = points.getJSONObject(j);
      polygon.addPoint(new PVector(pointData.getFloat("x"), pointData
        .getFloat("y")));
    }

    // Put object in array
    polygons[i] = polygon;
  }
}

public void keyPressed() {
  if (key == ' ') {
    mode = (mode + 1 ) % 3;
    for (Polygon p:polygons)
      p.setMode(mode);
  }
}

public void mousePressed() {
  if (true) {
    return;
  }
  // Create a new JSON bubble object
  JSONObject newBubble = new JSONObject();

  // Create a new JSON position object
  JSONObject position = new JSONObject();
  position.setInt("x", mouseX);
  position.setInt("y", mouseY);

  // Add position to bubble
  newBubble.setJSONObject("position", position);

  // Add diamater and label to bubble
  newBubble.setFloat("diameter", random(40, 80));
  newBubble.setString("label", "New label");

  // Append the new JSON bubble object to the array
  JSONArray bubbleData = json.getJSONArray("bubbles");
  bubbleData.append(newBubble);

  if (bubbleData.size() > 10) {
    bubbleData.remove(0);
  }

  // Save new data
  saveJSONObject(json, "data/data.json");
  loadData();
}

void oscEvent(OscMessage theOscMessage) {
  //print("### received an osc message.");
  pitch = theOscMessage.get(0).floatValue();  
  volume = theOscMessage.get(1).floatValue();
  volumeValues[counterVV]=volume;
  counterVV++; if(counterVV>=SAMPLES) counterVV=0;
  //println(" Received: "+pitch+", " + volume);
}


float sumVolume(){
  float sumVol=0;
  for (int i=0; i<volumeValues.length; i++){
    sumVol+=volumeValues[i];
  }
  return sumVol/SAMPLES;
}
