class Stone {
  int x, y;
  int stoneColor;
  color drawColor;
  boolean turn;
  float STONE_SIZE = (0.20 * width) / (size + 1);


  Stone(int x, int y, boolean turn) {
    this.turn = turn;
    this.setColor(turn);
    Point loc = game.getDrawXY(x,y);
    this.x = loc.x;
    this.y = loc.y;
  }

  void setColor(boolean turn) {
    if (turn) {
      this.stoneColor = Game.BLACK;
      this.drawColor = color(40);
    } else {
      this.stoneColor = Game.WHITE;
      this.drawColor = color(255);
    }
  }

  void render() {
    pushMatrix();
    noStroke();
    fill(drawColor);
    translate(x,y);
    sphere(STONE_SIZE);
    popMatrix();
  }
}