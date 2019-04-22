import java.util.Random; // Used to have the bot pick a spot and who goes first

PImage imgx, imgo; // used to import images into the game

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
boolean gameOver = false;
boolean won = false;
int playerScore = 0; // score of the player
int botScore = 0;    // score of the bot
boolean firstClick = false; // used to clear the text of the score, once turned true, the text disappears
boolean playerWon = false; 
boolean botWon = false;
boolean alreadyCalled = false; // used in draw(), ensures the updateScore() method is only called once
boolean playerIsX = false; // tell the player what they are before the game starts, false is default indicating O, true is X

void setup () { //<>//
  /**
      This setups the game, specifically the window size, who goes first, and the image that is preloaded for the symbols.
      Alternatively, you can change the symbols if you want if change it in the root folder - just make sure that it's named
      "x.png" or "o.png".
  **/
  size (900, 900);            //size will only take literals, not variable
  w = width / 3;
  h = height / 3;
  Random rand = new Random();
  choice = rand.nextInt(2); 
  if (choice == 1) {
    imgx = loadImage("x.png"); // loads the image for x 
    imgo = loadImage("o.png"); // loads the image for o
    playerIsX = true;
  } else {
    imgo = loadImage("x.png"); // loads the image for o
    imgx = loadImage("o.png"); // loads the image for x
    playerIsX = false;
  }
  smooth(); // smooths out the lines
}


void draw () { //<>//
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
  if(!firstClick) { // displays the score of the player and the bot before the game starts, once the player clicks, the text disappears
    fill(0);
    textSize(30);
    textAlign(CENTER);
    text("Player Score: " + playerScore, (width/2), (height/2)+ 50);
    text("Bot Score: " + botScore, (width/2), (height/2)); 
    if(playerIsX) {
      text("You play as X", (width/2), (height/2) + 100);
    } 
    if(!playerIsX) {
      text("You play as O", (width/2), (height/2) + 100);
    }
  }
  printPlayer(); // constantly prints out where the player's symbols are
  printBot();    // constantly prints out where the bot's symbols are
  //Checks for win scenarios each iteration
  rowWin();
  colWin();
  diagWin();
  //If not won, check if tie
  if(playCount >= 9) isTie();
  if (gameOver) {
    if(!alreadyCalled) { // this ensures that updateScore() is only called once
      updateScore();
      alreadyCalled = true; // now it won't be called
    }
    fill (0);
    textSize(30);
    textAlign(CENTER);
    text("Press space bar to restart.", (width/2)+30, (height/2)+30);
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
      Random rand = new Random();
      choice = rand.nextInt(2);
      if (choice == 1) {
        imgx = loadImage("x.png");
        imgo = loadImage("o.png");
        playerIsX = true;
      } else {
        imgo = loadImage("x.png");
        imgx = loadImage("o.png");
        playerIsX = false;
      }
    }
  } else if (playCount % 2 == 1) {
    bot();
  }
  if(!gameOver){
    takenSpot();
    detectPossibleWin();
    detectPossibleFork();
  }
}

void mouseClicked() {
  /**
      This monitors where the player has clicked, when the user clicks in a valid spot, it updates the array
      that stores the player's taken spots. Also then increases the play count.
  **/
  firstClick = true;
  if (mouseX < w && mouseY < h) { 
    //println("user pressed at " + mouseX + ", " + mouseY);
    if (gridSpots[0] != 1) {
      gridSpots[0] = 1;
      playerSpots[0] = 1;
      playCount++;
    }
  } else if (mouseX <= 2*w && mouseX >= w && mouseY <= h) {
    //println("user pressed at " + mouseX + ", " + mouseY);   
    if (gridSpots[1] != 1) {
      gridSpots[1] = 1;
      playerSpots[1] = 1;
      playCount++;
    }
  } else if (mouseX <= 3*w && mouseX >= 2*w && mouseY <= h) {
    //println("user pressed at " + mouseX + ", " + mouseY);   
    if (gridSpots[2] != 1) {
      gridSpots[2] = 1;
      playerSpots[2] = 1;
      playCount++;
    }
  } else if (mouseX <= w && mouseY >= h && mouseY <= 2*h) {
    //println("user pressed at " + mouseX + ", " + mouseY);   
    if (gridSpots[3] != 1) {
      gridSpots[3] = 1;
      playerSpots[3] = 1;
      playCount++;
    }
  } else if (mouseX >= w && mouseX <= 2*w && mouseY >= h && mouseY <= 2*h) {
    //println("user pressed at " + mouseX + ", " + mouseY);   
    if (gridSpots[4] != 1) {
      gridSpots[4] = 1;
      playerSpots[4] = 1;
      playCount++;
    }
  } else if (mouseX >= 2*w && mouseX <= 3*w && mouseY >= h && mouseY <= 2*h) {
    //println("user pressed at " + mouseX + ", " + mouseY);   
    if (gridSpots[5] != 1) {
      gridSpots[5] = 1;
      playerSpots[5] = 1;
      playCount++;
    }
  } else if (mouseX <= w && mouseY >= 2*h && mouseY <= 3*h) {
    //println("user pressed at " + mouseX + ", " + mouseY);   
    if (gridSpots[6] != 1) {
      gridSpots[6] = 1;
      playerSpots[6] = 1;
      playCount++;
    }
  } else if (mouseX >= w && mouseX <= 2*w && mouseY >= 2*h && mouseY <= 3*h) {
    //println("user pressed at " + mouseX + ", " + mouseY);   
    if (gridSpots[7] != 1) {
      gridSpots[7] = 1;
      playerSpots[7] = 1;
      playCount++;
    }
  } else if (mouseX >= 2*w && mouseX <= 3*w && mouseY >= 2*h && mouseY <= 3*h) {
    //println("user pressed at " + mouseX + ", " + mouseY);   
    if (gridSpots[8] != 1) {
      gridSpots[8] = 1;
      playerSpots[8] = 1;
      playCount++;
    }
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
      Detects if there a possible fork that the player can create.
      A "fork" is a move that creates two winning moves.
      To understand all this jumbled up code, it basically every POSSIBLE fork.
      Forks can only be really made in the corners of the grid or with the middle spot.
  **/
  if ((mouseX < w && mouseY < h) && (gridSpots[0] == 0) && ((playerSpots[2] == 1 && playerSpots[4] == 1) || (playerSpots[6] == 1 && playerSpots[4] == 1) || (playerSpots[2] == 1 && playerSpots[6] == 1) || (playerSpots[1] == 1 && playerSpots[4] == 1) || (playerSpots[3] == 1 && playerSpots[4] == 1))) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Make a fork here.", (w/2), (h/2) + 50);
  } else if ((mouseX >= 2*w && mouseX <= 3*w && mouseY >= 2*h && mouseY <= 3*h) && (gridSpots[8] == 0) && ((playerSpots[2] == 1 && playerSpots[4] == 1) || (playerSpots[6] == 1 && playerSpots[4] == 1) || (playerSpots[2] == 1 && playerSpots[6] == 1) || (playerSpots[4] == 1 && playerSpots[5] == 1) || (playerSpots[4] == 1 && playerSpots[7] == 1))) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Make a fork here.", (w*2.5), (h*2.5) + 50);
 } else if ((mouseX <= 3*w && mouseX >= 2*w && mouseY <= h) && (gridSpots[2] == 0) && ((playerSpots[0] == 1 && playerSpots[4] == 1) || (playerSpots[8] == 1 && playerSpots[4] == 1) || (playerSpots[0] == 1 && playerSpots[8] == 1) || (playerSpots[4] == 1 && playerSpots[5] == 1) || (playerSpots[1] == 1 && playerSpots[4] == 1))) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Make a fork here.", (w*2.5), (h/2) + 50);
 } else if ((mouseX <= w && mouseY >= 2*h && mouseY <= 3*h) && (gridSpots[6] == 0) && ((playerSpots[0] == 1 && playerSpots[4] == 1) || (playerSpots[4] == 1 && playerSpots[8] == 1) || (playerSpots[0] == 1 && playerSpots[8] == 1) || (playerSpots[3] == 1 && playerSpots[4] == 1) || (playerSpots[4] == 1 && playerSpots[8] == 1))) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Make a fork here.", (w/2), (h*2.5) + 50);
 } else if ((mouseX >= w && mouseX <= 2*w && mouseY >= h && mouseY <= 2*h) && (gridSpots[4] == 0) && ((playerSpots[0] == 1 && playerSpots[2] == 1) || (playerSpots[0] == 1 && playerSpots[6] == 1) || (playerSpots[6] == 1 && playerSpots[8] == 1) || (playerSpots[2] == 1 && playerSpots[8] == 1))) {
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Make a fork here.", (w*1.5), (h*1.5) + 50);
 }
}

void detectPossibleWin() {
  /**
      Detects if there is a possible spot the player can win in. All types of wins supported.
  **/
  // ROWS (RIGHT | MIDDLE | LEFT)
  if ((mouseX <= 3*w && mouseX >= 2*w && mouseY <= h) && (gridSpots[2] == 0)) {
    if(playerSpots[0] == 1 && playerSpots[1] == 1 && gridSpots[2] == 0){
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Pick this spot to win!", (w*2.5), (h/2));
    }
  } else if ((mouseX >= 2*w && mouseX <= 3*w && mouseY >= h && mouseY <= 2*h) && (gridSpots[5] == 0)) {
    if(playerSpots[3] == 1 && playerSpots[4] == 1 && gridSpots[5] == 0){
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Pick this spot to win!", (w*2.5), (h*1.5));
    }
  } else if ((mouseX >= 2*w && mouseX <= 3*w && mouseY >= 2*h && mouseY <= 3*h) && (gridSpots[8] == 0)) {
    if(playerSpots[6] == 1 && playerSpots[7] == 1 && gridSpots[8] == 0){
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Pick this spot to win!", (w*2.5), (h*2.5));
    }
  } else if ((mouseX <= 2*w && mouseX >= w && mouseY <= h) && (gridSpots[1] == 0)) {
    if(playerSpots[0] == 1 && playerSpots[2] == 1 && gridSpots[1] == 0){
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Pick this spot to win!", (w*1.5), (h/2));
    }
  } else if ((mouseX >= w && mouseX <= 2*w && mouseY >= h && mouseY <= 2*h) && (gridSpots[4] == 0)) {
    if(playerSpots[3] == 1 && playerSpots[5] == 1 && gridSpots[4] == 0){
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Pick this spot to win!", (w*1.5), (h*1.5));
    }
  } else if ((mouseX >= w && mouseX <= 2*w && mouseY >= 2*h && mouseY <= 3*h) && (gridSpots[7] == 0)) {
    if(playerSpots[6] == 1 && playerSpots[8] == 1 && gridSpots[7] == 0){
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Pick this spot to win!", (w*1.5), (h*2.5));
    }
  } else if ((mouseX < w && mouseY < h) && (gridSpots[0] == 0)) { 
    if(playerSpots[2] == 1 && playerSpots[1] == 1 && gridSpots[0] == 0){
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Pick this spot to win!", (w/2), (h/2));
    }
  } else if ((mouseX <= w && mouseY >= h && mouseY <= 2*h) && (gridSpots[3] == 0)) {
    if(playerSpots[5] == 1 && playerSpots[4] == 1 && gridSpots[3] == 0){
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Pick this spot to win!", (w/2), (h*1.5));
    }
  } else if ((mouseX <= w && mouseY >= 2*h && mouseY <= 3*h) && (gridSpots[6] == 0)) {
    if(playerSpots[8] == 1 && playerSpots[7] == 1 && gridSpots[6] == 0){
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Pick this spot to win!", (w/2), (h*2.5));
    }
  }
  
  // COLUMNS (BOTTOM | MIDDLE | TOP)
  if ((mouseX <= w && mouseY >= 2*h && mouseY <= 3*h) && (gridSpots[6] == 0)) {
    if(playerSpots[0] == 1 && playerSpots[3] == 1 && gridSpots[6] == 0){
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Pick this spot to win!", (w/2), (h*2.5));
    }
  } else if ((mouseX >= w && mouseX <= 2*w && mouseY >= 2*h && mouseY <= 3*h) && (gridSpots[7] == 0)) {
    if(playerSpots[1] == 1 && playerSpots[4] == 1 && gridSpots[7] == 0){
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Pick this spot to win!", (w*1.5), (h*2.5));
    }
  } else if ((mouseX >= 2*w && mouseX <= 3*w && mouseY >= 2*h && mouseY <= 3*h) && (gridSpots[8] == 0)) {
    if(playerSpots[2] == 1 && playerSpots[5] == 1 && gridSpots[8] == 0){
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Pick this spot to win!", (w*2.5), (h*2.5));
    }
  } else if ((mouseX <= w && mouseY >= h && mouseY <= 2*h) && (gridSpots[3] == 0)) {
    if(playerSpots[0] == 1 && playerSpots[6] == 1 && gridSpots[3] == 0){
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Pick this spot to win!", (w/2), (h*1.5));
    }
  } else if ((mouseX >= w && mouseX <= 2*w && mouseY >= h && mouseY <= 2*h) && (gridSpots[4] == 0)) {
    if(playerSpots[1] == 1 && playerSpots[7] == 1 && gridSpots[4] == 0){
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Pick this spot to win!", (w*1.5), (h*1.5));
    }
  } else if ((mouseX >= 2*w && mouseX <= 3*w && mouseY >= h && mouseY <= 2*h) && (gridSpots[5] == 0)) {
    if(playerSpots[2] == 1 && playerSpots[8] == 1 && gridSpots[5] == 0){
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Pick this spot to win!", (w*2.5), (h*1.5));
    }
  } else if ((mouseX < w && mouseY < h) && (gridSpots[0] == 0)) { 
    if(playerSpots[6] == 1 && playerSpots[3] == 1 && gridSpots[0] == 0){
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Pick this spot to win!", (w/2), (h/2));
    }
  } else if ((mouseX <= 2*w && mouseX >= w && mouseY <= h) && (gridSpots[1] == 0)) {
    if(playerSpots[7] == 1 && playerSpots[4] == 1 && gridSpots[1] == 0){
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Pick this spot to win!", (w*1.5), (h/2));
    }
  } else if ((mouseX <= 3*w && mouseX >= 2*w && mouseY <= h) && (gridSpots[2] == 0)) {
    if(playerSpots[8] == 1 && playerSpots[5] == 1 && gridSpots[2] == 0){
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Pick this spot to win!", (w*2.5), (h/2));
    }
  }
  
  // DIAG (BOTTOM || MIDDLE || TOP)
  if ((mouseX >= 2*w && mouseX <= 3*w && mouseY >= 2*h && mouseY <= 3*h) && (gridSpots[8] == 0)) {
    if(playerSpots[0] == 1 && playerSpots[4] == 1 && gridSpots[8] == 0){
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Pick this spot to win!", (w*2.5), (h*2.5));
    }
  } else if ((mouseX >= w && mouseX <= 2*w && mouseY >= h && mouseY <= 2*h) && (gridSpots[4] == 0)) {
    if(playerSpots[0] == 1 && playerSpots[8] == 1 && gridSpots[4] == 0){
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Pick this spot to win!", (w*1.5), (h*1.5));
    }
  } else if ((mouseX < w && mouseY < h) && (gridSpots[0] == 0)) { 
    if(playerSpots[4] == 1 && playerSpots[8] == 1 && gridSpots[0] == 0){
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Pick this spot to win!", (w/2), (h/2));
    }
  } else if ((mouseX <= w && mouseY >= 2*h && mouseY <= 3*h) && (gridSpots[6] == 0)) {
    if(playerSpots[2] == 1 && playerSpots[4] == 1 && gridSpots[6] == 0){
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Pick this spot to win!", (w/2), (h*2.5));
    }
  } else if ((mouseX >= w && mouseX <= 2*w && mouseY >= h && mouseY <= 2*h) && (gridSpots[4] == 0)) {
    if(playerSpots[2] == 1 && playerSpots[6] == 1 && gridSpots[4] == 0){
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Pick this spot to win!", (w*1.5), (h*1.5));
    }
  } else if ((mouseX <= 3*w && mouseX >= 2*w && mouseY <= h) && (gridSpots[2] == 0)) {
    if(playerSpots[6] == 1 && playerSpots[4] == 1 && gridSpots[2] == 0){
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Pick this spot to win!", (w*2.5), (h/2));
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
  if (((playerSpots[1] == 1 && playerSpots[2] == 1)||(playerSpots[3] == 1 && playerSpots[6] == 1)||(playerSpots[4] == 1 && playerSpots[8] == 1)) && gridSpots[0] != 1) { //Top Left Corner
    gridSpots[0] = 1;
    botSpots[0] = 1;
  } else if (((playerSpots[0] == 1 && playerSpots[2] == 1)||(playerSpots[4] == 1 && playerSpots[7] == 1)) && gridSpots[1] != 1) { //Top Middle
    gridSpots[1] = 1;
    botSpots[1] = 1;
  } else if (((playerSpots[0] == 1 && playerSpots[1] == 1)||(playerSpots[6] == 1 && playerSpots[4] == 1)||(playerSpots[5] == 1 && playerSpots[8] == 1)) && gridSpots[2] != 1) { //Tope Right Corner
    gridSpots[2] = 1;
    botSpots[2] = 1;
  } else if (((playerSpots[0] == 1 && playerSpots[6] == 1)||(playerSpots[4] == 1 && playerSpots[5] == 1)) && gridSpots[3] != 1) { //Middle Left
    gridSpots[3] = 1;
    botSpots[3] = 1;
  } else if (((playerSpots[0] == 1 && playerSpots[8] == 1)||(playerSpots[2] == 1 && playerSpots[6] == 1)||(playerSpots[3] == 1 && playerSpots[5] == 1)||(playerSpots[1] == 1 && playerSpots[7] == 1)) && gridSpots[4] != 1) { //Middle Middle
    gridSpots[4] = 1;
    botSpots[4] = 1;
  } else if (((playerSpots[3] == 1 && playerSpots[4] == 1)||(playerSpots[2] == 1 && playerSpots[8] == 1)) && gridSpots[5] != 1) { //Middle Right
    gridSpots[5] = 1;
    botSpots[5] = 1;
  } else if (((playerSpots[0] == 1 && playerSpots[3] == 1)||(playerSpots[2] == 1 && playerSpots[4] == 1)||(playerSpots[7] == 1 && playerSpots[8] == 1)) && gridSpots[6] != 1) { //Bottom Left
    gridSpots[6] = 1;
    botSpots[6] = 1;
  } else if (((playerSpots[1] == 1 && playerSpots[4] == 1)||(playerSpots[6] == 1 && playerSpots[8] == 1)) && gridSpots[7] != 1) { //Bottom Middle
    gridSpots[7] = 1;
    botSpots[7] = 1;
  } else if (((playerSpots[2] == 1 && playerSpots[5] == 1)||(playerSpots[0] == 1 && playerSpots[4] == 1)||(playerSpots[6] == 1 && playerSpots[7] == 1)) && gridSpots[8] != 1) { //Bottom Right
    gridSpots[8] = 1;
    botSpots[8] = 1;
  } else {
    if (n == 0) {
      gridSpots[n] = 1;
      botSpots[n] = 1;
    } else if (n == 1) {
      gridSpots[n] = 1;
      botSpots[n] = 1;
    } else if (n == 2) {
      gridSpots[n] = 1;
      botSpots[n] = 1;
    } else if (n == 3) {
      gridSpots[n] = 1;
      botSpots[n] = 1;
    } else if (n == 4) {
      gridSpots[n] = 1;
      botSpots[n] = 1;
    } else if (n == 5) {
      gridSpots[n] = 1;
      botSpots[n] = 1;
    } else if (n == 6) {
      gridSpots[n] = 1;
      botSpots[n] = 1;
    } else if (n == 7) {
      gridSpots[n] = 1;
      botSpots[n] = 1;
    } else if (n == 8) {
      gridSpots[n] = 1;
      botSpots[n] = 1;
    }
  }
  playCount++; // increase how many plays have gone by
}

void isTie() {
  /**
      Determines if the game has resulted in a tie
  **/
  if (!won) {
    textAlign(CENTER);
    textSize(60);
    fill(0);
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
    fill(0);
    text("Player wins", width/2, height/2);
    gameOver = true;
    won = true;
    playerWon = true;
  } else if (playerSpots[3] == 1 && playerSpots[4] == 1 && playerSpots[5] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(0);
    text("Player wins", width/2, height/2); 
    gameOver = true;
    won = true;
    playerWon = true;
  } else if (playerSpots[6] == 1 && playerSpots[7] == 1 && playerSpots[8] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(0);
    text("Player wins", width/2, height/2);
    gameOver = true;
    won = true;
    playerWon = true;
  } else if (botSpots[0] == 1 && botSpots[1] == 1 && botSpots[2] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(0);
    text("Bot wins", width/2, height/2);
    gameOver = true;
    won = true;
    botWon = true;
  } else if (botSpots[3] == 1 && botSpots[4] == 1 && botSpots[5] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(0);
    text("Bot wins", width/2, height/2); 
    gameOver = true;
    won = true;
    botWon = true;
  } else if (botSpots[6] == 1 && botSpots[7] == 1 && botSpots[8] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(0);
    text("Bot wins", width/2, height/2);
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
    fill(0);
    text("Player wins", width/2, height/2);
    gameOver = true;
    won = true;
    playerWon = true;
  } else if (playerSpots[1] == 1 && playerSpots[4] == 1 && playerSpots[7] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(0);
    text("Player wins", width/2, height/2);
    gameOver = true;
    won = true;
    playerWon = true;
  } else if (playerSpots[2] == 1 && playerSpots[5] == 1 && playerSpots[8] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(0);
    text("Player wins", width/2, height/2); 
    gameOver = true;
    won = true;
    playerWon = true;
  } else if (botSpots[0] == 1 && botSpots[3] == 1 && botSpots[6] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(0);
    text("Bot wins", width/2, height/2);   
    gameOver = true;
    won = true;
    botWon = true;
  } else if (botSpots[1] == 1 && botSpots[4] == 1 && botSpots[7] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(0);
    text("Bot wins", width/2, height/2);  
    gameOver = true;
    won = true;
    botWon = true;
  } else if (botSpots[2] == 1 && botSpots[5] == 1 && botSpots[8] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(0);
    text("Bot wins", width/2, height/2);
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
    fill(0);
    text("Player wins", width/2, height/2);
    gameOver = true;
    won = true;
    playerWon = true;
  } else if (playerSpots[2] == 1 && playerSpots[4] == 1 && playerSpots[6] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(0);
    text("Player wins", width/2, height/2);  
    gameOver = true;
    won = true;
    playerWon = true;
  } else if (botSpots[0] == 1 && botSpots[4] == 1 && botSpots[8] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(0);
    text("Bot wins", width/2, height/2); 
    gameOver = true;
    won = true;
    botWon = true;
  } else if (botSpots[2] == 1 && botSpots[4] == 1 && botSpots[6] == 1) {
    textAlign(CENTER);
    textSize(60);
    fill(0);
    text("Bot wins", width/2, height/2); 
    gameOver = true;
    won = true;
    botWon = true;
  }
}

void updateScore() {
  /**
      Updates the score of the game
  **/
  if(playerWon) { playerScore++; }
  if(botWon) { botScore++; }
}
