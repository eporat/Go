class GameState {
  short[][] stones;
  boolean turn;
  float scoreBlack;
  float scoreWhite;
  color current;
  private LinkedList<GameState> history;
  
  GameState(short[][] stones, boolean turn, float scoreBlack, float scoreWhite, color current, LinkedList<GameState> history) {
    this.stones = stones;
    this.turn = turn;
    this.scoreBlack = scoreBlack;
    this.scoreWhite = scoreWhite;
    this.current = current;
    this.history = history;
  }
  
  public GameState clone(){  
    return new GameState(
      (short[][])this.stones.clone(),
      this.turn,
      this.scoreBlack,
      this.scoreWhite,
      this.current,
      (LinkedList<GameState>)this.history.clone()
    );
  }
  

}