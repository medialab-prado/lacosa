public class Particle {
  
  Polygon p;
  long nextChange = 0;
  boolean died = false;
  int vel = 500;
  
  public void init(Polygon p, int vel){
    this.vel = vel;
    this.p = p;
    nextChange = millis() + vel;
  }
  
  
  public void draw(PGraphics canvas){
     
     p.draw(canvas);
     
     if(millis() > nextChange){
         nextPolygon();
         nextChange = millis() + vel;
     }
    
  }
  
  private void nextPolygon(){
    
    for(int i = 0;i<ordenPaneles.length;i++)
    {
       if( ordenPaneles[i].equals(p.name)){
           if( i == ordenPaneles.length -1){
             died = true;
           }else{
             //p = ordenPaneles[i+1];
             
           }  
       }
    }
  }
}
