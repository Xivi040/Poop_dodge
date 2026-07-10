class Sprite {
  float x, y;
  float dx, dy;

  void update() {
    x += dx;
    y += dy;
  }
}

class BouncingBall extends Sprite {
  float diam;
  color fillColor;

  void render() {
    pushMatrix();
    noStroke();
    fill(fillColor);
    ellipse(x, y, diam, diam);
    popMatrix();
  }

  void update() {
    x += dx;
    y += dy;

    if (y - diam / 2 < 0)      { y = diam / 2;          dy = -dy; }
    if (y + diam / 2 > height) { y = height - diam / 2;  dy = -dy; }
    if (x - diam / 2 < 0)      { x = diam / 2;          dx = -dx; }
    if (x + diam / 2 > width)  { x = width - diam / 2;   dx = -dx; }
  }
}

BouncingBall randomBouncingBall() {
  BouncingBall ball = new BouncingBall();
  ball.x         = random(100, 200);
  ball.y         = random(100, 200);
  ball.dx        = random(-3, 3);
  ball.dy        = random(-3, 3);
  ball.diam      = random(50, 150);
  ball.fillColor = color(random(255), random(255), random(255));
  return ball;
}
