class Point {
  int x, y;
  
  Point(int x, int y) {
    this.x = x;
    this.y = y;
  }
  @Override
  boolean equals(Object other) {
    return this.x == ((Point)other).x && this.y == ((Point)other).y;
  }
  
  String toString(){
    return "["+this.x+","+this.y+"]";  
  }
}