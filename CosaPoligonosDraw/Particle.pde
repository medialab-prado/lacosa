public class Particle {

  Polygon p;
  long nextChange = 0;
  boolean died = false;
  int vel = 500;
  int current = 0;

  public void init( int vel, color c) {
    this.vel = vel;
    nextChange = millis() + vel;
    p =  (Polygon) poligonosOrd.get(current);
    p.drawMode = (int)random(2);
    p.c = c;
  }


  public void draw(PGraphics canvas) {

    p.draw(canvas);

    if (millis() > nextChange) {
      nextPolygon();
      nextChange = millis() + vel;
    }
  }

  private void nextPolygon() {
    Polygon lastP = (Polygon) poligonosOrd.get(current);
    current ++;
    
    if(current < poligonosOrd.size()-1){
       p =  (Polygon) poligonosOrd.get(current);
       p.drawMode = lastP.drawMode;
       p.c = lastP.c;
       
    }else
     died = true;
  }
}

