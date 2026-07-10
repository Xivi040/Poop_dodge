import processing.sound.*;
import processing.pdf.*;

// 플레이어 변수
float playerX;
float playerY;
float playerSize  = 35;
float playerSpeed = 6;

// 플레이어 이동
boolean leftPressed  = false;
boolean rightPressed = false;

// 이미지 (스킨)
PImage poopImg;
PImage bgImg;     // data/bg.png
PImage playerImg; // data/player.png

// 사운드
SoundFile bgmStart;
SoundFile bgmScore;
SoundFile bgmGameOver;
SoundFile bgmClassic;

// 똥@@!!
int poopCount = 5;
ArrayList<Poop> poops = new ArrayList<Poop>();

// 화면
int     score    = 0;
boolean gameOver = true;
boolean Title    = true;
boolean savePDF  = false;

// 랭킹
int[] rankings = new int[10];

// 바운싱볼
ArrayList<BouncingBall> ballList = new ArrayList<BouncingBall>();


void setup() {
  size(700, 700);

  poopImg   = loadImage("poop_0.png");
  bgImg     = loadImage("bg.png");
  playerImg = loadImage("player.png");

  bgmStart    = new SoundFile(this, "dry-fart.mp3");    // 사운드 호출
  bgmScore    = new SoundFile(this, "dash_s.mp3");
  bgmGameOver = new SoundFile(this, "fail.mp3");
  bgmClassic  = new SoundFile(this, "classic.mp3");

  playerX = width / 2 - playerSize / 2;
  playerY = height - 60;

  textFont(createFont("Arial", 50, true));
  textSize(20);

  for (int i = 0; i < poopCount; i++) {
    poops.add(new Poop());
  }
}


void draw() {
  if (savePDF) beginRecord(PDF, "screenshot-" + frameCount + ".pdf");

  background(180, 220, 255);
  if (bgImg != null) image(bgImg, 0, 0, width, height);

  for (BouncingBall b : ballList) {
    b.render();
    b.update();
  }

// 타이틀 화면 텍스트
  if (Title) {
    textAlign(CENTER, CENTER);
    fill(0);
    textSize(50);
    text("POOP DODGE", width / 2, height / 2 - 60);
    textSize(20);
    text("LEFT / RIGHT : Move", width / 2, height / 2 + 10);
    textSize(20);
    text("ScreenShot : 0", width / 2, height / 2 + 40);
    textSize(18);
    fill(80);
    text("Press SPACE to Start", width / 2, height / 2 + 80);
    if (savePDF) { endRecord(); savePDF = false; }
    return;
  }

// 게임오버 텍스트
  if (gameOver) {
    textAlign(CENTER, CENTER);

    fill(255, 0, 0);
    textSize(40);
    text("GAME OVER", width / 2, 110);

    fill(0);
    textSize(22);
    text("Score : " + score, width / 2, 165);

    textSize(18);
    text("── TOP 10 ──", width / 2, 205);
    for (int i = 0; i < 10; i++) {
      if (rankings[i] > 0) {
        fill(0);
        text((i + 1) + ".  " + rankings[i], width / 2, 233 + i * 27);
      } else {
        fill(160);
        text((i + 1) + ".  -", width / 2, 233 + i * 27);
      }
    }

    fill(0);
    textSize(18);
    text("Press R to Restart", width / 2, 560);

    if (savePDF) { endRecord(); savePDF = false; }
    return;
  }

  if (leftPressed)  playerX -= playerSpeed;
  if (rightPressed) playerX += playerSpeed;

  //플레이어 탈출 방지
  playerX = constrain(playerX, 0, width - playerSize);

  // 플레이어 그리기 (스킨 적용)
  if (playerImg != null) {
    image(playerImg, playerX, playerY, playerSize, playerSize);
  } else {
    fill(0, 0, 255);
    rect(playerX, playerY, playerSize, playerSize);
  }

  // 난이도 설정
  int targetCount;
  if      (score >= 201) targetCount = (int)(poopCount * 2.2);
  else if (score >= 141) targetCount = (int)(poopCount * 2.0);
  else if (score >= 121) targetCount = (int)(poopCount * 1.6);
  else if (score >= 81)  targetCount = (int)(poopCount * 1.4);
  else if (score >= 41)  targetCount = (int)(poopCount * 1.2);
  else                   targetCount = poopCount;

  while (poops.size() < targetCount) {
    poops.add(new Poop());
  }

  for (int i = 0; i < poops.size(); i++) {
    Poop p = poops.get(i);
    p.display(score);

    if (p.update(score)) {
      score++;
      bgmScore.play();
    }

    if (p.hits(playerX, playerY, playerSize, score) && !gameOver) {
      gameOver = true;
      bgmClassic.stop();
      bgmGameOver.play();
      addToRanking(score);
    }
  }

  //HUD
  fill(0);
  textAlign(LEFT, TOP);
  textSize(20);
  text("Score : " + score, 10, 10);

  textSize(18);
  if (score >= 201) {
    fill(255, 0, 0);
    text("BOSS MODE!", 10, 40);
  } else if (score >= 141) {
    fill(220, 30, 30);
    text("Phase 3", 10, 40);
  } else if (score >= 121) {
    fill(255, 80, 0);
    text("Phase 2", 10, 40);
  } else if (score >= 81) {
    fill(255, 165, 0);
    text("Phase 1", 10, 40);
  } else if (score >= 41) {
    fill(200, 180, 0);
    text("SPEED UP!", 10, 40);
  }

  if (savePDF) { endRecord(); savePDF = false; }

  float startY = playerY + playerSize;
  float totalH = height - startY;

  float blockW = 50;
  float blockH = 12.5;

  fill(100);
  noStroke();
  rect(0, startY, width, totalH);

  clip(0, startY, width, totalH);

  int rowCount = 0;
  for (float y = startY; y < height; y += blockH) {
    for (float x = -blockW; x < width + blockW; x += blockW) {
      float currentX = x;
      if (rowCount % 2 == 1) {
        currentX -= blockW / 2.0;
      }
      fill(175, 180, 185);
      stroke(110);
      strokeWeight(1.5);
      rect(currentX, y, blockW, blockH, 3);
    }
    rowCount++;
  }
  noClip();

  stroke(80);
  strokeWeight(2);
  line(0, startY, width, startY);
}


void addToRanking(int newScore) {
  for (int i = 0; i < rankings.length; i++) {
    if (newScore > rankings[i]) {
      for (int j = rankings.length - 1; j > i; j--) {
        rankings[j] = rankings[j - 1];
      }
      rankings[i] = newScore;
      break;
    }
  }
}


void keyPressed() {
  if (keyCode == LEFT)  leftPressed  = true;
  if (keyCode == RIGHT) rightPressed = true;

  if (Title && key == ' ') {
    Title    = false;
    gameOver = false;
    bgmStart.play();
    bgmClassic.loop();
  }

  // 타이틀 아닐 때 스페이스 → 마지막 볼 제거
  if (!Title && key == ' ' && ballList.size() > 0) {
    ballList.remove(ballList.size() - 1);
  }

  if (gameOver && (key == 'r' || key == 'R')) {
    restartGame();
  }

  if (key == '0') savePDF = true;
}


void keyReleased() {
  if (keyCode == LEFT)  leftPressed  = false;
  if (keyCode == RIGHT) rightPressed = false;
}


// 마우스 클릭 → 바운싱볼 추가
void mousePressed() {
  BouncingBall b = randomBouncingBall();
  b.x = mouseX;
  b.y = mouseY;
  ballList.add(b);
}


void restartGame() {
  score    = 0;
  gameOver = true;
  Title    = true;

  bgmGameOver.stop();

  playerX = width / 2 - playerSize / 2;

  for (int i = 0; i < poops.size(); i++) {
    poops.get(i).reset();
  }
}
