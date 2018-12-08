import java.awt.Point;
import peasy.*;
import ddf.minim.*;
PeasyCam cam;
Minim minim; 
AudioPlayer errorSound, passSound, plopSound;
Game game;
GoAI melvin;

static final int size = 7;
static final int MAX_FRAME_RATE = 1000;

public void setup() {
  size(500, 500, P3D);
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
  //for (int i = 0; i < 50; i++){
  //  game.move(new Point(int(random(0,10)), int(random(0,10))));
  //}
  melvin = new GoAI(game);
}

public AudioPlayer loadPlayer(String path) {
  AudioPlayer player = minim.loadFile(path);
  player.setGain(-10.0f); // decrease db value of audio by 10
  return player;
}

public void mousePressed() {
  game.clicked = true;
  game.handleMouse();
}

void draw(){
  game.update();  
}
/*
public void mousePressed() {
  game.clicked = true;
  //game.handleMouse();
}
*/

public void keyPressed() {
  game.handleKeyboard();
}