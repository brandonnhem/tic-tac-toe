import java.util.Random;

PImage imgx, imgo; 

int w;              //Width of the grid
int h;              //Height of the grid
int bs = 300;             //block size
int playCount = 0;        //number of user turns
int numCols = 3;
int numRows = 3;
int[][] grid = new int [numRows][numCols];
int[] gridSpots = new int [9];
int[] playerSpots = new int [9];
int[] botSpots = new int [9];

void setup () {
  size (900, 900);            //size will only take literals, not variables
  background(255, 255, 255);            //make the background white
  w = width / 3;
  h = height / 3;
  //reset();
  smooth();
}

void draw () {
  //Create a grid pattern on the screen with vertical and horizontal lines
  for (int i = 0; i < width; i++) {
    line (i*bs, 0, i*bs, height);
  }
  for (int i = 0; i < height; i++) {
    line (0, i * bs, width, i * bs);
  }
  
  //for (int cols = 0; cols < numCols; cols++)
  //{
  //  for (int rows = 0; rows < numRows; rows++)
  //  {
  //    if (grid[rows][cols] == -1) {
  //      noFill();
  //      stroke(0, 0, 255);
  //      ellipse(cols * w + 10, rows * h + 10, w - 20, h - 20);
  //    } else if (grid[rows][cols] == 1) {
  //      noFill();
  //      stroke(255, 0, 0);
  //      line(cols * w + 10, rows * h + 10, (cols+1) * w - 10, (rows+1) * h - 10);
  //      line((cols+1) * w - 10, rows * h + 10, cols * w + 10, (rows+1) * h - 10);
  //    } else {
  //      stroke(0);
  //      fill(255, 255, 255);
  //      rect(cols * w, rows * h, w, h);
  //    }
  //  }
  //}
  imgx = loadImage("x.png");
  imgo = loadImage("o.png");
  if(playCount % 2 == 1){
    bot();
  }
}


void mouseClicked() {
  if(mouseX < w && mouseY < h){ 
      println("user pressed at " + mouseX + ", " + mouseY);
      image(imgx, 0, 0, w, h);
      gridSpots[0] = 1;
      playerSpots[0] = 1;
      playCount++;
  }
  else if (mouseX <= 2*w && mouseX >= w && mouseY <= h){
     println("user pressed at " + mouseX + ", " + mouseY);   
     image(imgx, w, 0, w, h);
     gridSpots[1] = 1;
     playerSpots[1] = 1;
     playCount++;
  }
  else if (mouseX <= 3*w && mouseX >= 2*w && mouseY <= h){
     println("user pressed at " + mouseX + ", " + mouseY);   
     image(imgx, 2*w, 0, w, h);
     gridSpots[2] = 1;
     playerSpots[2] = 1;
     playCount++;
  }
  else if (mouseX <= w && mouseY >= h && mouseY <= 2*h){
     println("user pressed at " + mouseX + ", " + mouseY);   
     image(imgx, 0, h, w, h);
     gridSpots[3] = 1;
     playerSpots[3] = 1;
     playCount++;
  }
  else if (mouseX >= w && mouseX <= 2*w && mouseY >= h && mouseY <= 2*h){
     println("user pressed at " + mouseX + ", " + mouseY);   
     image(imgx, w, h, w, h);
     gridSpots[4] = 1;
     playerSpots[4] = 1;
     playCount++;
  }
  else if (mouseX >= 2*w && mouseX <= 3*w && mouseY >= h && mouseY <= 2*h){
     println("user pressed at " + mouseX + ", " + mouseY);   
     image(imgx, 2*w, h, w, h);
     gridSpots[5] = 1;
     playerSpots[5] = 1;
     playCount++;
  }
  else if (mouseX <= w && mouseY >= 2*h && mouseY <= 3*h){
     println("user pressed at " + mouseX + ", " + mouseY);   
     image(imgx, 0, 2*h, w, h);
     gridSpots[6] = 1;
     playerSpots[6] = 1;
     playCount++;
  }
  else if (mouseX >= w && mouseX <= 2*w && mouseY >= 2*h && mouseY <= 3*h){
     println("user pressed at " + mouseX + ", " + mouseY);   
     image(imgx, w, 2*h, w, h);
     gridSpots[7] = 1;
     playerSpots[7] = 1;
     playCount++;
  }
  else if (mouseX >= 2*w && mouseX <= 3*w && mouseY >= 2*h && mouseY <= 3*h){
     println("user pressed at " + mouseX + ", " + mouseY);   
     image(imgx, 2*w, 2*h, w, h);
     gridSpots[8] = 1;
     playerSpots[8] = 1;
     playCount++;
  }
}

void bot(){
  Random rand = new Random();
  int n = rand.nextInt(9);
  while(gridSpots[n] == 1){
    n = rand.nextInt(8);
  }
  if(n == 0){
    image(imgo, 0, 0, w, h);
    gridSpots[n] = 1;
    botSpots[n] = 1;
  }
  else if(n == 1){
    image(imgo, w, 0, w, h);
    gridSpots[n] = 1;
    botSpots[n] = 1;
  }
  else if(n == 2){
    image(imgo, w*2, 0, w, h);
    gridSpots[n] = 1;
    botSpots[n] = 1;
  }
  else if(n == 3){
    image(imgo, 0, h, w, h);
    gridSpots[n] = 1;
    botSpots[n] = 1;
  }
  else if(n == 4){
    image(imgo, w, h, w, h);
    gridSpots[n] = 1;
    botSpots[n] = 1;
  }
  else if(n == 5){
    image(imgo, w*2, h, w, h);
    gridSpots[n] = 1;
    botSpots[n] = 1;
  }
  else if(n == 6){
    image(imgo, 0, h*2, w, h);
    gridSpots[n] = 1;
    botSpots[n] = 1;
  }
  else if(n == 7){
    image(imgo, w, h*2, w, h);
    gridSpots[n] = 1;
    botSpots[n] = 1;
  }
  else if(n == 8){
    image(imgo, w*2, h*2, w, h);
    gridSpots[n] = 1;
    botSpots[n] = 1;
  }
  playCount++;
}

void rowWin(){
  if(playerSpots[0] == 1 && playerSpots[1] == 1 && playerSpots[2] == 1){
    textAlign(CENTER);
    textSize(25);
    fill(0);
    text("Player wins", width/2, height/2);
  }
  else if(botSpots[0] == 1 && botSpots[1] == 1 && botSpots[2] == 1){
    textAlign(CENTER);
    textSize(25);
    fill(0);
    text("Bot wins", width/2, height/2); 
  }
  if(playerSpots[3] == 1 && playerSpots[4] == 1 && playerSpots[5] == 1){
    textAlign(CENTER);
    textSize(25);
    fill(0);
    text("Player wins", width/2, height/2); 
  }
  else if(botSpots[3] == 1 && botSpots[4] == 1 && botSpots[5] == 1){
    textAlign(CENTER);
    textSize(25);
    fill(0);
    text("Bot wins", width/2, height/2); 
  }
  if(playerSpots[6] == 1 && playerSpots[7] == 1 && playerSpots[8] == 1){
    textAlign(CENTER);
    textSize(25);
    fill(0);
    text("Player wins", width/2, height/2); 
  }
  else if(botSpots[6] == 1 && botSpots[7] == 1 && botSpots[8] == 1){
    textAlign(CENTER);
    textSize(25);
    fill(0);
    text("Bot wins", width/2, height/2); 
  }
}

void colWin(){
}

void diagWin(){
}
