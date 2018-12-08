class GoAI {

  Game game;
  int moves;
  HeuristicComparator comparator;

  GoAI(Game g) {
    this.game = new Game(g.size);
    this.comparator = new HeuristicComparator(g.size);
  }

  public float evaluation() {
    float dScore = 0;
    int size = game.stones.length;
    float maxDist = dist(0, 0, size/2, size/2);

    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (game.stones[i][j] != null) {
          if (game.stones[i][j].turn) {
            dScore += abs(maxDist - dist(i, j, size/2, size/2));
          } else {
            dScore -= abs(maxDist - dist(i, j, size/2, size/2));
          }
        }
      }
    }


    return (game.scoreBlack - game.scoreWhite) + 0.2 * dScore;
  }

  public ArrayList<Point> nextMoves() {
    ArrayList<Point> moves = new ArrayList<Point>();
    for (int i = 0; i < game.size; i++) {
      for (int j = 0; j < game.size; j++) {
        if (game.isEmpty(i, j) && game.placeStone(new Point(i, j), false)) {
          game.reverseMove();
          moves.add(new Point(i, j));
        }
      }
    }
    Collections.sort(moves, comparator);
    return moves;
  }

  public Point chooseMove(GameState state, int depth, boolean maximizingPlayer) {
    moves = 0;
    game.setState(state);
    float alpha = -1000; 
    float beta = 1000;
    Point bestPoint = null;

    if (maximizingPlayer) {
      float maxEval = -1000;
      for (Point move : nextMoves()) {
        game.placeStone(move, false);
        float eval = minimax(depth - 1, alpha, beta, false);
        game.reverseMove();
        if (eval > maxEval) {
          maxEval = eval;
          bestPoint = new Point(move.x, move.y);
        }
      }
    } else {
      float minEval = 1000;
      for (Point move : nextMoves()) {
        game.placeStone(move, false);
        float eval = minimax(depth - 1, alpha, beta, true);
        game.reverseMove();

        if (eval < minEval) {
          minEval = eval;
          bestPoint = new Point(move.x, move.y);
        }
      }
      println(minEval);
    }

    if (bestPoint == null) {
      ArrayList<Point> nextMoves = nextMoves();
      // ADD PASS!
      bestPoint = nextMoves.get(int(random(0, nextMoves.size())));
    }
    println(moves);
    return bestPoint;
  }

  public float minimax(int depth, float alpha, float beta, boolean maximizingPlayer) {
    if (depth == 0) {
      moves ++;
      return evaluation();
    }

    if (maximizingPlayer) {
      float maxEval = -1000;

      for (Point move : nextMoves()) {
        game.placeStone(move, false);
        float eval = minimax(depth - 1, alpha, beta, false);
        game.reverseMove();
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) {
          break;
        }
      }
      return maxEval;
    } else {
      float minEval = 1000;

      for (Point move : nextMoves()) {
        game.placeStone(move, false);
        float eval = minimax(depth - 1, alpha, beta, true);
        game.reverseMove();
        minEval = min(minEval, eval);
        beta = min(beta, eval);

        if (beta <= alpha) {
          break;
        }
      }
      return minEval;
    }
  }
}