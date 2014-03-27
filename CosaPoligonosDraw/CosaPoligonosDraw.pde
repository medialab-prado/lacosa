
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
int currentColor = 0;
String[] ordenPaneles = {
  "patilla", "morro", "cuello", "panza",
  "paredesplanta1", "techoplanta1", "paredesplanta2", "techoplanta2", "techoplanta2"
};
ArrayList<Polygon> poligonosOrd = new ArrayList();
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
ArrayList particles = new ArrayList();

float boometro = 0;
float pitchFollower = 0;

color currentColorPitch = 0;

public void setup() {
  size(1024, 768, P3D);
  loadData();
  for (int i= 0;i<ordenPaneles.length;i++) {
    for (Polygon p : polygons) {
      if ( p.name.equals(ordenPaneles[i])) {
        poligonosOrd.add(p);
      }
    }
  }

  oscP5 = new OscP5(this, 12000);
  volumeValues=new float[SAMPLES];
  cp5 = new ControlP5(this);

  // add a horizontal sliders, the value of this slider will be linked
  // to variable 'sliderValue' 
  cp5.addSlider("UMBRAL")
    .setPosition(100, 75).setSize(300, 30)
      .setRange(0, 0.3).setValue(0.03);
}

public void draw() {
  //println(UMBRAL);
  update();
  if(modoFuncionamiento == HABLANDO)
    background(20);

  if (modoFuncionamiento == DISPARO) {
    for (Polygon p : polygons) {
      //p.drawMode = 0;
      //p.c = color( map(pitch, 20, 800, 0, 255), 200, map(volume, 0.0, 1.0, 0, 255));
      // p.draw(g);
    }
  }
  else if (modoFuncionamiento == HABLANDO) {
    /*for (int i = 0; i< ordenPaneles.length;i++)
     for (Polygon p : polygons) {
     if ( p.name.equals(ordenPaneles[i])) {
     p.drawMode = 2;
     p.c = color( 255, 0, 0);//map(pitch, 20, 800, 0, 255),  map(volume, 0.2, 1.0, 0, 255), 200);
     p.draw(g);
     }
     }*/

    float dif = (volume * 3 - boometro );
    //println(dif);
    if(dif < 0)
      boometro +=  dif * 0.05;
     else
      boometro +=  dif * 0.1;
    
    pitchFollower += (pitch/3 - pitchFollower ) * 0.05;
    
    //boometro = volume * 1.3;
  
    colorMode(HSB, 100);  

    color currentColorTemp = color( map(pitchFollower, 20, 400, 0, 255),  map(boometro, 0.2, 1.0, 0, 255), 200);

    Polygon p = (Polygon)poligonosOrd.get(0);
    p.drawMode = 3;
    p.c = currentColorTemp;
    p.llenadoCantidad = boometro * 3.33;
    p.draw(g);

    if (boometro > 0.33) {
      Polygon pp = (Polygon)poligonosOrd.get(1);
      pp.drawMode = 3;
      //pp.c = color( map(pitch, 20, 400, 0, 100),  map(volume, 0.2, 1.0, 0, 100), 50);
      pp.c = currentColorTemp;
      pp.llenadoCantidad = (boometro-0.33) * 3.33;
      pp.draw(g);
      
      currentColorPitch = currentColorTemp;
    }
    if (boometro > 0.66) {
      Polygon pp = (Polygon)poligonosOrd.get(2);
      pp.drawMode = 3;
      pp.c = currentColorTemp;
      pp.llenadoCantidad = (boometro-0.66) * 3.33;
      pp.draw(g);
      currentColorPitch = currentColorTemp;
    }
  }  
  else if (modoFuncionamiento == SALVAPANTALLAS) {
    for (Polygon p : polygons) {
      //p.drawMode = 1;
      //p.c = color( 200, 200, 200);
      // p.draw(g);
    }
  }
  ArrayList delpp = new ArrayList();
  for (int i = 0;i<particles.size();i++) {
    Particle p = (Particle)particles.get(i);
    if (!p.died) {
      p.draw(g);
    }
    else {
      delpp.add(p);
    }
  }
  particles.removeAll(delpp);

  if (!calladoAhora) {
    stroke(255);
    fill(255, 255, 0);
    rect(10, 10, boometro*width, 20);
    fill(255, 0, 255);
    rect(10, 50, pitchFollower, 20);
    text(pitchFollower,0, 50);
    fill(0, 255, 255);
    rect(10, 80, currentVol, 20);
  }

  fill(0, 255, 255);
  //Paredes de primera planta
  //rect(0, 190, 800, 150);
  // Techo primera planta
//  rect(731, 322, 100, 100);

  // Segunda planta
  fill(255, 255, 0);    
  //rect(783, 203, 500, 150);
  //rect(0, 342, 500, 150);
  //rect(0, 442, 500, 150);

  fill(255);
  text("modoFuncionamiento " + modoFuncionamiento, 100, 10);
  
  //poligonosOrd.get(poligonosOrd.size()-1).draw(g);
}

boolean silencio = false;
int lastDisparoMillis = 0;
int disparoPeriodMillis = 1000;


void update() {

  //println(counterVV);
  

  boolean empiezahablar = false;
  if (counterVV==0) {
    currentVol=sumVolume();         
    if ( currentVol<UMBRAL) { 
      if (calladoAhora==false) {
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
    boolean cambiaahora = false;
    if (acabaDeCallarse == true) {
        if(boometro<0.33){
          cambiaahora = true;
        }
    }
    
    if(cambiaahora){
      modoFuncionamiento = DISPARO; 
      Particle p = new Particle();
      p.init(200, currentColorPitch,0);
      particles.add(p);
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
  } 
  else if (modoFuncionamiento == DISPARO) {
    if (lastDisparoMillis < millis()) {
      modoFuncionamiento = SALVAPANTALLAS;
    }
    acabaDeCallarse = false;
  } 

  else if (modoFuncionamiento == SALVAPANTALLAS) {
    if (!calladoAhora) {
      modoFuncionamiento = HABLANDO;
      Polygon p = (Polygon)poligonosOrd.get(0);
      p.llenadoCantidad = 0;
    }
    acabaDeCallarse = false;
  }
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
  counterVV++; 
  if (counterVV>=SAMPLES) counterVV=0;
  //println(" Received: "+pitch+", " + volume);
}


float sumVolume() {
  float sumVol=0;
  for (int i=0; i<volumeValues.length; i++) {
    sumVol+=volumeValues[i];
  }
  return sumVol/SAMPLES;
}
