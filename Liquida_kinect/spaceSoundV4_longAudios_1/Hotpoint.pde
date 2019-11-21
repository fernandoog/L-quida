class Hotpoint{
  PVector center;
  color fillColor;
  color strokeColor;
  int size;
  int pointsIncluded;
  int maxPoints;
  boolean wasJustHit;
  int threshold;
  
  Hotpoint(float centerX, float centerY, float centerZ, int boxSize){
    
    center = new PVector (centerX, centerY, centerZ);
    size = boxSize;
    pointsIncluded = 0;
    maxPoints = 1000;
    threshold = 50;
    fillColor = strokeColor = color (random(255), random(255), random(255));
    
  }
  
  void setThreshold(int newThreshold){
    threshold = newThreshold;
  }
  
  void setMaxPoints(int newMaxPoints){
    maxPoints = newMaxPoints;
    
  }
  
  void setColor(float red, float green, float blue){
    fillColor = strokeColor = color(red, green, blue);
   }
   
  boolean check(PVector point){
    boolean result = false;
    
    if(point.x > center.x - size/2 && point.x < center.x + size/2){
      if(point.y > center.y - size/2 && point.y < center.y + size/2){
        if(point.z > center.z - size/2 && point.z < center.z + size/2){
          result = true;
          pointsIncluded++;
         }
        }
      }
    return result;
  }
  
  void draw(){
    pushMatrix();
      translate(center.x, center.y, center.z);
      
      fill(red(fillColor), green(fillColor), blue(fillColor), 255*percentIncluded());
      stroke(red(strokeColor), green(strokeColor), blue(strokeColor), 255);
      box(size);
    popMatrix();  
  }
  
  float percentIncluded(){
   return map(pointsIncluded, 0, maxPoints, 0, 1);
  }
  
  boolean currentlyHit(){
    return (pointsIncluded > threshold);
  }
  
  boolean isHit(){
    return currentlyHit() && !wasJustHit;
  }
  
  void clear(){
    wasJustHit = currentlyHit();
    pointsIncluded = 0;
    
  }




}
