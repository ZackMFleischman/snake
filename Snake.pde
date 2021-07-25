
// Params
int worldDimension = 30;
int blockSize = 16;
color snakeColor = color(0, 150, 0);

PFont font;
PFont font2;
int fontSize = 24;
int fontSize2 = 18;



class SnakeCell {
  int x;
  int y;
  
  SnakeCell next;
  SnakeCell prev;
  
  SnakeCell(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
}

// Game State
int velocityX;
int velocityY;

int startingX;
int startingY;

int appleX;
int appleY;
int applesEaten;
boolean gameover = false;

SnakeCell head;
SnakeCell body;
SnakeCell tail;


float gameStepTime = 150;
float appleSpeedBoost = 5;
float currentStepTime = 0;
float lastStepTime = 0;

void setup() {
  size(510, 510);
  
  font = createFont("Arial", fontSize ,true);
  font2 = createFont("Arial", fontSize2 ,true);
   
  reset();
}

void draw() {
  if (gameover) {
    renderGameover();   
    return;
  }
  
  background(255);
  
  checkForInput();
  
  tryGameStep();
  render();
}

void renderGameover() {
  fill(color(200, 0 ,0));
    
    textFont(font, fontSize);
    text("Game Over!", (worldDimension*blockSize)/2 - 50,(worldDimension*blockSize)/2);
    text("Apples Eaten: " + applesEaten, (worldDimension*blockSize)/2 - 70,(worldDimension*blockSize)/2 + 40);
    
    textFont(font2, fontSize2);
    text("(Hit space to play again)", (worldDimension*blockSize)/2 - 85,(worldDimension*blockSize)/2 + 70);
    
    if (key == ' ') {
      reset();
    }
}

void reset() {
  gameover = false;
  velocityX = 1;
  velocityY = 0;

  startingX = floor(random(4, worldDimension-4));
  startingY = floor(random(4, worldDimension-4));

  head = new SnakeCell(startingX, startingY);
  body = new SnakeCell(startingX-1, startingY);
  tail  = new SnakeCell(startingX-2, startingY);
  
  head.next = body;
  body.next = tail;
  body.prev = head;
  tail.prev = body;
 
  applesEaten = 0;
  
  spawnApple();
}

void checkForInput() {
  if (!keyPressed) return;
  
  if ((key == 'a' || keyCode == LEFT) && !(head.next.x == head.x-1 && head.next.y == head.y)) {
    velocityX = -1;
    velocityY = 0;
  }
  
  if ((key == 'w'  || keyCode == UP) && !(head.next.x == head.x && head.next.y == head.y-1)) {
    velocityX = 0;
    velocityY = -1;
  }
  
  if ((key == 's' || keyCode == DOWN) && !(head.next.x == head.x && head.next.y == head.y+1)) {
    velocityX = 0;
    velocityY = 1;
  }
  
  if ((key == 'd' || keyCode == RIGHT)  && !(head.next.x == head.x+1 && head.next.y == head.y)) {
    velocityX = 1;
    velocityY = 0;
  }
}

void tryGameStep() {
  float actualGameStepTime = gameStepTime - (applesEaten*appleSpeedBoost);
  
  float currentTime = millis();
  currentStepTime = currentTime - lastStepTime;
  if (currentStepTime > actualGameStepTime) {
    lastStepTime = currentTime;
    gameStep();
  }
}

void gameStep() {
  int newX = head.x + velocityX;
  int newY = head.y + velocityY;
  
  if (isGameover(newX, newY)) {
    gameover = true;  
    return; 
  }
  
  if (head.x == appleX && head.y == appleY) {
    makeNewHead(newX, newY);
    spawnApple();
    applesEaten++;
  } else {
    makeNewHead(newX, newY);
    removeTail();
  }
}

boolean isGameover(int newX, int newY) {
  return isWalls(newX, newY) || isInSnake(newX, newY);
}

boolean isWalls(int newX, int newY) {
  if (newX < 0) return true;
  if (newX >= worldDimension) return true;
  if (newY < 0) return true;
  if (newY >= worldDimension) return true;
   
  return false;
}

void makeNewHead(int newX, int newY) {
  SnakeCell newHead =new SnakeCell(newX, newY);
  newHead.next = head;
  head.prev = newHead;
  head = newHead;
}

void removeTail() {
  SnakeCell newTail = tail.prev;
  newTail.next = null;
  tail = newTail;
}

void render() {
  renderWalls();
  renderApple(); 
  renderSnake();
}

void spawnApple() {
  //PVector[] possibleSpots = new PVector[worldDimension*worldDimension];
  //int current = 0;
  //for (int i=0; i<worldDimension; ++i) {
  //  for (int j=0; j<worldDimension; ++j) {
  //    possibleSpots[current++] = new PVector(i, j);
  //  }
  //}
  
  do {
    appleX = floor(random(worldDimension));
    appleY = floor(random(worldDimension));
  } while (isInSnake(appleX, appleY));
}

boolean isInSnake(int x, int y) {
  SnakeCell current = head;
   do {
     if (current.x == x && current.y == y)
       return true;
    
    current = current.next;
  } while(current != null);
  
  return false;
}

void renderWalls() {
  color wallColor = color(0,0,0);
  for (int i=0; i<=worldDimension; ++i) {
    renderBlock(i, 0, wallColor);
    renderBlock(i, worldDimension+1, wallColor);
    
    renderBlock(0, i, wallColor);
    renderBlock(worldDimension+1, i, wallColor);
  }
  renderBlock(worldDimension+1, worldDimension+1, wallColor);
}

void renderSnake() {
  SnakeCell current = head;
  
  do {
    renderBlockOnGrid(current.x, current.y, snakeColor);
    current = current.next;
  } while(current != null); 
}

void renderApple() {
  color appleColor = color(250, 0, 0);
  renderBlockOnGrid(appleX, appleY, appleColor);
}

void renderBlockOnGrid(int x, int y, color c) {
  renderBlock(x+1, y+1, c);
}

void renderBlock(int x, int y, color c) {
  fill(c);
  rect((x*blockSize),y*blockSize, blockSize, blockSize);
}
