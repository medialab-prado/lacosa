// A Bubble class

public class Polygon {

  String name;
  List<PVector> rawPoints = new ArrayList<PVector>();  
  boolean over = false;
  color c;
  
  // Create  the Bubble
  public Polygon(String name) {
    this.name = name;
    c = color(random(255),random(255),random(255));
  }
  
  public void setColor(color c){
     this.c = c; 
  }
  
  public void addPoint(PVector point){
     rawPoints.add(point); 
  }
  
  public void draw(PGraphics canvas){
    canvas.noStroke();
      canvas.beginShape();
      canvas.fill(c);
      for(int i = 0;i<rawPoints.size();i++){
        PVector p = rawPoints.get(i);
       canvas.vertex(p.x,p.y); 
      }
      canvas.endShape();
  }
  
  
}
