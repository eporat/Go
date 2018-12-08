
class Stone {
  int x, y;
  int stoneColor;
  int drawColor;
  boolean turn;
  float STONE_SIZE = (0.20f * width) / (size + 1);


  Stone(int x, int y, boolean turn) {
    this.turn = turn;
    this.setColor(turn);
    Point loc = game.getDrawXY(x, y);
    this.x = loc.x;
    this.y = loc.y;
  }

  public void setColor(boolean turn) {
    if (turn) {
      this.stoneColor = Game.BLACK;
      this.drawColor = color(40);
    } else {
      this.stoneColor = Game.WHITE;
      this.drawColor = color(255);
    }
  }

  public void render() {
    pushMatrix();
    noStroke();
    fill(drawColor);
    translate(x, y);
    sphere(STONE_SIZE);
    popMatrix();
  }
}