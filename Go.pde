import peasy.*;
import ddf.minim.*;
PeasyCam cam;
Minim minim; 
AudioPlayer errorSound, passSound, plopSound;
Game game;

static final int size = 19;
static final int SCREEN_WIDTH = 1000;
static final int SCREEN_HEIGHT = 1000;
static final int MAX_FRAME_RATE = 1000;

public void setup() {
  size(1000, 1000, P3D);
  frameRate(MAX_FRAME_RATE);
  rectMode(CENTER);
  textAlign(CENTER, CENTER);


  minim = new Minim(this);
  errorSound = loadPlayer("error.mp3");
  passSound = loadPlayer("pass.mp3");
  plopSound = loadPlayer("plop.mp3");

  PFont font = createFont("SansSerif", 100, false);
  textFont(font);

  cam = new PeasyCam(this, width/2, height/2, 0, height);
  cam.setActive(false);
  game = new Game(size);
}

public AudioPlayer loadPlayer(String path) {
  AudioPlayer player = minim.loadFile(path);
  player.setGain(-10.0f); // decrease db value of audio by 10
  return player;
}

public void draw() {
  game.update();
}

public void mousePressed() {
  game.clicked = true;
  game.handleMouse();
}

public void keyPressed() {
  game.handleKeyboard();
}