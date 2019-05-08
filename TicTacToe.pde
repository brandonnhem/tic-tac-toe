import java.util.Random; // Used to have the bot pick a spot and who goes first //<>//
import java.util.Stack; // used to keep track of the last moves made by the bot and player
import ddf.minim.*; // used to add sounds to the game

PImage imgx, imgo; // used to import images into the game
Minim minim; // used to import sounds into the game

int w;              // Width of the grid
int h;              // Height of the grid
int choice;        // used to determine who goes first, bot or player
int bs = 300;             // block size
int playCount = 0;        // number of user turns
int numCols = 3;
int numRows = 3;
int[][] grid = new int [numRows][numCols];
int[] gridSpots = new int [9];  // all possible spots on the grid
int[] playerSpots = new int [9];  // spots that the user has taken
int[] botSpots = new int [9];   // spots that the bot has taken
String [] cheekyRemarks = {"You Are Not Very Good", "Two Thumbs Down", "Are You Even Trying?", "How Embarassing", "You're Bad", "Pathetic"}; // What the bot says when you lose to it
boolean gameOver = false;
boolean won = false;
int playerScore = 0; // score of the player
int botScore = 0;    // score of the bot
boolean firstClick = false; // used to clear the text of the score, once turned true, the text disappears
boolean playerWon = false; 
boolean botWon = false;
boolean alreadyCalled = false; // used in draw(), ensures the updateScore() method is only called once
boolean playerIsX = false; // tell the player what they are before the game starts, false is default indicating O, true is X
boolean botToWin = false; // determines if the bot is about to win in the next move
boolean userToWin = false; // determines if the user is about to win in the next move
boolean botMsg = false; // flag to ensure the bot's snarky message is only called once
boolean paused = false; // if the game is paused or not
boolean botFirst = false; // determines if the bot should go first or not
boolean playerTurn = false; // if it is the player's turn to go
boolean botTurn = false; // if it is the bot's turn
Stack<Integer> playerMoves = new Stack<Integer>();
Stack<Integer> botMoves = new Stack<Integer>();
boolean ctrlPressed = false;
boolean zPressed = false;

AudioSample no;

void setup () {
  /**
   This setups the game, specifically the window size, who goes first, and the image that is preloaded for the symbols.
   Alternatively, you can change the symbols if you want if change it in the root folder - just make sure that it's named
   "x.png" or "o.png".
   **/
  minim = new Minim(this); // used for audio playback
  no = minim.loadSample("nonono.mp3"); // loads the file for error when pressing ctrl+z
  size (900, 900);            //size will only take literals, not variable
  w = width / 3;
  h = height / 3;
  Random rand = new Random();
  choice = rand.nextInt(2); 
  if (choice == 1) {
    imgx = loadImage("x.png"); // loads the image for x 
    imgo = loadImage("o.png"); // loads the image for o
    playerIsX = true;
    playerTurn = true;
  } else {
    imgo = loadImage("x.png"); // loads the image for o
    imgx = loadImage("o.png"); // loads the image for x
    playerIsX = false;
    botTurn = true;
  }
  smooth(); // smooths out the lines
}


void draw () {
  /**
   This draws in the window for the game. Here we can change the background color. Most of the logic of the
   game belongs in this function.
   **/
  background(255, 255, 255);
  //Create a grid pattern on the screen with vertical and horizontal lines
  for (int i = 0; i < width; i++) {
    line (i*bs, 0, i*bs, height);
  }
  for (int i = 0; i < height; i++) {
    line (0, i * bs, width, i * bs);
  }
  printPlayer(); // constantly prints out where the player's symbols are
  printBot();    // constantly prints out where the bot's symbols are
  if (!firstClick) { // displays the score of the player and the bot before the game starts, once the player clicks, the text disappears
    fill(0, 128, 0);
    textSize(30);
    textAlign(CENTER);
    text("Player Score: " + playerScore, (width/2), (height/2) - 100);
    fill(178, 34, 34);
    text("Bot Score: " + botScore, (width/2), (height/2) - 50); 
    fill(0);
    if (playerIsX) {
      text("You play as X", (width/2), (height/2));
    } 
    if (!playerIsX) {
      text("You play as O", (width/2), (height/2));
    }
    text("Click to start...", (width/2), (height/2) + 50);
    text("Press UP to pause", (width/2), (height/2) + 100);
  }
  //Checks for win scenarios each iteration
  rowWin();
  colWin();
  diagWin();
  //If not won, check if tie
  if (playCount >= 9) isTie();
  if (botTurn && !gameOver) bot(); // determines if the bot's turn or not
  if (gameOver) {
    if (!alreadyCalled) { // this ensures that updateScore() is only called once
      updateScore();
      alreadyCalled = true; // now it won't be called
    }
    if (botWon) {
      fill(178, 34, 34);
      if (!botMsg) { // this makes sure that the message does not constantly change back and forth
        Random rand = new Random();
        choice = rand.nextInt(cheekyRemarks.length); 
        botMsg = true;
      }
      textAlign(CENTER);
      text(cheekyRemarks[choice], width/2, height/2 - 50);
    }
    if (playerWon) {
      fill(0, 128, 0);
    }
    textSize(40);
    textAlign(CENTER);
    text("Press space bar to restart.", (width/2), (height/2)+50);
    if (keyPressed && key == ' ') {  // this is the restart logic, it resets everything
      playCount = 0;        //number of user turns
      grid = new int [numRows][numCols];
      gridSpots = new int [9];
      playerSpots = new int [9];
      botSpots = new int [9];
      gameOver = false;
      won = false;
      firstClick = false;
      playerWon = false;
      botWon = false;
      alreadyCalled = false;
      botToWin = false;
      userToWin = false;
      botMsg = false;
      playerTurn = false;
      botTurn = false;
      playerMoves.clear();
      botMoves.clear();
      Random rand = new Random();
      choice = rand.nextInt(2);
      if (choice == 1) {
        imgx = loadImage("x.png");
        imgo = loadImage("o.png");
        playerIsX = true;
        playerTurn = true;
      } else {
        imgo = loadImage("x.png");
        imgx = loadImage("o.png");
        playerIsX = false;
        botTurn = true;
      }
    }
  }
  if (!gameOver) {
    takenSpot();
    detectPossibleWin();
    detectPossibleFork();
    detectPossibleBotWin();
    detectPossibleBotFork();
  }
}

void keyPressed() {
  /**
   Detects for UP or DOWN arrow keys
   **/
  if (keyPressed && keyCode == UP) {
    paused();
  }
  if (keyPressed && keyCode == DOWN) {
    paused = false;
    loop(); // starts draw() back up again after being not called
  }
  if (paused && keyPressed && key == 'r') { // resets the score for the game
    paused = false;
    playerScore = 0;
    botScore = 0;
    loop();
  }
  if ((keyPressed && key == 26)) { // combination of CTRL + Z
    ctrlPressed = true;
    zPressed = true;
  }
}

void keyReleased() {
  if (ctrlPressed && zPressed) {
    undoMove();
    ctrlPressed = false;
    zPressed = false;
  }
}
void undoMove() {
  /**
    Undos the player's last move along with the previous bot's move. 
    Will not go if the player has no more moves on the board.
   **/
  if (!gameOver && !playerMoves.empty() && !botMoves.empty()) {
    int playerSpot = playerMoves.peek();
    int botSpot = botMoves.peek();
    noLoop();
    gridSpots[playerSpot] = 0;
    playerSpots[playerSpot] = 0;
    playCount --;
    gridSpots[botSpot] = 0;
    botSpots[botSpot] = 0;
    playerMoves.pop();
    botMoves.pop();
    playCount --;
    loop();
  }
  else {
    fill(0);
    textSize(30);
    no.trigger();
  }
}

void paused() {
  /**
   If the UP arrow key is pressed, the game will enter a paused state. 
   The only options are to reset the score OR quit the game. 
   **/
  paused = true;
  background(255);
  fill(255, 3, 3);
  textSize(60);
  text("Game paused...", width/2, height/2 - 25);
  text("Press DOWN to unpause", width/2, height/2 + 50);
  fill(0, 128, 0);
  text("Player Score: " + playerScore, (w*1.5), (h/2) - 25);
  fill(178, 34, 34);
  text("Bot Score: " + botScore, (w*1.5), (h/2) + 50);
  fill(0);
  text("Press R to reset score", (w*1.5), (h/2) + 125);
  text("Press ESC to quit", width/2, h*2.5);
  noLoop(); // this is what keeps the pause game at bay, draw() is not called
}

void mouseClicked() {
  /**
   This monitors where the player has clicked, when the user clicks in a valid spot, it updates the array
   that stores the player's taken spots. Also then increases the play count.
   **/
  if (!gameOver && !playerTurn && botTurn) { // used to set firstClick to true if the bot goes first
    firstClick = true;
  }
  if (!paused && !gameOver && playerTurn && !botTurn) { // DEBUG merged the if conditions
    firstClick = true;
    if (mouseX < w && mouseY < h) { 
      //println("user pressed at " + mouseX + ", " + mouseY);
      if (gridSpots[0] != 1) {
        gridSpots[0] = 1;
        playerSpots[0] = 1;
        playerTurn = false;
        botTurn = true;
        playerMoves.push(0);
        playCount++;
      }
    } else if (mouseX <= 2*w && mouseX >= w && mouseY <= h) {
      //println("user pressed at " + mouseX + ", " + mouseY);   
      if (gridSpots[1] != 1) {
        gridSpots[1] = 1;
        playerSpots[1] = 1;
        playerTurn = false;
        botTurn = true;
        playerMoves.push(1);
        playCount++;
      }
    } else if (mouseX <= 3*w && mouseX >= 2*w && mouseY <= h) {
      //println("user pressed at " + mouseX + ", " + mouseY);   
      if (gridSpots[2] != 1) {
        gridSpots[2] = 1;
        playerSpots[2] = 1;
        playerTurn = false;
        botTurn = true;
        playerMoves.push(2);
        playCount++;
      }
    } else if (mouseX <= w && mouseY >= h && mouseY <= 2*h) {
      //println("user pressed at " + mouseX + ", " + mouseY);   
      if (gridSpots[3] != 1) {
        gridSpots[3] = 1;
        playerSpots[3] = 1;
        playerTurn = false;
        botTurn = true;
        playerMoves.push(3);
        playCount++;
      }
    } else if (mouseX >= w && mouseX <= 2*w && mouseY >= h && mouseY <= 2*h) {
      //println("user pressed at " + mouseX + ", " + mouseY);   
      if (gridSpots[4] != 1) {
        gridSpots[4] = 1;
        playerSpots[4] = 1;
        playerTurn = false;
        botTurn = true;
        playerMoves.push(4);
        playCount++;
      }
    } else if (mouseX >= 2*w && mouseX <= 3*w && mouseY >= h && mouseY <= 2*h) {
      //println("user pressed at " + mouseX + ", " + mouseY);   
      if (gridSpots[5] != 1) {
        gridSpots[5] = 1;
        playerSpots[5] = 1;
        playerTurn = false;
        botTurn = true;
        playerMoves.push(5);
        playCount++;
      }
    } else if (mouseX <= w && mouseY >= 2*h && mouseY <= 3*h) {
      //println("user pressed at " + mouseX + ", " + mouseY);   
      if (gridSpots[6] != 1) {
        gridSpots[6] = 1;
        playerSpots[6] = 1;
        playerTurn = false;
        botTurn = true;
        playerMoves.push(6);
        playCount++;
      }
    } else if (mouseX >= w && mouseX <= 2*w && mouseY >= 2*h && mouseY <= 3*h) {
      //println("user pressed at " + mouseX + ", " + mouseY);   
      if (gridSpots[7] != 1) {
        gridSpots[7] = 1;
        playerSpots[7] = 1;
        playerTurn = false;
        botTurn = true;
        playerMoves.push(7);
        playCount++;
      }
    } else if (mouseX >= 2*w && mouseX <= 3*w && mouseY >= 2*h && mouseY <= 3*h) {
      //println("user pressed at " + mouseX + ", " + mouseY);   
      if (gridSpots[8] != 1) {
        gridSpots[8] = 1;
        playerSpots[8] = 1;
        playerTurn = false;
        botTurn = true;
        playerMoves.push(8);
        playCount++;
      }
    }
    userToWin = false;
    botToWin = false;
  }
}

void takenSpot() {
  /**
   Gives advice to the player depending where they hover
   **/

  // Lets the user know that a spot is taken... why did I spend time on this...
  if ((mouseX < w && mouseY < h) && (gridSpots[0] == 1)) { 
    fill(0);
    textSize(30);
    textAlign(CENTER);
    text("This spot is taken.", (w/2), (h/2));
  } else if ((mouseX <= 2*w && mouseX >= w && mouseY <= h) && (gridSpots[1] == 1)) {
    fill(0);
    textSize(30);
    textAlign(CENTER);
    text("This spot is taken.", (w*1.5), (h/2));
  } else if ((mouseX <= 3*w && mouseX >= 2*w && mouseY <= h) && (gridSpots[2] == 1)) {
    fill(0);
    textSize(30);
    textAlign(CENTER);
    text("This spot is taken.", (w*2.5), (h/2));
  } else if ((mouseX <= w && mouseY >= h && mouseY <= 2*h) && (gridSpots[3] == 1)) {
    fill(0);
    textSize(30);
    textAlign(CENTER);
    text("This spot is taken.", (w/2), (h*1.5));
  } else if ((mouseX >= w && mouseX <= 2*w && mouseY >= h && mouseY <= 2*h) && (gridSpots[4] == 1)) {
    fill(0);
    textSize(30);
    textAlign(CENTER);
    text("This spot is taken.", (w*1.5), (h*1.5));
  } else if ((mouseX >= 2*w && mouseX <= 3*w && mouseY >= h && mouseY <= 2*h) && (gridSpots[5] == 1)) {
    fill(0);
    textSize(30);
    textAlign(CENTER);
    text("This spot is taken.", (w*2.5), (h*1.5));
  } else if ((mouseX <= w && mouseY >= 2*h && mouseY <= 3*h) && (gridSpots[6] == 1)) {
    fill(0);
    textSize(30);
    textAlign(CENTER);
    text("This spot is taken.", (w/2), (h*2.5));
  } else if ((mouseX >= w && mouseX <= 2*w && mouseY >= 2*h && mouseY <= 3*h) && (gridSpots[7] == 1)) {
    fill(0);
    textSize(30);
    textAlign(CENTER);
    text("This spot is taken.", (w*1.5), (h*2.5));
  } else if ((mouseX >= 2*w && mouseX <= 3*w && mouseY >= 2*h && mouseY <= 3*h) && (gridSpots[8] == 1)) {
    fill(0);
    textSize(30);
    textAlign(CENTER);
    text("This spot is taken.", (w*2.5), (h*2.5));
  }
}

void detectPossibleFork() {
  /**
   Detects if there a possible fork that the player can block. If so, advise the player if they hover over the square.
   **/
  if (!userToWin && !botToWin) {
    if ((mouseX <= w && mouseY <= h) && 
      (gridSpots[0] == 0) && 
      (((playerSpots[4] == 1 && gridSpots[8] == 0) && ((playerSpots[1] == 1 && gridSpots[2] == 0) || (playerSpots[2] == 1 && gridSpots[1] == 0) || (playerSpots[3] == 1 && gridSpots[6] == 0) || (playerSpots[6] == 1 && gridSpots[3] == 0))) ||
      ((playerSpots[8] == 1 && gridSpots[1] == 0) && ((playerSpots[1] == 1 && gridSpots[2] == 0) || (playerSpots[2] == 1 && gridSpots[1] == 0) || (playerSpots[3] == 1 && gridSpots[6] == 0) || (playerSpots[6] == 1 && gridSpots[3] == 0))) || 
      ((playerSpots[2] == 1 && gridSpots[1] == 0) && ((playerSpots[3] == 1 && gridSpots[6] == 0) || (playerSpots[6] == 1 && gridSpots[3] == 0))) ||
      ((playerSpots[1] == 1 && gridSpots[2] == 0) && ((playerSpots[3] == 1 && gridSpots[6] == 0) || (playerSpots[6] == 1 && gridSpots[3] == 0))))) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Make a fork here.", (w/2), (h/2) + 50);
    } else if ((mouseX >= w && mouseX <= w*2 && mouseY <= h) && 
      (gridSpots[1] == 0) && 
      (((playerSpots[4] == 1 && gridSpots[7] == 0) && ((playerSpots[0] == 1 && gridSpots[2] == 0) || (playerSpots[2] == 1 && gridSpots[0] == 0))) ||
      ((playerSpots[7] == 1 && gridSpots[4] == 0) && ((playerSpots[0] == 1 && gridSpots[2] == 0) || (playerSpots[2] == 1 && gridSpots[0] == 0))))) {    
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Make a fork here.", (w*1.5), (h/2) + 50);
    } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY <= h) && 
      (gridSpots[2] == 0) && 
      (((playerSpots[4] == 1 && gridSpots[6] == 0) && ((playerSpots[1] == 1 && gridSpots[0] == 0) || (playerSpots[0] == 1 && gridSpots[1] == 0) || (playerSpots[5] == 1 && gridSpots[8] == 0) || (playerSpots[8] == 1 && gridSpots[5] == 0))) ||
      ((playerSpots[6] == 1 && gridSpots[4] == 0) && ((playerSpots[1] == 1 && gridSpots[0] == 0) || (playerSpots[0] == 1 && gridSpots[1] == 0) || (playerSpots[5] == 1 && gridSpots[8] == 0) || (playerSpots[8] == 1 && gridSpots[5] == 0))) || 
      ((playerSpots[0] == 1 && gridSpots[1] == 0) && ((playerSpots[5] == 1 && gridSpots[8] == 0) || (playerSpots[8] == 1 && gridSpots[5] == 0))) ||
      ((playerSpots[1] == 1 && gridSpots[0] == 0) && ((playerSpots[5] == 1 && gridSpots[8] == 0) || (playerSpots[8] == 1 && gridSpots[5] == 0))))) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Make a fork here.", (w*2.5), (h/2) + 50);
    } else if ((mouseX <= w && mouseY <= h*2 && mouseY >= h) && 
      (gridSpots[3] == 0) && 
      (((playerSpots[4] == 1 && gridSpots[5] == 0) && ((playerSpots[0] == 1 && gridSpots[6] == 0) || (playerSpots[6] == 1 && gridSpots[0] == 0))) ||
      ((playerSpots[5] == 1 && gridSpots[4] == 0) && ((playerSpots[0] == 1 && gridSpots[6] == 0) || (playerSpots[6] == 1 && gridSpots[0] == 0))))) { 
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Make a fork here.", (w/2), (h*1.5) + 50);
    } else if ((mouseX >= w && mouseX <= w*2 && mouseY <= h*2 && mouseY >= h) && 
      (gridSpots[4] == 0) && 
      (((playerSpots[0] == 1 && gridSpots[8] == 0) && ((playerSpots[1] == 1 && gridSpots[7] == 0) || (playerSpots[2] == 1 && gridSpots[6] == 0) || (playerSpots[5] == 1 && gridSpots[3] == 0) || (playerSpots[7] == 1 && gridSpots[1] == 0) || (playerSpots[6] == 1 && gridSpots[2] == 0) || (playerSpots[3] == 1 && gridSpots[5] == 0))) ||
      ((playerSpots[8] == 1 && gridSpots[0] == 0) && ((playerSpots[1] == 1 && gridSpots[7] == 0) || (playerSpots[2] == 1 && gridSpots[6] == 0) || (playerSpots[5] == 1 && gridSpots[3] == 0) || (playerSpots[7] == 1 && gridSpots[1] == 0) || (playerSpots[6] == 1 && gridSpots[2] == 0) || (playerSpots[3] == 1 && gridSpots[5] == 0))) ||
      ((playerSpots[1] == 1 && gridSpots[7] == 0) && ((playerSpots[3] == 1 && gridSpots[5] == 0) || (playerSpots[5] == 1 && gridSpots[3] == 0))) || 
      ((playerSpots[7] == 1 && gridSpots[1] == 0) && ((playerSpots[3] == 1 && gridSpots[5] == 0) || (playerSpots[5] == 1 && gridSpots[3] == 0))))) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Make a fork here.", (w*1.5), (h*1.5) + 50);
    } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY <= h*2 && mouseY >= h) && 
      (gridSpots[5] == 0) && 
      (((playerSpots[4] == 1 && gridSpots[3] == 0) && ((playerSpots[2] == 1 && gridSpots[8] == 0) || (playerSpots[8] == 1 && gridSpots[2] == 0))) ||
      ((playerSpots[3] == 1 && gridSpots[4] == 0) && ((playerSpots[2] == 1 && gridSpots[8] == 0) || (playerSpots[8] == 1 && gridSpots[2] == 0))))) { 
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Make a fork here.", (w*2.5), (h*1.5) + 50);
    } else if ((mouseX <= w && mouseY <= h*3 && mouseY >= h*2) && 
      (gridSpots[6] == 0) && 
      (((playerSpots[4] == 1 && gridSpots[2] == 0) && ((playerSpots[3] == 1 && gridSpots[0] == 0) || (playerSpots[0] == 1 && gridSpots[3] == 0) || (playerSpots[7] == 1 && gridSpots[8] == 0) || (playerSpots[8] == 1 && gridSpots[7] == 0))) ||
      ((playerSpots[2] == 1 && gridSpots[4] == 0) && ((playerSpots[3] == 1 && gridSpots[0] == 0) || (playerSpots[0] == 1 && gridSpots[3] == 0) || (playerSpots[7] == 1 && gridSpots[8] == 0) || (playerSpots[8] == 1 && gridSpots[7] == 0))) || 
      ((playerSpots[0] == 1 && gridSpots[3] == 0) && ((playerSpots[7] == 1 && gridSpots[8] == 0) || (playerSpots[8] == 1 && gridSpots[7] == 0))) ||
      ((playerSpots[3] == 1 && gridSpots[0] == 0) && ((playerSpots[7] == 1 && gridSpots[8] == 0) || (playerSpots[8] == 1 && gridSpots[7] == 0))))) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Make a fork here.", (w/2), (h*2.5) + 50);
    } else if ((mouseX >= w && mouseX <= w*2 && mouseY <= h*3 && mouseY >= h*2) && 
      (gridSpots[7] == 0) && 
      (((playerSpots[4] == 1 && gridSpots[1] == 0) && ((playerSpots[6] == 1 && gridSpots[8] == 0) || (playerSpots[8] == 1 && gridSpots[6] == 0))) ||
      ((playerSpots[1] == 1 && gridSpots[4] == 0) && ((playerSpots[6] == 1 && gridSpots[8] == 0) || (playerSpots[8] == 1 && gridSpots[6] == 0))))) { 
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Make a fork here.", (w*1.5), (h*2.5) + 50);
    } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY <= h*3 && mouseY >= h*2) && 
      (gridSpots[8] == 0) && 
      (((playerSpots[4] == 1 && gridSpots[0] == 0) && ((playerSpots[5] == 1 && gridSpots[2] == 0) || (playerSpots[2] == 1 && gridSpots[5] == 0) || (playerSpots[7] == 1 && gridSpots[6] == 0) || (playerSpots[6] == 1 && gridSpots[7] == 0))) ||
      ((playerSpots[0] == 1 && gridSpots[4] == 0) && ((playerSpots[5] == 1 && gridSpots[2] == 0) || (playerSpots[2] == 1 && gridSpots[5] == 0) || (playerSpots[7] == 1 && gridSpots[6] == 0) || (playerSpots[6] == 1 && gridSpots[7] == 0))) || 
      ((playerSpots[6] == 1 && gridSpots[7] == 0) && ((playerSpots[5] == 1 && gridSpots[2] == 0) || (playerSpots[2] == 1 && gridSpots[5] == 0))) ||
      ((playerSpots[7] == 1 && gridSpots[6] == 0) && ((playerSpots[5] == 1 && gridSpots[2] == 0) || (playerSpots[2] == 1 && gridSpots[5] == 0))))) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Make a fork here.", (w*2.5), (h*2.5) + 50);
    }
  }
}

void detectPossibleBotFork() {
  /**
   Detects if there a possible fork that the player can create.
   A "fork" is a move that creates two winning moves.
   To understand all this jumbled up code, it basically every POSSIBLE fork.
   **/
  if (!userToWin && !botToWin) {
    if ((mouseX <= w && mouseY <= h) && 
      (gridSpots[0] == 0) && 
      (((botSpots[4] == 1 && gridSpots[8] == 0) && ((botSpots[1] == 1 && gridSpots[2] == 0) || (botSpots[2] == 1 && gridSpots[1] == 0) || (botSpots[3] == 1 && gridSpots[6] == 0) || (botSpots[6] == 1 && gridSpots[3] == 0))) ||
      ((botSpots[8] == 1 && gridSpots[1] == 0) && ((botSpots[1] == 1 && gridSpots[2] == 0) || (botSpots[2] == 1 && gridSpots[1] == 0) || (botSpots[3] == 1 && gridSpots[6] == 0) || (botSpots[6] == 1 && gridSpots[3] == 0))) || 
      ((botSpots[2] == 1 && gridSpots[1] == 0) && ((botSpots[3] == 1 && gridSpots[6] == 0) || (botSpots[6] == 1 && gridSpots[3] == 0))) ||
      ((botSpots[1] == 1 && gridSpots[2] == 0) && ((botSpots[3] == 1 && gridSpots[6] == 0) || (botSpots[6] == 1 && gridSpots[3] == 0))))) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Block fork here.", (w/2), (h/2) - 100);
    } else if ((mouseX >= w && mouseX <= w*2 && mouseY <= h) && 
      (gridSpots[1] == 0) && 
      (((botSpots[4] == 1 && gridSpots[7] == 0) && ((botSpots[0] == 1 && gridSpots[2] == 0) || (botSpots[2] == 1 && gridSpots[0] == 0))) ||
      ((botSpots[7] == 1 && gridSpots[4] == 0) && ((botSpots[0] == 1 && gridSpots[2] == 0) || (botSpots[2] == 1 && gridSpots[0] == 0))))) {    
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Block fork here.", (w*1.5), (h/2) - 100);
    } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY <= h) && 
      (gridSpots[2] == 0) && 
      (((botSpots[4] == 1 && gridSpots[6] == 0) && ((botSpots[1] == 1 && gridSpots[0] == 0) || (botSpots[0] == 1 && gridSpots[1] == 0) || (botSpots[5] == 1 && gridSpots[8] == 0) || (botSpots[8] == 1 && gridSpots[5] == 0))) ||
      ((botSpots[6] == 1 && gridSpots[4] == 0) && ((botSpots[1] == 1 && gridSpots[0] == 0) || (botSpots[0] == 1 && gridSpots[1] == 0) || (botSpots[5] == 1 && gridSpots[8] == 0) || (botSpots[8] == 1 && gridSpots[5] == 0))) || 
      ((botSpots[0] == 1 && gridSpots[1] == 0) && ((botSpots[5] == 1 && gridSpots[8] == 0) || (botSpots[8] == 1 && gridSpots[5] == 0))) ||
      ((botSpots[1] == 1 && gridSpots[0] == 0) && ((botSpots[5] == 1 && gridSpots[8] == 0) || (botSpots[8] == 1 && gridSpots[5] == 0))))) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Block fork here.", (w*2.5), (h/2) - 100);
    } else if ((mouseX <= w && mouseY <= h*2 && mouseY >= h) && 
      (gridSpots[3] == 0) && 
      (((botSpots[4] == 1 && gridSpots[5] == 0) && ((botSpots[0] == 1 && gridSpots[6] == 0) || (botSpots[6] == 1 && gridSpots[0] == 0))) ||
      ((botSpots[5] == 1 && gridSpots[4] == 0) && ((botSpots[0] == 1 && gridSpots[6] == 0) || (botSpots[6] == 1 && gridSpots[0] == 0))))) { 
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Block fork here.", (w/2), (h*1.5) - 100);
    } else if ((mouseX >= w && mouseX <= w*2 && mouseY <= h*2 && mouseY >= h) && 
      (gridSpots[4] == 0) && 
      (((botSpots[0] == 1 && gridSpots[8] == 0) && ((botSpots[1] == 1 && gridSpots[7] == 0) || (botSpots[2] == 1 && gridSpots[6] == 0) || (botSpots[5] == 1 && gridSpots[3] == 0) || (botSpots[7] == 1 && gridSpots[1] == 0) || (botSpots[6] == 1 && gridSpots[2] == 0) || (botSpots[3] == 1 && gridSpots[5] == 0))) ||
      ((botSpots[8] == 1 && gridSpots[0] == 0) && ((botSpots[1] == 1 && gridSpots[7] == 0) || (botSpots[2] == 1 && gridSpots[6] == 0) || (botSpots[5] == 1 && gridSpots[3] == 0) || (botSpots[7] == 1 && gridSpots[1] == 0) || (botSpots[6] == 1 && gridSpots[2] == 0) || (botSpots[3] == 1 && gridSpots[5] == 0))) ||
      ((botSpots[1] == 1 && gridSpots[7] == 0) && ((botSpots[3] == 1 && gridSpots[5] == 0) || (botSpots[5] == 1 && gridSpots[3] == 0))) || 
      ((botSpots[7] == 1 && gridSpots[1] == 0) && ((botSpots[3] == 1 && gridSpots[5] == 0) || (botSpots[5] == 1 && gridSpots[3] == 0))))) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Block fork here.", (w*1.5), (h*1.5) - 100);
    } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY <= h*2 && mouseY >= h) && 
      (gridSpots[5] == 0) && 
      (((botSpots[4] == 1 && gridSpots[3] == 0) && ((botSpots[2] == 1 && gridSpots[8] == 0) || (botSpots[8] == 1 && gridSpots[2] == 0))) ||
      ((botSpots[3] == 1 && gridSpots[4] == 0) && ((botSpots[2] == 1 && gridSpots[8] == 0) || (botSpots[8] == 1 && gridSpots[2] == 0))))) { 
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Block fork here.", (w*2.5), (h*1.5) - 100);
    } else if ((mouseX <= w && mouseY <= h*3 && mouseY >= h*2) && 
      (gridSpots[6] == 0) && 
      (((botSpots[4] == 1 && gridSpots[2] == 0) && ((botSpots[3] == 1 && gridSpots[0] == 0) || (botSpots[0] == 1 && gridSpots[3] == 0) || (botSpots[7] == 1 && gridSpots[8] == 0) || (botSpots[8] == 1 && gridSpots[7] == 0))) ||
      ((botSpots[2] == 1 && gridSpots[4] == 0) && ((botSpots[3] == 1 && gridSpots[0] == 0) || (botSpots[0] == 1 && gridSpots[3] == 0) || (botSpots[7] == 1 && gridSpots[8] == 0) || (botSpots[8] == 1 && gridSpots[7] == 0))) || 
      ((botSpots[0] == 1 && gridSpots[3] == 0) && ((botSpots[7] == 1 && gridSpots[8] == 0) || (botSpots[8] == 1 && gridSpots[7] == 0))) ||
      ((botSpots[3] == 1 && gridSpots[0] == 0) && ((botSpots[7] == 1 && gridSpots[8] == 0) || (botSpots[8] == 1 && gridSpots[7] == 0))))) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Block fork here.", (w/2), (h*2.5) - 100);
    } else if ((mouseX >= w && mouseX <= w*2 && mouseY <= h*3 && mouseY >= h*2) && 
      (gridSpots[7] == 0) && 
      (((botSpots[4] == 1 && gridSpots[1] == 0) && ((botSpots[6] == 1 && gridSpots[8] == 0) || (botSpots[8] == 1 && gridSpots[6] == 0))) ||
      ((botSpots[1] == 1 && gridSpots[4] == 0) && ((botSpots[6] == 1 && gridSpots[8] == 0) || (botSpots[8] == 1 && gridSpots[6] == 0))))) { 
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Block fork here.", (w*1.5), (h*2.5) - 100);
    } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY <= h*3 && mouseY >= h*2) && 
      (gridSpots[8] == 0) && 
      (((botSpots[4] == 1 && gridSpots[0] == 0) && ((botSpots[5] == 1 && gridSpots[2] == 0) || (botSpots[2] == 1 && gridSpots[5] == 0) || (botSpots[7] == 1 && gridSpots[6] == 0) || (botSpots[6] == 1 && gridSpots[7] == 0))) ||
      ((botSpots[0] == 1 && gridSpots[4] == 0) && ((botSpots[5] == 1 && gridSpots[2] == 0) || (botSpots[2] == 1 && gridSpots[5] == 0) || (botSpots[7] == 1 && gridSpots[6] == 0) || (botSpots[6] == 1 && gridSpots[7] == 0))) || 
      ((botSpots[6] == 1 && gridSpots[7] == 0) && ((botSpots[5] == 1 && gridSpots[2] == 0) || (botSpots[2] == 1 && gridSpots[5] == 0))) ||
      ((botSpots[7] == 1 && gridSpots[6] == 0) && ((botSpots[5] == 1 && gridSpots[2] == 0) || (botSpots[2] == 1 && gridSpots[5] == 0))))) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Block fork here.", (w*2.5), (h*2.5) - 100);
    }
  }
}

void detectPossibleWin() {
  /**
   Detects if there is a possible spot the player can win in. All types of wins supported.
   **/
  // ROWS (RIGHT | MIDDLE | LEFT)
  if (((playerSpots[1] == 1 && playerSpots[2] == 1)||(playerSpots[3] == 1 && playerSpots[6] == 1)||(playerSpots[4] == 1 && playerSpots[8] == 1)) && gridSpots[0] != 1) { //Top Left Corner
    if ((mouseX <= w && mouseY <= h) && (gridSpots[0] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Winning Move!", (w/2), (h/2));
    } else if ((mouseX <= w*2 && mouseX >= w && mouseY <= h) && (gridSpots[1] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*1.5), (h/2));
    } else if ((mouseX <= w*3 && mouseX >= w*2 && mouseY <= h) && (gridSpots[2] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*2.5), (h/2));
    } else if ((mouseX <= w && mouseY >= h && mouseY <= h*2) && (gridSpots[3] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w/2), (h*1.5));
    } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h && mouseY <= h*2) && (gridSpots[4] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*1.5), (h*1.5));
    } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h && mouseY <= h*2) && (gridSpots[5] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*2.5), (h*1.5));
    } else if ((mouseX <= w && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[6] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w/2), (h*2.5));
    } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[7] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*1.5), (h*2.5));
    } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[8] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*2.5), (h*2.5));
    }
    userToWin = true;
  } else if (((playerSpots[0] == 1 && playerSpots[2] == 1)||(playerSpots[4] == 1 && playerSpots[7] == 1)) && gridSpots[1] != 1) { //Top Middle
    if ((mouseX <= w && mouseY <= h) && (gridSpots[0] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w/2), (h/2));
    } else if ((mouseX <= w*2 && mouseX >= w && mouseY <= h) && (gridSpots[1] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Winning Move!", (w*1.5), (h/2));
    } else if ((mouseX <= w*3 && mouseX >= w*2 && mouseY <= h) && (gridSpots[2] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*2.5), (h/2));
    } else if ((mouseX <= w && mouseY >= h && mouseY <= h*2) && (gridSpots[3] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w/2), (h*1.5));
    } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h && mouseY <= h*2) && (gridSpots[4] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*1.5), (h*1.5));
    } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h && mouseY <= h*2) && (gridSpots[5] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*2.5), (h*1.5));
    } else if ((mouseX <= w && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[6] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w/2), (h*2.5));
    } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[7] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*1.5), (h*2.5));
    } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[8] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*2.5), (h*2.5));
    }
    userToWin = true;
  } else if (((playerSpots[0] == 1 && playerSpots[1] == 1)||(playerSpots[6] == 1 && playerSpots[4] == 1)||(playerSpots[5] == 1 && playerSpots[8] == 1)) && gridSpots[2] != 1) { //Top Right Corner
    if ((mouseX <= w && mouseY <= h) && (gridSpots[0] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w/2), (h/2));
    } else if ((mouseX <= w*2 && mouseX >= w && mouseY <= h) && (gridSpots[1] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*1.5), (h/2));
    } else if ((mouseX <= w*3 && mouseX >= w*2 && mouseY <= h) && (gridSpots[2] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Winning Move!", (w*2.5), (h/2));
    } else if ((mouseX <= w && mouseY >= h && mouseY <= h*2) && (gridSpots[3] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w/2), (h*1.5));
    } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h && mouseY <= h*2) && (gridSpots[4] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*1.5), (h*1.5));
    } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h && mouseY <= h*2) && (gridSpots[5] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*2.5), (h*1.5));
    } else if ((mouseX <= w && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[6] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w/2), (h*2.5));
    } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[7] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*1.5), (h*2.5));
    } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[8] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*2.5), (h*2.5));
    }
    userToWin = true;
  } else if (((playerSpots[0] == 1 && playerSpots[6] == 1)||(playerSpots[4] == 1 && playerSpots[5] == 1)) && gridSpots[3] != 1) { //Middle Left
    if ((mouseX <= w && mouseY <= h) && (gridSpots[0] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w/2), (h/2));
    } else if ((mouseX <= w*2 && mouseX >= w && mouseY <= h) && (gridSpots[1] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*1.5), (h/2));
    } else if ((mouseX <= w*3 && mouseX >= w*2 && mouseY <= h) && (gridSpots[2] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*2.5), (h/2));
    } else if ((mouseX <= w && mouseY >= h && mouseY <= h*2) && (gridSpots[3] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Winning Move!", (w/2), (h*1.5));
    } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h && mouseY <= h*2) && (gridSpots[4] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*1.5), (h*1.5));
    } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h && mouseY <= h*2) && (gridSpots[5] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*2.5), (h*1.5));
    } else if ((mouseX <= w && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[6] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w/2), (h*2.5));
    } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[7] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*1.5), (h*2.5));
    } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[8] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*2.5), (h*2.5));
    }
    userToWin = true;
  } else if (((playerSpots[0] == 1 && playerSpots[8] == 1)||(playerSpots[2] == 1 && playerSpots[6] == 1)||(playerSpots[3] == 1 && playerSpots[5] == 1)||(playerSpots[1] == 1 && playerSpots[7] == 1)) && gridSpots[4] != 1) { //Middle Middle
    if ((mouseX <= w && mouseY <= h) && (gridSpots[0] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w/2), (h/2));
    } else if ((mouseX <= w*2 && mouseX >= w && mouseY <= h) && (gridSpots[1] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*1.5), (h/2));
    } else if ((mouseX <= w*3 && mouseX >= w*2 && mouseY <= h) && (gridSpots[2] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*2.5), (h/2));
    } else if ((mouseX <= w && mouseY >= h && mouseY <= h*2) && (gridSpots[3] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w/2), (h*1.5));
    } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h && mouseY <= h*2) && (gridSpots[4] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Winning Move!", (w*1.5), (h*1.5));
    } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h && mouseY <= h*2) && (gridSpots[5] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*2.5), (h*1.5));
    } else if ((mouseX <= w && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[6] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w/2), (h*2.5));
    } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[7] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*1.5), (h*2.5));
    } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[8] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*2.5), (h*2.5));
    }
    userToWin = true;
  } else if (((playerSpots[3] == 1 && playerSpots[4] == 1)||(playerSpots[2] == 1 && playerSpots[8] == 1)) && gridSpots[5] != 1) { //Middle Right
    if ((mouseX <= w && mouseY <= h) && (gridSpots[0] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w/2), (h/2));
    } else if ((mouseX <= w*2 && mouseX >= w && mouseY <= h) && (gridSpots[1] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*1.5), (h/2));
    } else if ((mouseX <= w*3 && mouseX >= w*2 && mouseY <= h) && (gridSpots[2] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*2.5), (h/2));
    } else if ((mouseX <= w && mouseY >= h && mouseY <= h*2) && (gridSpots[3] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w/2), (h*1.5));
    } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h && mouseY <= h*2) && (gridSpots[4] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*1.5), (h*1.5));
    } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h && mouseY <= h*2) && (gridSpots[5] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Winning Move!", (w*2.5), (h*1.5));
    } else if ((mouseX <= w && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[6] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w/2), (h*2.5));
    } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[7] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*1.5), (h*2.5));
    } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[8] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*2.5), (h*2.5));
    }
    userToWin = true;
  } else if (((playerSpots[0] == 1 && playerSpots[3] == 1)||(playerSpots[2] == 1 && playerSpots[4] == 1)||(playerSpots[7] == 1 && playerSpots[8] == 1)) && gridSpots[6] != 1) { //Bottom Left
    if ((mouseX <= w && mouseY <= h) && (gridSpots[0] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w/2), (h/2));
    } else if ((mouseX <= w*2 && mouseX >= w && mouseY <= h) && (gridSpots[1] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*1.5), (h/2));
    } else if ((mouseX <= w*3 && mouseX >= w*2 && mouseY <= h) && (gridSpots[2] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*2.5), (h/2));
    } else if ((mouseX <= w && mouseY >= h && mouseY <= h*2) && (gridSpots[3] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w/2), (h*1.5));
    } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h && mouseY <= h*2) && (gridSpots[4] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*1.5), (h*1.5));
    } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h && mouseY <= h*2) && (gridSpots[5] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*2.5), (h*1.5));
    } else if ((mouseX <= w && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[6] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Winning Move!", (w/2), (h*2.5));
    } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[7] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*1.5), (h*2.5));
    } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[8] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*2.5), (h*2.5));
    }
    userToWin = true;
  } else if (((playerSpots[1] == 1 && playerSpots[4] == 1)||(playerSpots[6] == 1 && playerSpots[8] == 1)) && gridSpots[7] != 1) { //Bottom Middle
    if ((mouseX <= w && mouseY <= h) && (gridSpots[0] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w/2), (h/2));
    } else if ((mouseX <= w*2 && mouseX >= w && mouseY <= h) && (gridSpots[1] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*1.5), (h/2));
    } else if ((mouseX <= w*3 && mouseX >= w*2 && mouseY <= h) && (gridSpots[2] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*2.5), (h/2));
    } else if ((mouseX <= w && mouseY >= h && mouseY <= h*2) && (gridSpots[3] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w/2), (h*1.5));
    } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h && mouseY <= h*2) && (gridSpots[4] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*1.5), (h*1.5));
    } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h && mouseY <= h*2) && (gridSpots[5] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*2.5), (h*1.5));
    } else if ((mouseX <= w && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[6] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w/2), (h*2.5));
    } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[7] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Winning Move!", (w*1.5), (h*2.5));
    } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[8] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*2.5), (h*2.5));
    }
    userToWin = true;
  } else if (((playerSpots[2] == 1 && playerSpots[5] == 1)||(playerSpots[0] == 1 && playerSpots[4] == 1)||(playerSpots[6] == 1 && playerSpots[7] == 1)) && gridSpots[8] != 1) { //Bottom Right
    if ((mouseX <= w && mouseY <= h) && (gridSpots[0] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w/2), (h/2));
    } else if ((mouseX <= w*2 && mouseX >= w && mouseY <= h) && (gridSpots[1] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*1.5), (h/2));
    } else if ((mouseX <= w*3 && mouseX >= w*2 && mouseY <= h) && (gridSpots[2] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*2.5), (h/2));
    } else if ((mouseX <= w && mouseY >= h && mouseY <= h*2) && (gridSpots[3] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w/2), (h*1.5));
    } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h && mouseY <= h*2) && (gridSpots[4] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*1.5), (h*1.5));
    } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h && mouseY <= h*2) && (gridSpots[5] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*2.5), (h*1.5));
    } else if ((mouseX <= w && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[6] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w/2), (h*2.5));
    } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[7] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Better move possible", (w*1.5), (h*2.5));
    } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[8] == 0)) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Winning Move!", (w*2.5), (h*2.5));
    }
    userToWin = true;
  }
}


void detectPossibleBotWin() {
  /**
   Detects if there is a winning move that the bot could make, if so, advise the player to block it if they hover over the square.
   **/
  // ROWS (RIGHT | MIDDLE | LEFT)
  if (!userToWin) {
    if (((botSpots[1] == 1 && botSpots[2] == 1)||(botSpots[3] == 1 && botSpots[6] == 1)||(botSpots[4] == 1 && botSpots[8] == 1)) && gridSpots[0] != 1) { //Top Left Corner
      if ((mouseX <= w && mouseY <= h) && (gridSpots[0] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Block here!", (w/2), (h/2));
      } else if ((mouseX <= w*2 && mouseX >= w && mouseY <= h) && (gridSpots[1] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*1.5), (h/2));
      } else if ((mouseX <= w*3 && mouseX >= w*2 && mouseY <= h) && (gridSpots[2] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*2.5), (h/2));
      } else if ((mouseX <= w && mouseY >= h && mouseY <= h*2) && (gridSpots[3] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w/2), (h*1.5));
      } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h && mouseY <= h*2) && (gridSpots[4] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*1.5), (h*1.5));
      } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h && mouseY <= h*2) && (gridSpots[5] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*2.5), (h*1.5));
      } else if ((mouseX <= w && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[6] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w/2), (h*2.5));
      } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[7] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*1.5), (h*2.5));
      } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[8] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*2.5), (h*2.5));
      }
      botToWin = true;
    } else if (((botSpots[0] == 1 && botSpots[2] == 1)||(botSpots[4] == 1 && botSpots[7] == 1)) && gridSpots[1] != 1) { //Top Middle
      if ((mouseX <= w && mouseY <= h) && (gridSpots[0] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w/2), (h/2));
      } else if ((mouseX <= w*2 && mouseX >= w && mouseY <= h) && (gridSpots[1] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Block here!", (w*1.5), (h/2));
      } else if ((mouseX <= w*3 && mouseX >= w*2 && mouseY <= h) && (gridSpots[2] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*2.5), (h/2));
      } else if ((mouseX <= w && mouseY >= h && mouseY <= h*2) && (gridSpots[3] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w/2), (h*1.5));
      } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h && mouseY <= h*2) && (gridSpots[4] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*1.5), (h*1.5));
      } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h && mouseY <= h*2) && (gridSpots[5] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*2.5), (h*1.5));
      } else if ((mouseX <= w && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[6] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w/2), (h*2.5));
      } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[7] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*1.5), (h*2.5));
      } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[8] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*2.5), (h*2.5));
      }
      botToWin = true;
    } else if (((botSpots[0] == 1 && botSpots[1] == 1)||(botSpots[6] == 1 && botSpots[4] == 1)||(botSpots[5] == 1 && botSpots[8] == 1)) && gridSpots[2] != 1) { //Top Right Corner
      if ((mouseX <= w && mouseY <= h) && (gridSpots[0] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w/2), (h/2));
      } else if ((mouseX <= w*2 && mouseX >= w && mouseY <= h) && (gridSpots[1] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*1.5), (h/2));
      } else if ((mouseX <= w*3 && mouseX >= w*2 && mouseY <= h) && (gridSpots[2] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Block here!", (w*2.5), (h/2));
      } else if ((mouseX <= w && mouseY >= h && mouseY <= h*2) && (gridSpots[3] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w/2), (h*1.5));
      } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h && mouseY <= h*2) && (gridSpots[4] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*1.5), (h*1.5));
      } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h && mouseY <= h*2) && (gridSpots[5] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*2.5), (h*1.5));
      } else if ((mouseX <= w && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[6] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w/2), (h*2.5));
      } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[7] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*1.5), (h*2.5));
      } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[8] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*2.5), (h*2.5));
      }
      botToWin = true;
    } else if (((botSpots[0] == 1 && botSpots[6] == 1)||(botSpots[4] == 1 && botSpots[5] == 1)) && gridSpots[3] != 1) { //Middle Left
      if ((mouseX <= w && mouseY <= h) && (gridSpots[0] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w/2), (h/2));
      } else if ((mouseX <= w*2 && mouseX >= w && mouseY <= h) && (gridSpots[1] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*1.5), (h/2));
      } else if ((mouseX <= w*3 && mouseX >= w*2 && mouseY <= h) && (gridSpots[2] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*2.5), (h/2));
      } else if ((mouseX <= w && mouseY >= h && mouseY <= h*2) && (gridSpots[3] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Block here!", (w/2), (h*1.5));
      } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h && mouseY <= h*2) && (gridSpots[4] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*1.5), (h*1.5));
      } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h && mouseY <= h*2) && (gridSpots[5] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*2.5), (h*1.5));
      } else if ((mouseX <= w && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[6] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w/2), (h*2.5));
      } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[7] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*1.5), (h*2.5));
      } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[8] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*2.5), (h*2.5));
      }
      botToWin = true;
    } else if (((botSpots[0] == 1 && botSpots[8] == 1)||(botSpots[2] == 1 && botSpots[6] == 1)||(botSpots[3] == 1 && botSpots[5] == 1)||(botSpots[1] == 1 && botSpots[7] == 1)) && gridSpots[4] != 1) { //Middle Middle
      if ((mouseX <= w && mouseY <= h) && (gridSpots[0] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w/2), (h/2));
      } else if ((mouseX <= w*2 && mouseX >= w && mouseY <= h) && (gridSpots[1] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*1.5), (h/2));
      } else if ((mouseX <= w*3 && mouseX >= w*2 && mouseY <= h) && (gridSpots[2] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*2.5), (h/2));
      } else if ((mouseX <= w && mouseY >= h && mouseY <= h*2) && (gridSpots[3] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w/2), (h*1.5));
      } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h && mouseY <= h*2) && (gridSpots[4] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Block here!", (w*1.5), (h*1.5));
      } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h && mouseY <= h*2) && (gridSpots[5] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*2.5), (h*1.5));
      } else if ((mouseX <= w && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[6] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w/2), (h*2.5));
      } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[7] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*1.5), (h*2.5));
      } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[8] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*2.5), (h*2.5));
      }
      botToWin = true;
    } else if (((botSpots[3] == 1 && botSpots[4] == 1)||(botSpots[2] == 1 && botSpots[8] == 1)) && gridSpots[5] != 1) { //Middle Right
      if ((mouseX <= w && mouseY <= h) && (gridSpots[0] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w/2), (h/2));
      } else if ((mouseX <= w*2 && mouseX >= w && mouseY <= h) && (gridSpots[1] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*1.5), (h/2));
      } else if ((mouseX <= w*3 && mouseX >= w*2 && mouseY <= h) && (gridSpots[2] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*2.5), (h/2));
      } else if ((mouseX <= w && mouseY >= h && mouseY <= h*2) && (gridSpots[3] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w/2), (h*1.5));
      } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h && mouseY <= h*2) && (gridSpots[4] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*1.5), (h*1.5));
      } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h && mouseY <= h*2) && (gridSpots[5] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Block here!", (w*2.5), (h*1.5));
      } else if ((mouseX <= w && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[6] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w/2), (h*2.5));
      } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[7] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*1.5), (h*2.5));
      } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[8] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*2.5), (h*2.5));
      }
      botToWin = true;
    } else if (((botSpots[0] == 1 && botSpots[3] == 1)||(botSpots[2] == 1 && botSpots[4] == 1)||(botSpots[7] == 1 && botSpots[8] == 1)) && gridSpots[6] != 1) { //Bottom Left
      if ((mouseX <= w && mouseY <= h) && (gridSpots[0] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w/2), (h/2));
      } else if ((mouseX <= w*2 && mouseX >= w && mouseY <= h) && (gridSpots[1] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*1.5), (h/2));
      } else if ((mouseX <= w*3 && mouseX >= w*2 && mouseY <= h) && (gridSpots[2] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*2.5), (h/2));
      } else if ((mouseX <= w && mouseY >= h && mouseY <= h*2) && (gridSpots[3] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w/2), (h*1.5));
      } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h && mouseY <= h*2) && (gridSpots[4] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*1.5), (h*1.5));
      } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h && mouseY <= h*2) && (gridSpots[5] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*2.5), (h*1.5));
      } else if ((mouseX <= w && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[6] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Block here!", (w/2), (h*2.5));
      } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[7] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*1.5), (h*2.5));
      } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[8] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*2.5), (h*2.5));
      }
      botToWin = true;
    } else if (((botSpots[1] == 1 && botSpots[4] == 1)||(botSpots[6] == 1 && botSpots[8] == 1)) && gridSpots[7] != 1) { //Bottom Middle
      if ((mouseX <= w && mouseY <= h) && (gridSpots[0] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w/2), (h/2));
      } else if ((mouseX <= w*2 && mouseX >= w && mouseY <= h) && (gridSpots[1] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*1.5), (h/2));
      } else if ((mouseX <= w*3 && mouseX >= w*2 && mouseY <= h) && (gridSpots[2] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*2.5), (h/2));
      } else if ((mouseX <= w && mouseY >= h && mouseY <= h*2) && (gridSpots[3] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w/2), (h*1.5));
      } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h && mouseY <= h*2) && (gridSpots[4] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*1.5), (h*1.5));
      } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h && mouseY <= h*2) && (gridSpots[5] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*2.5), (h*1.5));
      } else if ((mouseX <= w && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[6] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w/2), (h*2.5));
      } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[7] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Block here!", (w*1.5), (h*2.5));
      } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[8] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*2.5), (h*2.5));
      }
      botToWin = true;
    } else if (((botSpots[2] == 1 && botSpots[5] == 1)||(botSpots[0] == 1 && botSpots[4] == 1)||(botSpots[6] == 1 && botSpots[7] == 1)) && gridSpots[8] != 1) { //Bottom Right
      if ((mouseX <= w && mouseY <= h) && (gridSpots[0] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w/2), (h/2));
      } else if ((mouseX <= w*2 && mouseX >= w && mouseY <= h) && (gridSpots[1] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*1.5), (h/2));
      } else if ((mouseX <= w*3 && mouseX >= w*2 && mouseY <= h) && (gridSpots[2] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*2.5), (h/2));
      } else if ((mouseX <= w && mouseY >= h && mouseY <= h*2) && (gridSpots[3] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w/2), (h*1.5));
      } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h && mouseY <= h*2) && (gridSpots[4] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*1.5), (h*1.5));
      } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h && mouseY <= h*2) && (gridSpots[5] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*2.5), (h*1.5));
      } else if ((mouseX <= w && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[6] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w/2), (h*2.5));
      } else if ((mouseX >= w && mouseX <= w*2 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[7] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Need to Block!", (w*1.5), (h*2.5));
      } else if ((mouseX >= w*2 && mouseX <= w*3 && mouseY >= h*2 && mouseY <= h*3) && (gridSpots[8] == 0)) {
        fill(0);
        textSize(30);
        textAlign(CENTER);
        text("Block here!", (w*2.5), (h*2.5));
      }
      botToWin = true;
    }
  }
}

void printPlayer() {
  /**
   Displays the spots that the player has picked.
   **/
  for (int i=0; i<playerSpots.length; i++) {
    int row = i % 3;
    int col = i / 3;
    if (playerSpots[i] == 1) {
      image(imgx, w*row, h*col, w, h);
    }
  }
}

void printBot() {
  /**
   Displays the spots that the bot has picked.
   **/
  for (int i=0; i<botSpots.length; i++) {
    int row = i % 3;
    int col = i / 3;
    if (botSpots[i] == 1) {
      image(imgo, w*row, h*col, w, h);
    }
  }
}

void bot() {
  /**
   The logic behind the bot, determining if the spot is taken and where to take the next step.
   **/
  Random rand = new Random(); // used to determine the next spot
  int n = rand.nextInt(9);
  while (gridSpots[n] == 1) { // if spot is taken rerun until a spot is open
    n = rand.nextInt(9);
  }
  if (((botSpots[1] == 1 && botSpots[2] == 1)||(botSpots[3] == 1 && botSpots[6] == 1)||(botSpots[4] == 1 && botSpots[8] == 1)) && gridSpots[0] != 1) { //Top Left Corner
    gridSpots[0] = 1;
    botSpots[0] = 1;
    playerTurn = true;
    botTurn = false;
    botMoves.push(0);
  } else if (((botSpots[0] == 1 && botSpots[2] == 1)||(botSpots[4] == 1 && botSpots[7] == 1)) && gridSpots[1] != 1) { //Top Middle
    gridSpots[1] = 1;
    botSpots[1] = 1;
    playerTurn = true;
    botTurn = false;
    botMoves.push(1);
  } else if (((botSpots[0] == 1 && botSpots[1] == 1)||(botSpots[6] == 1 && botSpots[4] == 1)||(botSpots[5] == 1 && botSpots[8] == 1)) && gridSpots[2] != 1) { //Tope Right Corner
    gridSpots[2] = 1;
    botSpots[2] = 1;
    playerTurn = true;
    botTurn = false;
    botMoves.push(2);
  } else if (((botSpots[0] == 1 && botSpots[6] == 1)||(botSpots[4] == 1 && botSpots[5] == 1)) && botSpots[3] != 1 && gridSpots[3] != 1) { //Middle Left
    gridSpots[3] = 1;
    botSpots[3] = 1;
    playerTurn = true;
    botTurn = false;
    botMoves.push(3);
  } else if (((botSpots[0] == 1 && botSpots[8] == 1)||(botSpots[2] == 1 && botSpots[6] == 1)||(botSpots[3] == 1 && botSpots[5] == 1)||(botSpots[1] == 1 && botSpots[7] == 1)) && gridSpots[4] != 1) { //Middle Middle
    gridSpots[4] = 1;
    botSpots[4] = 1;
    playerTurn = true;
    botTurn = false;
    botMoves.push(4);
  } else if (((botSpots[3] == 1 && botSpots[4] == 1)||(botSpots[2] == 1 && botSpots[8] == 1)) && gridSpots[5] != 1) { //Middle Right
    gridSpots[5] = 1;
    botSpots[5] = 1;
    playerTurn = true;
    botTurn = false;
    botMoves.push(5);
  } else if (((botSpots[0] == 1 && botSpots[3] == 1)||(botSpots[2] == 1 && botSpots[4] == 1)||(botSpots[7] == 1 && botSpots[8] == 1)) && gridSpots[6] != 1) { //Bottom Left
    gridSpots[6] = 1;
    botSpots[6] = 1;
    playerTurn = true;
    botTurn = false;
    botMoves.push(6);
  } else if (((botSpots[1] == 1 && botSpots[4] == 1)||(botSpots[6] == 1 && botSpots[8] == 1)) && gridSpots[7] != 1) { //Bottom Middle
    gridSpots[7] = 1;
    botSpots[7] = 1;
    playerTurn = true;
    botTurn = false;
    botMoves.push(7);
  } else if (((botSpots[2] == 1 && botSpots[5] == 1)||(botSpots[0] == 1 && botSpots[4] == 1)||(botSpots[6] == 1 && botSpots[7] == 1)) && gridSpots[8] != 1) { //Bottom Right
    gridSpots[8] = 1;
    botSpots[8] = 1;
    playerTurn = true;
    botTurn = false;
    botMoves.push(8);
  } else {
    if (((playerSpots[1] == 1 && playerSpots[2] == 1)||(playerSpots[3] == 1 && playerSpots[6] == 1)||(playerSpots[4] == 1 && playerSpots[8] == 1)) && gridSpots[0] != 1) { //Top Left Corner
      gridSpots[0] = 1;
      botSpots[0] = 1;
      playerTurn = true;
      botTurn = false;
      botMoves.push(0);
    } else if (((playerSpots[0] == 1 && playerSpots[2] == 1)||(playerSpots[4] == 1 && playerSpots[7] == 1)) && gridSpots[1] != 1) { //Top Middle
      gridSpots[1] = 1;
      botSpots[1] = 1;
      playerTurn = true;
      botTurn = false;
      botMoves.push(1);
    } else if (((playerSpots[0] == 1 && playerSpots[1] == 1)||(playerSpots[6] == 1 && playerSpots[4] == 1)||(playerSpots[5] == 1 && playerSpots[8] == 1)) && gridSpots[2] != 1) { //Tope Right Corner
      gridSpots[2] = 1;
      botSpots[2] = 1;
      playerTurn = true;
      botTurn = false;
      botMoves.push(2);
    } else if (((playerSpots[0] == 1 && playerSpots[6] == 1)||(playerSpots[4] == 1 && playerSpots[5] == 1)) && gridSpots[3] != 1) { //Middle Left
      gridSpots[3] = 1;
      botSpots[3] = 1;
      playerTurn = true;
      botTurn = false;
      botMoves.push(3);
    } else if (((playerSpots[0] == 1 && playerSpots[8] == 1)||(playerSpots[2] == 1 && playerSpots[6] == 1)||(playerSpots[3] == 1 && playerSpots[5] == 1)||(playerSpots[1] == 1 && playerSpots[7] == 1)) && gridSpots[4] != 1) { //Middle Middle
      gridSpots[4] = 1;
      botSpots[4] = 1;
      playerTurn = true;
      botTurn = false;
      botMoves.push(4);
    } else if (((playerSpots[3] == 1 && playerSpots[4] == 1)||(playerSpots[2] == 1 && playerSpots[8] == 1)) && gridSpots[5] != 1) { //Middle Right
      gridSpots[5] = 1;
      botSpots[5] = 1;
      playerTurn = true;
      botTurn = false;
      botMoves.push(5);
    } else if (((playerSpots[0] == 1 && playerSpots[3] == 1)||(playerSpots[2] == 1 && playerSpots[4] == 1)||(playerSpots[7] == 1 && playerSpots[8] == 1)) && gridSpots[6] != 1) { //Bottom Left
      gridSpots[6] = 1;
      botSpots[6] = 1;
      playerTurn = true;
      botTurn = false;
      botMoves.push(6);
    } else if (((playerSpots[1] == 1 && playerSpots[4] == 1)||(playerSpots[6] == 1 && playerSpots[8] == 1)) && gridSpots[7] != 1) { //Bottom Middle
      gridSpots[7] = 1;
      botSpots[7] = 1;
      playerTurn = true;
      botTurn = false;
      botMoves.push(7);
    } else if (((playerSpots[2] == 1 && playerSpots[5] == 1)||(playerSpots[0] == 1 && playerSpots[4] == 1)||(playerSpots[6] == 1 && playerSpots[7] == 1)) && gridSpots[8] != 1) { //Bottom Right
      gridSpots[8] = 1;
      botSpots[8] = 1;
      playerTurn = true;
      botTurn = false;
      botMoves.push(8);
    } else {
      if (n == 0) {
        gridSpots[n] = 1;
        botSpots[n] = 1;
        botMoves.push(n);
      } else if (n == 1) {
        gridSpots[n] = 1;
        botSpots[n] = 1;
        botMoves.push(n);
      } else if (n == 2) {
        gridSpots[n] = 1;
        botSpots[n] = 1;
        botMoves.push(n);
      } else if (n == 3) {
        gridSpots[n] = 1;
        botSpots[n] = 1;
        botMoves.push(n);
      } else if (n == 4) {
        gridSpots[n] = 1;
        botSpots[n] = 1;
        botMoves.push(n);
      } else if (n == 5) {
        gridSpots[n] = 1;
        botSpots[n] = 1;
        botMoves.push(n);
      } else if (n == 6) {
        gridSpots[n] = 1;
        botSpots[n] = 1;
        botMoves.push(n);
      } else if (n == 7) {
        gridSpots[n] = 1;
        botSpots[n] = 1;
        botMoves.push(n);
      } else if (n == 8) {
        gridSpots[n] = 1;
        botSpots[n] = 1;
        botMoves.push(n);
      }
      //DEBUG PT 2
      //playerTurn = true;
      //botTurn = false;
    }
  }
  playerTurn = true;
  botTurn = false;
  playCount++; // increase how many plays have gone by
}

void isTie() {
  /**
   Determines if the game has resulted in a tie
   **/
  if (!won) {
    println("Playcount " + playCount);
    textAlign(CENTER);
    textSize(60);
    fill(102, 102, 255);
    text("It's a tie!", width/2, height/2);
    gameOver = true;
  }
}

void rowWin() {
  /**
   Determines if the game has been won but with 3 in a row
   **/
  if (playerSpots[0] == 1 && playerSpots[1] == 1 && playerSpots[2] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(0, 128, 0);
    text("Player wins in " + playCount + " turns", width/2, height/2);
    gameOver = true;
    won = true;
    playerWon = true;
  } else if (playerSpots[3] == 1 && playerSpots[4] == 1 && playerSpots[5] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(0, 128, 0);
    text("Player wins in " + playCount + " turns", width/2, height/2);
    gameOver = true;
    won = true;
    playerWon = true;
  } else if (playerSpots[6] == 1 && playerSpots[7] == 1 && playerSpots[8] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(0, 128, 0);
    text("Player wins in " + playCount + " turns", width/2, height/2);
    gameOver = true;
    won = true;
    playerWon = true;
  } else if (botSpots[0] == 1 && botSpots[1] == 1 && botSpots[2] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(178, 34, 34);
    text("Bot wins in " + playCount + " turns", width/2, height/2);
    gameOver = true;
    won = true;
    botWon = true;
  } else if (botSpots[3] == 1 && botSpots[4] == 1 && botSpots[5] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(178, 34, 34);
    text("Bot wins in " + playCount + " turns", width/2, height/2);
    gameOver = true;
    won = true;
    botWon = true;
  } else if (botSpots[6] == 1 && botSpots[7] == 1 && botSpots[8] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(178, 34, 34);
    text("Bot wins in " + playCount + " turns", width/2, height/2);
    gameOver = true;
    won = true;
    botWon = true;
  }
}

void colWin() {
  /**
   Determines if the game has been won but with 3 in a row, in a column
   **/
  if (playerSpots[0] == 1 && playerSpots[3] == 1 && playerSpots[6] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(0, 128, 0);
    text("Player wins in " + playCount + " turns", width/2, height/2);
    gameOver = true;
    won = true;
    playerWon = true;
  } else if (playerSpots[1] == 1 && playerSpots[4] == 1 && playerSpots[7] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(0, 128, 0);
    text("Player wins in " + playCount + " turns", width/2, height/2);
    gameOver = true;
    won = true;
    playerWon = true;
  } else if (playerSpots[2] == 1 && playerSpots[5] == 1 && playerSpots[8] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(0, 128, 0);
    text("Player wins in " + playCount + " turns", width/2, height/2);
    gameOver = true;
    won = true;
    playerWon = true;
  } else if (botSpots[0] == 1 && botSpots[3] == 1 && botSpots[6] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(178, 34, 34);
    text("Bot wins in " + playCount + " turns", width/2, height/2);
    gameOver = true;
    won = true;
    botWon = true;
  } else if (botSpots[1] == 1 && botSpots[4] == 1 && botSpots[7] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(178, 34, 34);
    text("Bot wins in " + playCount + " turns", width/2, height/2); 
    gameOver = true;
    won = true;
    botWon = true;
  } else if (botSpots[2] == 1 && botSpots[5] == 1 && botSpots[8] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(178, 34, 34);
    text("Bot wins in " + playCount + " turns", width/2, height/2);
    gameOver = true;
    won = true;
    botWon = true;
  }
}

void diagWin() {
  /**
   Determines if the game has been won but with 3 in a row, diagonally
   **/
  if (playerSpots[0] == 1 && playerSpots[4] == 1 && playerSpots[8] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(0, 128, 0);
    text("Player wins in " + playCount + " turns", width/2, height/2);
    gameOver = true;
    won = true;
    playerWon = true;
  } else if (playerSpots[2] == 1 && playerSpots[4] == 1 && playerSpots[6] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(0, 128, 0);
    text("Player wins in " + playCount + " turns", width/2, height/2);
    gameOver = true;
    won = true;
    playerWon = true;
  } else if (botSpots[0] == 1 && botSpots[4] == 1 && botSpots[8] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(178, 34, 34);
    text("Bot wins in " + playCount + " turns", width/2, height/2);
    gameOver = true;
    won = true;
    botWon = true;
  } else if (botSpots[2] == 1 && botSpots[4] == 1 && botSpots[6] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(178, 34, 34);
    text("Bot wins in " + playCount + " turns", width/2, height/2); 
    gameOver = true;
    won = true;
    botWon = true;
  }
}

void updateScore() {
  /**
   Updates the score of the game
   **/
  if (playerWon) { 
    playerScore++;
  }
  if (botWon) { 
    botScore++;
  }
}
