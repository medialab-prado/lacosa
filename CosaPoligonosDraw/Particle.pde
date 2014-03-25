public class Particle {

  Polygon p;
  long nextChange = 0;
  boolean died = false;
  int vel = 500;
  int current = 0;

  public void init( int vel) {
    this.vel = vel;
    
    nextChange = millis() + vel;
    p =  (Polygon) poligonosOrd.get(current);
  }


  public void draw(PGraphics canvas) {

    p.draw(canvas);

    if (millis() > nextChange) {
      nextPolygon();
      nextChange = millis() + vel;
    }
  }

  private void nextPolygon() {
    current ++;
    if(current < poligonosOrd.size()-1)
       p =  (Polygon) poligonosOrd.get(current);
   else
   died = true;
  }
}

