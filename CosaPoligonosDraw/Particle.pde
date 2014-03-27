public class Particle {

  Polygon p;
  long nextChange = 0;
  boolean died = false;
  int vel = 500;
  int current = 0;
  int drawMode = 0;
  color c;

  public void init( int vel, color c, int drawMode) {
    this.vel = vel;
    nextChange = millis() + vel;
    p =  (Polygon) poligonosOrd.get(current);
    p.c = c;
    this.drawMode = drawMode;
    this.c = c;
  }


  public void draw(PGraphics canvas) {

    p.draw(canvas);

    if (millis() > nextChange) {
      nextPolygon();
      nextChange = millis() + vel;
      vel-=12;
    }
  }

  private void nextPolygon() {
    Polygon lastP = (Polygon) poligonosOrd.get(current);
    current ++;
    
    if(current < poligonosOrd.size()-1){
       p =  (Polygon) poligonosOrd.get(current);
       p.drawMode = drawMode;
       p.c = c;
       
    }else
     died = true;
  }
}
