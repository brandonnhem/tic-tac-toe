PImage imgx, imgo; 

int w;              //Width of the grid
int h;              //Height of the grid
int bs = w / 3;           //block size
int playCount = 0;        //number of user turns
int numCols = 3;
int numRows = 3;
int[][] grid = new int [numRows][numCols];

void setup () {
  size (900, 900);            //size will only take literals, not variables
  background(255);            //make the background white
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
  //image(imgx, 0, 0, 100, 100);
  //image(imgo, 200, 200, 100, 100);
}


void mouseClicked() {
  if(mouseX < w && mouseY < h){ 
      println("user pressed at " + mouseX + ", " + mouseY);
      image(imgx, 0, 0, w, h);
  }
  else if (mouseX <= 2*w && mouseX >= w && mouseY <= h){
     println("user pressed at " + mouseX + ", " + mouseY);   
     image(imgx, w, 0, w, h);
  }
  else if (mouseX <= 3*w && mouseX >= 2*w && mouseY <= h){
     println("user pressed at " + mouseX + ", " + mouseY);   
     image(imgx, 2*w, 0, w, h);
  }
  else if (mouseX <= w && mouseY >= h && mouseY <= 2*h){
     println("user pressed at " + mouseX + ", " + mouseY);   
     image(imgx, 0, h, w, h);
  }
  else if (mouseX >= w && mouseX <= 2*w && mouseY >= h && mouseY <= 2*h){
     println("user pressed at " + mouseX + ", " + mouseY);   
     image(imgx, w, h, w, h);
  }
  else if (mouseX >= 2*w && mouseX <= 3*w && mouseY >= h && mouseY <= 2*h){
     println("user pressed at " + mouseX + ", " + mouseY);   
     image(imgx, 2*w, h, w, h);
  }
  else if (mouseX <= w && mouseY >= 2*h && mouseY <= 3*h){
     println("user pressed at " + mouseX + ", " + mouseY);   
     image(imgx, 0, 2*h, w, h);
  }
  else if (mouseX >= w && mouseX <= 2*w && mouseY >= 2*h && mouseY <= 3*h){
     println("user pressed at " + mouseX + ", " + mouseY);   
     image(imgx, w, 2*h, w, h);
  }
  else if (mouseX >= 2*w && mouseX <= 3*w && mouseY >= 2*h && mouseY <= 3*h){
     println("user pressed at " + mouseX + ", " + mouseY);   
     image(imgx, 2*w, 2*h, w, h);
  }
}
