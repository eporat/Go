class Board {

  final static int BOARD_SIZE = size, MARGIN = 1;
  final static float SQUARE_SIZE = (SCREEN_WIDTH * 0.5) / (BOARD_SIZE - 1 + 2 * MARGIN);
  final static float OFFSET_X = (SCREEN_WIDTH * 0.5) - 0.5 * (SQUARE_SIZE * (BOARD_SIZE - 1 + 2 * MARGIN));
  final static float OFFSET_Y = (SCREEN_HEIGHT * 0.55) - 0.5 * (SQUARE_SIZE * (BOARD_SIZE - 1 + 2 * MARGIN));
  PVector[][] points;
  boolean firstDraw = true;


  Board(int size) {
    points = new PVector[BOARD_SIZE][BOARD_SIZE];
  }

  void initPoints() {
    for (int x = 0; x < BOARD_SIZE; x++) {
      for (int y = 0; y < BOARD_SIZE; y++) {
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

    point = game.getDrawXY(float(BOARD_SIZE-1)/2, float(BOARD_SIZE-1)/2);
    pushMatrix();
    translate(point.x, point.y, -height*0.025);
    fill(#ffa54f);
    box(SQUARE_SIZE * (BOARD_SIZE - 1 + 2 * MARGIN), SQUARE_SIZE * (BOARD_SIZE - 1 + 2 * MARGIN), height*0.05);
    popMatrix();

    stroke(0);
    for (int x = 0; x < BOARD_SIZE - 1; x++) {
      for (int y = 0; y < BOARD_SIZE - 1; y++) {
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

    for (int x = 0; x < BOARD_SIZE; x++) {
      for (int y = 0; y < BOARD_SIZE; y++) {
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
