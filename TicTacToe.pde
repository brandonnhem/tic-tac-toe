import java.util.Random;

PImage imgx, imgo; 

int w;              //Width of the grid
int h;              //Height of the grid
int choice;
int bs = 300;             //block size
int playCount = 0;        //number of user turns
int numCols = 3;
int numRows = 3;
int[][] grid = new int [numRows][numCols];
int[] gridSpots = new int [9];
int[] playerSpots = new int [9];
int[] botSpots = new int [9];
boolean gameOver = false;
boolean won = false;

void setup () {
  size (900, 900);            //size will only take literals, not variable
  w = width / 3;
  h = height / 3;
  Random rand = new Random();
  choice = rand.nextInt(2);
  if (choice == 1) {
    imgx = loadImage("x.png");
    imgo = loadImage("o.png");
  } else {
    imgo = loadImage("x.png");
    imgx = loadImage("o.png");
  }
  //reset();
  smooth();
}

void draw () {
  background(255, 255, 255);
  //Create a grid pattern on the screen with vertical and horizontal lines
  for (int i = 0; i < width; i++) {
    line (i*bs, 0, i*bs, height);
  }
  for (int i = 0; i < height; i++) {
    line (0, i * bs, width, i * bs);
  }
  //Checks for win scenarios each iteration
  printPlayer();
  printBot();
  rowWin();
  colWin();
  diagWin();
  isTie();
  if (gameOver) {
    fill (0);
    textSize(30);
    textAlign(CENTER);
    text("Press space bar to restart.", (width/2)+30, (height/2)+30);
    if (keyPressed && key == ' ') {
      playCount = 0;        //number of user turns
      grid = new int [numRows][numCols];
      gridSpots = new int [9];
      playerSpots = new int [9];
      botSpots = new int [9];
      gameOver = false;
      Random rand = new Random();
      choice = rand.nextInt(2);
      if (choice == 1) {
        imgx = loadImage("x.png");
        imgo = loadImage("o.png");
      } else {
        imgo = loadImage("x.png");
        imgx = loadImage("o.png");
      }
    }
  } else if (playCount % 2 == 1) {
    bot();
  }
}

void mouseClicked() {
  if (mouseX < w && mouseY < h) { 
    println("user pressed at " + mouseX + ", " + mouseY);
    if (gridSpots[0] != 1) {
      gridSpots[0] = 1;
      playerSpots[0] = 1;
      playCount++;
    }
  } else if (mouseX <= 2*w && mouseX >= w && mouseY <= h) {
    println("user pressed at " + mouseX + ", " + mouseY);   
    if (gridSpots[1] != 1) {
      gridSpots[1] = 1;
      playerSpots[1] = 1;
      playCount++;
    }
  } else if (mouseX <= 3*w && mouseX >= 2*w && mouseY <= h) {
    println("user pressed at " + mouseX + ", " + mouseY);   
    if (gridSpots[2] != 1) {
      gridSpots[2] = 1;
      playerSpots[2] = 1;
      playCount++;
    }
  } else if (mouseX <= w && mouseY >= h && mouseY <= 2*h) {
    println("user pressed at " + mouseX + ", " + mouseY);   
    if (gridSpots[3] != 1) {
      gridSpots[3] = 1;
      playerSpots[3] = 1;
      playCount++;
    }
  } else if (mouseX >= w && mouseX <= 2*w && mouseY >= h && mouseY <= 2*h) {
    println("user pressed at " + mouseX + ", " + mouseY);   
    if (gridSpots[4] != 1) {
      gridSpots[4] = 1;
      playerSpots[4] = 1;
      playCount++;
    }
  } else if (mouseX >= 2*w && mouseX <= 3*w && mouseY >= h && mouseY <= 2*h) {
    println("user pressed at " + mouseX + ", " + mouseY);   
    if (gridSpots[5] != 1) {
      gridSpots[5] = 1;
      playerSpots[5] = 1;
      playCount++;
    }
  } else if (mouseX <= w && mouseY >= 2*h && mouseY <= 3*h) {
    println("user pressed at " + mouseX + ", " + mouseY);   
    if (gridSpots[6] != 1) {
      gridSpots[6] = 1;
      playerSpots[6] = 1;
      playCount++;
    }
  } else if (mouseX >= w && mouseX <= 2*w && mouseY >= 2*h && mouseY <= 3*h) {
    println("user pressed at " + mouseX + ", " + mouseY);   
    if (gridSpots[7] != 1) {
      gridSpots[7] = 1;
      playerSpots[7] = 1;
      playCount++;
    }
  } else if (mouseX >= 2*w && mouseX <= 3*w && mouseY >= 2*h && mouseY <= 3*h) {
    println("user pressed at " + mouseX + ", " + mouseY);   
    if (gridSpots[8] != 1) {
      gridSpots[8] = 1;
      playerSpots[8] = 1;
      playCount++;
    }
  }
}

void printPlayer() {
  for (int i=0; i<playerSpots.length; i++) {
    int row = i % 3;
    int col = i / 3;
    if (playerSpots[i] == 1) {
      image(imgx, w*row, h*col, w, h);
    }
  }
}

void printBot() {
  for (int i=0; i<botSpots.length; i++) {
    int row = i % 3;
    int col = i / 3;
    if (botSpots[i] == 1) {
      image(imgo, w*row, h*col, w, h);
    }
  }
}

void bot() {
  Random rand = new Random();
  int n = rand.nextInt(9);
  while (gridSpots[n] == 1) {
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
  playCount++;
}

void isTie() {
  if (playCount >= 9 && !won) {
    textAlign(CENTER);
    textSize(60);
    fill(0);
    text("It's a tie!", width/2, height/2);
    gameOver = true;
  }
}

void rowWin() {
  if (playerSpots[0] == 1 && playerSpots[1] == 1 && playerSpots[2] == 1) {
    textAlign(CENTER);
    textSize(25);
    fill(0);
    text("Player wins", width/2, height/2);
    gameOver = true;
  } else if (playerSpots[3] == 1 && playerSpots[4] == 1 && playerSpots[5] == 1) {
    textAlign(CENTER);
    textSize(25);
    fill(0);
    text("Player wins", width/2, height/2); 
    gameOver = true;
  } else if (playerSpots[6] == 1 && playerSpots[7] == 1 && playerSpots[8] == 1) {
    textAlign(CENTER);
    textSize(25);
    fill(0);
    text("Player wins", width/2, height/2);
    gameOver = true;
  } else if (botSpots[0] == 1 && botSpots[1] == 1 && botSpots[2] == 1) {
    textAlign(CENTER);
    textSize(25);
    fill(0);
    text("Bot wins", width/2, height/2);
    gameOver = true;
  } else if (botSpots[3] == 1 && botSpots[4] == 1 && botSpots[5] == 1) {
    textAlign(CENTER);
    textSize(25);
    fill(0);
    text("Bot wins", width/2, height/2); 
    gameOver = true;
  } else if (botSpots[6] == 1 && botSpots[7] == 1 && botSpots[8] == 1) {
    textAlign(CENTER);
    textSize(25);
    fill(0);
    text("Bot wins", width/2, height/2);
    gameOver = true;
  }
}

void colWin() {
  if (playerSpots[0] == 1 && playerSpots[3] == 1 && playerSpots[6] == 1) {
    textAlign(CENTER);
    textSize(25);
    fill(0);
    text("Player wins", width/2, height/2);
    gameOver = true;
  } else if (playerSpots[1] == 1 && playerSpots[4] == 1 && playerSpots[7] == 1) {
    textAlign(CENTER);
    textSize(25);
    fill(0);
    text("Player wins", width/2, height/2);
    gameOver = true;
  } else if (playerSpots[2] == 1 && playerSpots[5] == 1 && playerSpots[8] == 1) {
    textAlign(CENTER);
    textSize(25);
    fill(0);
    text("Player wins", width/2, height/2); 
    gameOver = true;
  } else if (botSpots[0] == 1 && botSpots[3] == 1 && botSpots[6] == 1) {
    textAlign(CENTER);
    textSize(25);
    fill(0);
    text("Bot wins", width/2, height/2);   
    gameOver = true;
  } else if (botSpots[1] == 1 && botSpots[4] == 1 && botSpots[7] == 1) {
    textAlign(CENTER);
    textSize(25);
    fill(0);
    text("Bot wins", width/2, height/2);  
    gameOver = true;
  } else if (botSpots[2] == 1 && botSpots[5] == 1 && botSpots[8] == 1) {
    textAlign(CENTER);
    textSize(25);
    fill(0);
    text("Bot wins", width/2, height/2);
    gameOver = true;
  }
}

void diagWin() {
  if (playerSpots[0] == 1 && playerSpots[4] == 1 && playerSpots[8] == 1) {
    textAlign(CENTER);
    textSize(25);
    fill(0);
    text("Player wins", width/2, height/2);
    gameOver = true;
  } else if (playerSpots[2] == 1 && playerSpots[4] == 1 && playerSpots[6] == 1) {
    textAlign(CENTER);
    textSize(25);
    fill(0);
    text("Player wins", width/2, height/2);  
    gameOver = true;
  } else if (botSpots[0] == 1 && botSpots[4] == 1 && botSpots[8] == 1) {
    textAlign(CENTER);
    textSize(25);
    fill(0);
    text("Bot wins", width/2, height/2); 
    gameOver = true;
  } else if (botSpots[2] == 1 && botSpots[4] == 1 && botSpots[6] == 1) {
    textAlign(CENTER);
    textSize(25);
    fill(0);
    text("Bot wins", width/2, height/2); 
    gameOver = true;
  }
}
