
import java.util.*;
/**
 Represents a Go game. 
 */

class Game {
  final static int BLACK = #000000;
  final static int WHITE = #FFFFFF;
  final float KOMI = 6.5f;
  Board board;
  private Stone[][] stones;
  private LinkedList<GameState> history;
  private LinkedList<Point> checkedPoints;
  private boolean turn;
  private int current;
  private boolean clicked;
  private float scoreBlack = 0;
  private float scoreWhite = KOMI;
  private float start = 0;
  private float end = 0;
  private boolean pass = false;
  /* For optimization, unnecessary to draw board all the time */
  private boolean drawBoard = true; // if true, draws the board.

  private Game(int size) {
    board = new Board(size);
    stones = new Stone[size][size];
    turn = true;
    current = BLACK;
    clicked = false;
    scoreBlack = 0;
    scoreWhite = KOMI;
    history = new LinkedList<GameState>();
    background(0xff8b4513);
  }

  private GameState createState() {
    return new GameState(toShort(), turn, scoreBlack, scoreWhite, current);
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
    directionalLight(255, 2555, 255, 0.5, 0.5, -1);
    renderBoard();
    drawHud();
  }

  private void drawHud() {    
    fill(128);
    textSize(20);
    text("Frame rate: "+int(frameRate), 0.05* width, 0.05*height);

    fill(0);
    textSize(100);
    text("G", width * 0.46, height * (0.1 + 0.003 * cos(frameCount * 0.01)));
    fill(255);
    text("o", width * 0.46 + textWidth("G"), height * (0.1 + 0.003 * sin(frameCount * 0.01)));

    if (pass) {
      fill(otherColor(current));
      text("Pass!", width * 0.5, height*0.20);
    }

    textSize(25);
    fill(0);
    text("Black Score :"+scoreBlack, width*0.25, height * 0.15f); 
    fill(255);
    if (scoreWhite == KOMI) {
      text("White Score : 6.5 (KOMI)", width*0.75f, height * 0.15f);
    } else {
      text("White Score :"+scoreWhite, width*0.75f, height * 0.15f);
    }
    
    fill(current);
    text("Current Player", width*0.5, height * 0.92f); 
    noStroke();

    end += 0.01;
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

  private void move() {
    changeTurn(placeStone());
  }

  private boolean canPlay() {
    return !errorSound.isPlaying();
  }

  private boolean placeStone() {
    Point loc = board.closestPoint(mouseX, mouseY);

    if (inBound(loc.x, loc.y) && isEmpty(loc.x, loc.y)) {
      history.addFirst(createState());
      setStone(loc.x, loc.y, turn, true);
      capture(loc.x, loc.y);
      if (!ko() && freeSpace(loc.x, loc.y, current) != 0) {
        plopSound.rewind();
        plopSound.play();
        return true;
      } else if (canPlay()) {
        errorSound.rewind();
        errorSound.play();
        clicked = false;
        reverseMove();
      }
    }

    return false;
  }

  private void update() {
    if (canPlay()) {
      render();
      handleMouse();
      clicked = false;
    } else {
      cam.beginHUD();
      fill(255, 0, 0);
      textSize(100);
      text("Illegal Move!", width/2, height/2);
      drawBoard = true;
      cam.endHUD();
    }
  }

  private void handleMouse() {
    if (canPlay() && clicked) {
      move();
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

  private color otherColor(color c) {
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

  private boolean isEmpty(int x, int y) {
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
    if (captured) {
      drawBoard = true;
    }
  }

  /* Draw the board */
  void renderBoard() {
    if (drawBoard == true) {
      pushMatrix();
      translate(width/2, height/2);
      rotateX(radians(40));
      background(0xff8b4513);
      board.render();
      renderStones();
      //drawBoard = false;
      popMatrix();
    }
  }

  /* Checks for ko state */
  private boolean ko() {
    short[][] shortStones = toShort();
    
    if (history.size() < 2){
      return false;
    }
    return (Arrays.deepEquals(shortStones, history.get(1).stones));
  }

  /* This function reverses the move */
  public void reverseMove() {
    setState(history.pollFirst());
    drawBoard = true;
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
      changeTurn(true);
      pass = true;

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
      stones[x][y].render();
      popMatrix();
    }
  }

  Point getDrawXY(float x, float y) {
    int drawX = int(Board.OFFSET_X+x*Board.SQUARE_SIZE - width/2);
    int drawY = int(Board.OFFSET_Y+y*Board.SQUARE_SIZE - height/2);
    return new Point(drawX, drawY);
  }

  Point getBoardXY(int x, int y) {
    int boardX = round((x-Board.OFFSET_X)/(Board.SQUARE_SIZE+1));
    int boardY = round((y-Board.OFFSET_Y)/(Board.SQUARE_SIZE+1));
    return new Point(boardX, boardY);
  }
}
