class GameState {
  short[][] stones;
  boolean turn;
  float scoreBlack;
  float scoreWhite;
  color current;
  
  GameState(short[][] stones, boolean turn, float scoreBlack, float scoreWhite, color current) {
    this.stones = stones;
    this.turn = turn;
    this.scoreBlack = scoreBlack;
    this.scoreWhite = scoreWhite;
    this.current = current;
  }
}