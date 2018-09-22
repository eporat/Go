class Board {

  int MARGIN = 1;
  float SQUARE_SIZE = (width * 0.5) / (size - 1 + 2 * MARGIN);
  float OFFSET_X = (width * 0.5) - 0.5 * (SQUARE_SIZE * (size - 1 + 2 * MARGIN));
  float OFFSET_Y = (height * 0.55) - 0.5 * (SQUARE_SIZE * (size - 1 + 2 * MARGIN));
  PVector[][] points;
  boolean firstDraw = true;


  Board(int size) {
    points = new PVector[size][size];
  }

  void initPoints() {
    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size; y++) {
        Point point = game.getDrawXY(y, x);
        float drawX = screenX(point.x, point.y, 0);
        float drawY = screenY(point.x, point.y, 0);
        pushMatrix();
        points[x][y] = new PVector();
        points[x][y].x = drawX;
        points[x][y].y = drawY;
        points[x][y].z = 0;
        popMatrix();
      }
    }  
    firstDraw = false;
  }

  void render() {
    if (firstDraw) { 
      initPoints();
    }

    Point point;

    point = game.getDrawXY(float(size-1)/2, float(size-1)/2);
    pushMatrix();
    translate(point.x, point.y, -height*0.025);
    fill(#ffa54f);
    box(SQUARE_SIZE * (size - 1 + 2 * MARGIN), SQUARE_SIZE * (size - 1 + 2 * MARGIN), height*0.05);
    popMatrix();

    stroke(0);
    for (int x = 0; x < size - 1; x++) {
      for (int y = 0; y < size - 1; y++) {
        point = game.getDrawXY(y, x);
        pushMatrix();
        translate(point.x, point.y);
        noFill();
        rect(SQUARE_SIZE/2, SQUARE_SIZE/2, SQUARE_SIZE, SQUARE_SIZE);
        popMatrix();
      }
    }
  }


  Point closestPoint(int mouseX, int mouseY) {
    Point closest = null;
    float closestDistance = MAX_INT;
    PVector mouse = new PVector(mouseX, mouseY);

    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size; y++) {
        PVector point = points[y][x];
        if (point.dist(mouse) < closestDistance) {
          closestDistance = point.dist(mouse);
          closest = new Point(x, y);
        }
      }
    }
    return closest;
  }
}
