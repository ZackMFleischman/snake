
// Params ///////////////
int worldDimension = 50;
int blockSize = 16;
float gameStepTime = 150;
float appleSpeedBoost = 5;
color snakeColor1 = color(0, 150, 0);
color snakeColor2 = color(150, 0, 150);
////////////////////////

PFont font;
PFont font2;
int fontSize = 24;
int fontSize2 = 18;

class SnakeCell {
  PVector pos;
  
  SnakeCell next;
  SnakeCell prev;
  
  SnakeCell(PVector pos) {
    this.pos = pos;
  }
}

class Snake {
  SnakeCell head;
  SnakeCell tail;
  
  PVector velocity;
  int applesEaten;
  color snakeColor;
  
  boolean isDead = false;
  
  Snake(PVector velocity, PVector startingPos, color snakeColor) {
    this.velocity = velocity;
    this.snakeColor = snakeColor;

    head = new SnakeCell(startingPos);
    SnakeCell body = new SnakeCell(new PVector(startingPos.x-velocity.x, startingPos.y-velocity.y));
    tail  = new SnakeCell(new PVector(startingPos.x-(2*velocity.x), startingPos.y-(2*velocity.y)));
  
    head.next = body;
    body.next = tail;
    body.prev = head;
    tail.prev = body;
 
    applesEaten = 0;
  }
  
  boolean isInSnake(PVector pos) {
   SnakeCell myCurrent = this.head;
     
   do {
     if (myCurrent.pos.x == pos.x && myCurrent.pos.y == pos.y)
       return true;
      myCurrent = myCurrent.next;
    } while(myCurrent != null);
    
    return false;
  }
  
  boolean intersectsItself() {
    SnakeCell myCurrent = this.head.next;
     
   do {
     if (myCurrent.pos.x == this.head.pos.x && myCurrent.pos.y == this.head.pos.y)
       return true;
      myCurrent = myCurrent.next;
    } while(myCurrent != null);
    
    return false;
  }
  
  boolean isIntersectingOtherSnake(Snake snake) {
     SnakeCell myCurrent = this.head;
     
     do {
       
       if (snake.isInSnake(myCurrent.pos))
           return true;
          
      myCurrent = myCurrent.next;
    } while(myCurrent != null);
    
    return false;
  }
  
  void step() {
    PVector newPos = new PVector(this.head.pos.x + this.velocity.x, this.head.pos.y + this.velocity.y);
    
    if (this.head.pos.x == appleX && this.head.pos.y == appleY) {
      this.makeNewHead(newPos);
      spawnApple();
      this.applesEaten++;
    } else {
      this.makeNewHead(newPos);
      this.removeTail();
    }
  }
  
  void makeNewHead(PVector newPos) {
    SnakeCell newHead = new SnakeCell(newPos);
    newHead.next = this.head;
    this.head.prev = newHead;
    this.head = newHead;
  }
  
  void removeTail() {
    SnakeCell newTail = this.tail.prev;
    newTail.next = null;
    this.tail = newTail;
  }
  
  void render() {
    SnakeCell current = head;
  
    do {
      renderBlockOnGrid(floor(current.pos.x), floor(current.pos.y), snakeColor);
      current = current.next;
    } while(current != null); 
  }
}

Snake snake1;
Snake snake2;

// Game State
int appleX;
int appleY;
boolean gameover = false;


float currentStepTime = 0;
float lastStepTime = 0;

void settings() {
  size(worldDimension * blockSize + blockSize * 2, worldDimension * blockSize + blockSize * 2);
}

void setup() {  
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
  int lineHeight = 40;
  fill(color(200, 0 ,0));  
  textFont(font, fontSize);
  
  if (snake1.isDead && snake2.isDead)
      text("Game Over! It's a tie!", (worldDimension*blockSize)/2 - 150,(worldDimension*blockSize)/2);
  else if (snake1.isDead)
      text("Game Over! Purple wins!", (worldDimension*blockSize)/2 - 150,(worldDimension*blockSize)/2);
  else if (snake2.isDead)
      text("Game Over! Green wins!", (worldDimension*blockSize)/2 - 150,(worldDimension*blockSize)/2);
  
  text("Apples Eaten by Green: " + snake1.applesEaten, (worldDimension*blockSize)/2 - 100,(worldDimension*blockSize)/2 + lineHeight);
  text("Apples Eaten by Purple: " + snake2.applesEaten, (worldDimension*blockSize)/2 - 100,(worldDimension*blockSize)/2 + lineHeight*2);
  
  textFont(font2, fontSize2);
  text("(Hit space to play again)", (worldDimension*blockSize)/2 - 85,(worldDimension*blockSize)/2 + lineHeight*3);
  
  if (key == ' ') {
    reset();
  }
}

PVector randomWorldPos() {
  return new PVector(floor(random(4, worldDimension-4)), floor(random(4, worldDimension-4)));
}

PVector randomVelocity() {
  int choice = floor(random(0, 4));
  if (choice == 0) return new PVector(-1, 0);
  if (choice == 1) return new PVector(1, 0);
  if (choice == 2) return new PVector(0, 1);
  return new PVector(0, -1);
}


void reset() {
  gameover = false;
  
  snake1 = new Snake(randomVelocity(), randomWorldPos(), snakeColor1);
  do {
    snake2 = new Snake(randomVelocity(), randomWorldPos(), snakeColor2);
  } while(snake1.isIntersectingOtherSnake(snake2));
  
  spawnApple();
}

void checkForInput() {
  if (!keyPressed) return;
  
  if (key == 'a' && !(snake1.head.next.pos.x == snake1.head.pos.x-1 && snake1.head.next.pos.y == snake1.head.pos.y)) {
    snake1.velocity = new PVector(-1, 0);
  }
  
  if (key == 'w' && !(snake1.head.next.pos.x == snake1.head.pos.x && snake1.head.next.pos.y == snake1.head.pos.y-1)) {
    snake1.velocity = new PVector(0, -1);
  }
  
  if (key == 's' && !(snake1.head.next.pos.x == snake1.head.pos.x && snake1.head.next.pos.y == snake1.head.pos.y+1)) {
    snake1.velocity = new PVector(0, 1);
  }
  
  if (key == 'd' && !(snake1.head.next.pos.x == snake1.head.pos.x+1 && snake1.head.next.pos.y == snake1.head.pos.y)) {
    snake1.velocity = new PVector(1, 0);
  }
  
  if (keyCode == LEFT && !(snake2.head.next.pos.x == snake2.head.pos.x-1 && snake2.head.next.pos.y == snake2.head.pos.y)) {
    snake2.velocity = new PVector(-1, 0);
  }
  
  if (keyCode == UP && !(snake2.head.next.pos.x == snake2.head.pos.x && snake2.head.next.pos.y == snake2.head.pos.y-1)) {
    snake2.velocity = new PVector(0, -1);
  }
  
  if (keyCode == DOWN && !(snake2.head.next.pos.x == snake2.head.pos.x && snake2.head.next.pos.y == snake2.head.pos.y+1)) {
    snake2.velocity = new PVector(0, 1);
  }
  
  if (keyCode == RIGHT && !(snake2.head.next.pos.x == snake2.head.pos.x+1 && snake2.head.next.pos.y == snake2.head.pos.y)) {
    snake2.velocity = new PVector(1, 0);
  }
}

void tryGameStep() {
  float actualGameStepTime = gameStepTime - ((snake1.applesEaten + snake2.applesEaten)*appleSpeedBoost);
  
  float currentTime = millis();
  currentStepTime = currentTime - lastStepTime;
  if (currentStepTime > actualGameStepTime) {
    lastStepTime = currentTime;
    gameStep();
  }
}

void gameStep() {
  snake1.step();
  snake2.step();
  
  if (snake1.isInSnake(snake2.head.pos) || isWalls(snake2.head.pos) || snake2.intersectsItself()) {
    snake2.isDead = true;
  }
  
  if (snake2.isInSnake(snake1.head.pos) || isWalls(snake1.head.pos) || snake1.intersectsItself()) {
    snake1.isDead = true;
  }
  
  if (snake1.isDead || snake2.isDead) {
    gameover = true;
  }
}

boolean isGameover(PVector pos) {
  return isWalls(pos) || snake1.isInSnake(pos) || snake2.isInSnake(pos);
}

boolean isWalls(PVector pos) {
  if (pos.x < 0) return true;
  if (pos.x >= worldDimension) return true;
  if (pos.y < 0) return true;
  if (pos.y >= worldDimension) return true;
   
  return false;
}


void render() {
  renderWalls();
  renderApple(); 
  snake1.render();
  snake2.render();
}

void spawnApple() {
  do {
    appleX = floor(random(worldDimension));
    appleY = floor(random(worldDimension));
  } while (snake1.isInSnake(new PVector(appleX, appleY)) || snake2.isInSnake(new PVector(appleX, appleY)));
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
