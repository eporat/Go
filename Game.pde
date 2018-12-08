import java.util.*; //<>//

class Game {
  final static int BLACK = 0xff000000;
  final static int WHITE = 0xffFFFFFF;
  final float KOMI = 6.5f;
  Board board;
  private Stone[][] stones;
  LinkedList<GameState> history;
  private LinkedList<Point> checkedPoints;
  private boolean turn;
  private int current;
  private boolean clicked;
  private float scoreBlack = 0;
  private float scoreWhite = KOMI;
  private float start = 0;
  private float end = 0;
  private boolean pass = false;
  private boolean endGame = false;
  private boolean won = false;
  private int winner;

  /* For optimization, unnecessary to draw board all the time */
  private boolean drawBoard = true; // if true, draws the board.
  int size;

  private Game(int size) {
    this.size = size;
    board = new Board(size);
    stones = new Stone[size][size];
    turn = true;
    current = BLACK;
    clicked = false;
    scoreBlack = 0;
    scoreWhite = KOMI;
    history = new LinkedList<GameState>();
    //background(0xff8b4513);
  }

  public GameState createState() {
    return new GameState(toShort(), turn, scoreBlack, scoreWhite, current, (LinkedList<GameState>)history.clone());
  }

  private short[][] toShort() {
    short[][] target = new short[size][size];
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (!isEmpty(i, j)) {
          if (stones[i][j].turn == true) {
            target[i][j] = 1;
          } else {
            target[i][j] = 2;
          }
        } else {
          target[i][j] = 0;
        }
      }
    }
    return target;
  }

  private Stone[][] toStones(short[][] stones) {
    Stone[][] target = new Stone[size][size];
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (stones[i][j] == 0) {
          target[i][j] = null;
        } else if (stones[i][j] == 1) {
          target[i][j] = new Stone(i, j, true);
        } else if (stones[i][j] == 2) {
          target[i][j] = new Stone(i, j, false);
        }
      }
    }
    return target;
  }

  private void setState(GameState state) {
    this.stones = toStones(state.stones);
    this.turn = state.turn;
    this.scoreBlack = state.scoreBlack;
    this.scoreWhite = state.scoreWhite;
    this.current = state.current;
  }

  private void render() {
    noStroke();
    background(0xff8b4513);
    directionalLight(255, 2555, 255, 0.5f, 0.5f, -1);
    renderBoard();
    drawHud();
  }

  private void drawHud() {    
    fill(128);
    textSize(20);
    text("Frame rate: "+PApplet.parseInt(frameRate), 0.05f* width, 0.05f*height);

    fill(0);
    textSize(100);
    text("G", width * 0.46f, height * (0.1f + 0.003f * cos(frameCount * 0.01f)));
    fill(255);
    text("o", width * 0.46f + textWidth("G"), height * (0.1f + 0.003f * sin(frameCount * 0.01f)));

    if (pass) {
      if (!endGame) {
        fill(otherColor(current));
        text("Pass!", width * 0.5f, height*0.20f);
      } else {
        if (!won) {
          fill((current+otherColor(current))/2);
          text("Remove dead stones", width * 0.5f, height*0.20f);
        } else {
          fill(winner);
          if (winner == BLACK) {
            text("Black Wins!", width * 0.5f, height*0.20f);
          } else {
            text("White Wins!", width * 0.5f, height*0.20f);
          }
        }
      }
    }

    textSize(25);
    fill(0);
    text("Black Score :"+scoreBlack, width*0.25f, height * 0.15f); 
    fill(255);
    if (scoreWhite == KOMI) {
      text("White Score : 6.5 (KOMI)", width*0.75f, height * 0.15f);
    } else {
      text("White Score :"+scoreWhite, width*0.75f, height * 0.15f);
    }

    fill(current);
    text("Current Player", width*0.5f, height * 0.92f); 
    noStroke();

    end += 0.01f;
    if (end % (4 * PI) < TWO_PI) {
      arc(width/2, height * 0.96f, height * 0.03f, height * 0.03f, start % TWO_PI, end % TWO_PI);
    } else {
      arc(width/2, height * 0.96f, height * 0.03f, height * 0.03f, end % TWO_PI, TWO_PI);
    }
    stroke(0);
  }

  private void renderStones() {
    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size; y++) {
        if (!isEmpty(x, y)) {
          getStone(x, y).render();
        }
      }
    }
  }

  private void move(Point loc, boolean isPlayer) {
    boolean isSuccessful = placeStone(loc, isPlayer);
    changeTurn(isSuccessful);
    if (isSuccessful && isPlayer){
      move(melvin.chooseMove(game.createState(),4,turn), false);
    }
  }

  private boolean canPlay() {
    return !errorSound.isPlaying();
  }

  private boolean placeStone(Point loc, boolean isPlayer) {
    /*Point loc = board.closestPoint(mouseX, mouseY); */

    if (inBound(loc.x, loc.y) && isEmpty(loc.x, loc.y)) {
      history.addFirst(createState());
      setStone(loc.x, loc.y, turn, true);
      capture(loc.x, loc.y);
      if (!ko() && freeSpace(loc.x, loc.y, current) != 0) {
        if (isPlayer){
          plopSound.rewind();
          plopSound.play();
        }
        return true;
      } else if (canPlay()) {
        if (isPlayer){
          errorSound.rewind();
          errorSound.play();
          clicked = false;
        }
        reverseMove();
      }
    }

    return false;
  }

  private void update() {
    if (canPlay()) {
      render();
      //handleMouse();
      clicked = false;
    } else {
      cam.beginHUD();
      fill(255, 0, 0);
      textSize(100);
      text("Illegal Move!", width/2, height/2);
      cam.endHUD();
    }
  }

  private void handleMouse() {
    if (canPlay() && clicked) {
      if (!endGame) {
        move(board.closestPoint(mouseX, mouseY), true);
      } else {
        removeDeadStones(endGameMove());
      }
    }
  }

  private void changeTurn(boolean placed) {
    if (placed) {
      turn = !turn;
      pass = false;
      changeColor();
    }
  }

  private void changeColor() {
    current = otherColor(current);
  }

  private int otherColor(int c) {
    if (c == BLACK) {
      return WHITE;
    } else return BLACK;
  }

  private boolean inBound(int x, int y) {
    return x >= 0 && x < size && y >= 0 && y < size;
  }

  private int freeSpace(int x, int y, int playercolor) {
    checkedPoints = new LinkedList<Point>();
    return freeSpaceUtil(x, y, playercolor);
  }

  private int freeSpaceUtil(int x, int y, int playercolor) {
    if (!inBound(x, y) || checkedPoints.contains(new Point(x, y))) {
      return 0;
    }
    checkedPoints.add(new Point(x, y));

    if (isEmpty(x, y)) {
      return 1 + freeSpaceUtil(x, y+1, playercolor) + freeSpaceUtil(x, y-1, playercolor) + freeSpaceUtil(x+1, y, playercolor) + freeSpaceUtil(x-1, y, playercolor);
    } else if (getStone(x, y).stoneColor == playercolor) {
      return freeSpaceUtil(x, y+1, playercolor) + freeSpaceUtil(x, y-1, playercolor) + freeSpaceUtil(x+1, y, playercolor) + freeSpaceUtil(x-1, y, playercolor);
    }

    return 0;
  }

  public boolean isEmpty(int x, int y) {
    return getStone(x, y) == null;
  }

  private boolean isEnemy(int x1, int y1, int x2, int y2) {
    return getStone(x1, y1).stoneColor != getStone(x2, y2).stoneColor;
  }

  /* Remove a stone (also updates score) */
  private void removeStone(int x, int y) {
    stones[x][y] = null;
    if (current == WHITE) {
      scoreWhite += 1;
    } else {
      scoreBlack += 1;
    }
  }

  /* Removes stones using flood fill */
  private void removeStones(int x, int y) {
    if (!inBound(x, y) || isEmpty(x, y) || (!isEmpty(x, y) && getStone(x, y).stoneColor == current)) {
      return;
    } else {
      removeStone(x, y);
      removeStones(x+1, y); 
      removeStones(x, y+1); 
      removeStones(x-1, y); 
      removeStones(x, y-1);
    }
  }

  /* Captures a stone */
  private void capture(int x, int y) {
    boolean captured = false;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if (i != 0 && j == 0 || i == 0 && j != 0) {
          if (inBound(x+i, y+j) && !isEmpty(x, y) && !isEmpty(x+i, y+j)
            && isEnemy(x, y, x+i, y+j) && freeSpace(x+i, y+j, getStone(x+i, y+j).stoneColor) == 0) {
            removeStones(x+i, y+j);
            captured = true;
          }
        }
      }
    }
  }

  /* Draw the board */
  public void renderBoard() {
    pushMatrix();
    translate(width/2, height/2);
    rotateX(radians(40));
    background(0xff8b4513);
    board.render();
    renderStones();
    //drawBoard = false;
    popMatrix();
  }

  /* Checks for ko state */
  private boolean ko() {
    short[][] shortStones = toShort();

    if (history.size() < 2) {
      return false;
    }
    return (Arrays.deepEquals(shortStones, history.get(1).stones));
  }

  private boolean equalStates(GameState a, GameState b) {
    return Arrays.deepEquals(a.stones, b.stones);
  }

  /* This function reverses the move */
  public void reverseMove() {
    setState(history.pollFirst());
  }

  public void handleKeyboard() {
    if (!canPlay()) {
      return;
    }

    if (keyCode == BACKSPACE) { 
      if (history.size() > 0) {
        reverseMove();
        pass = false;
      }
    } else if (key == ' ') {

      if (pass == false) {
        changeTurn(true);
        pass = true;
      } else {
        if (!endGame) {
          endGame = true;
        } else {
          won = true;
          if (Math.max(scoreBlack, scoreWhite) == scoreBlack) {
            winner = BLACK;
          } else {
            winner = WHITE;
          }
        }
      }
      passSound.rewind();
      passSound.play();
    } else if (key == 'q') {
      exit();
    }
  }

  /* Accessors */
  private Stone getStone(int x, int y) {
    return stones[x][y];
  }

  private void setStone(int x, int y, boolean turn, boolean draw) {
    stones[x][y] = new Stone(x, y, turn);
    if (draw) {
      pushMatrix();
      translate(width/2, height/2);
      rotateX(radians(40));
      //stones[x][y].render();
      popMatrix();
    }
  }

  public Point getDrawXY(float x, float y) {
    int drawX = PApplet.parseInt(board.OFFSET_X+x*board.SQUARE_SIZE - width/2);
    int drawY = PApplet.parseInt(board.OFFSET_Y+y*board.SQUARE_SIZE - height/2);
    return new Point(drawX, drawY);
  }

  public Point getBoardXY(int x, int y) {
    int boardX = round((x-board.OFFSET_X)/(board.SQUARE_SIZE+1));
    int boardY = round((y-board.OFFSET_Y)/(board.SQUARE_SIZE+1));
    return new Point(boardX, boardY);
  }

  public boolean endGameMove() {
    Point loc = board.closestPoint(mouseX, mouseY);
    return inBound(loc.x, loc.y) && (!isEmpty(loc.x, loc.y));
  }

  public void removeDeadStones(boolean endGame) {
    if (endGame) {
      history.addFirst(createState());
      Point loc = board.closestPoint(mouseX, mouseY);
      current = otherColor(stones[loc.x][loc.y].stoneColor);
      removeStones(loc.x, loc.y);
      changeColor();
    }
  }
}