PImage imgx, imgo; 

int w;              //Width of the grid
int h;              //Height of the grid
int bs = 300;             //block size
int playCount = 0;        //number of user turns
int numCols = 3;
int numRows = 3;
int[][] grid = new int [numRows][numCols];

void setup () {
  size (900, 900);            //size will only take literals, not variables
  background(255, 255, 255);            //make the background white
  w = width / 3;
  h = height / 3;
  ellipseMode(CORNER);
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

//The coordinates of the 9 positions are 
// (0  , 0), (0  , 100), (0  , 200)
// (100, 0), (100, 100), (100, 200)
// (200, 0), (200, 100), (200, 200)

//void mouseClicked(){
// if(mouseX < 100 & mouseY < 100){
//   image(imgx, 0, 0, 100, 100);
// }
// else if (mouseX < 100 & mouseY > 100 & mouseY < 200){
//   image(imgx, 0, 100, 100, 100);
// }
// else if (mouseX < 100 & mouseY > 200){
//   image(imgx, 0, 200, 100, 100);
// }
// else if (mouseX > 100 & mouseX < 200 & mouseY < 100){
//   image(imgx, 100, 0, 100, 100);
// }
// else if (mouseX > 100 & mouseX < 200 & mouseY > 100 & mouseY < 200){
//   image(imgx, 100, 100, 100, 100);
// }
// else if (mouseX > 100 & mouseX < 200 & mouseY > 200){
//   image(imgx, 100, 200, 100, 100);
// }
// else if (mouseX > 200 & mouseY < 100){
//   image(imgx, 200, 0, 100, 100);
// }
//  else if (mouseX > 200 & mouseY > 100 & mouseY < 200){
//   image(imgx, 200, 100, 100, 100);
// }
// else if (mouseX > 200 & mouseY > 200){
//   image(imgx, 200, 200, 100, 100);
// }
//}

void mouseClicked() {
  if(mouseX < w && mouseY < h){ 
      println("user pressed at " + mouseX + ", " + mouseY);
      image(imgx, 0, 0, w, h);
  }
  else if (mouseX <= 600 && mouseX >= 300 && mouseY <= 300){
     println("user pressed at " + mouseX + ", " + mouseY);   
     image(imgx, 300, 0, w, h);
  }
  else if (mouseX <= 900 && mouseX >= 600 && mouseY <= 300){
     println("user pressed at " + mouseX + ", " + mouseY);   
     image(imgx, 600, 0, w, h);
  }
  else if (mouseX <= 300 && mouseY >= 300 && mouseY <= 600){
     println("user pressed at " + mouseX + ", " + mouseY);   
     image(imgx, 0, 300, w, h);
  }
  else if (mouseX >= 300 && mouseX <= 600 && mouseY >= 300 && mouseY <= 600){
     println("user pressed at " + mouseX + ", " + mouseY);   
     image(imgx, 300, 300, w, h);
  }
  else if (mouseX >= 600 && mouseX <= 900 && mouseY >= 300 && mouseY <= 600){
     println("user pressed at " + mouseX + ", " + mouseY);   
     image(imgx, 600, 300, w, h);
  }
  else if (mouseX <= 300 && mouseY >= 600 && mouseY <= 900){
     println("user pressed at " + mouseX + ", " + mouseY);   
     image(imgx, 0, 600, w, h);
  }
  else if (mouseX >= 300 && mouseX <= 600 && mouseY >= 600 && mouseY <= 900){
     println("user pressed at " + mouseX + ", " + mouseY);   
     image(imgx, 300, 600, w, h);
  }
  else if (mouseX >= 600 && mouseX <= 900 && mouseY >= 600 && mouseY <= 900){
     println("user pressed at " + mouseX + ", " + mouseY);   
     image(imgx, 600, 600, w, h);
  }
  //else if(mouseX < w + 300 && mouseY < h + 300){
  //      image(imgx, 300, 300, w, h);
  //}
  //else if(mouseX < w + 600 && mouseY < h + 600){
  //      image(imgx, 600, 600, w, h);
  //}
}
