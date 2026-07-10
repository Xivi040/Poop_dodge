class Poop {

  float x, y;
  float speed;
  float size;

  Poop() {
    reset();
    y = -random(50, 300);
  }

  void reset() {
    x     = random(20, width - 20);
    y     = -random(50, 300);
    speed = random(3, 9);
    size  = random(20, 60);
  }

  boolean update(int score) {
    float mult;

    if      (score >= 201) mult = 2.7;
    else if (score >= 141) mult = 2.5;
    else if (score >= 121) mult = 2.0;
    else if (score >= 81)  mult = 1.4;
    else if (score >= 41)  mult = 1.2;
    else                   mult = 1.0;

    y += speed * mult;

    if (y > height + size * 3) {
      reset();
      return true;
    }

    return false;
  }

  void display(int score) {
    if (score >= 201) {
      fill(120, 70, 20);
      rectMode(CENTER);
      rect(x, y, size / 3, size * 3);
      rectMode(CORNER);
    } else {
      imageMode(CENTER);
      image(poopImg, x, y, size, size);
      imageMode(CORNER);
    }
  }

  boolean hits(float px, float py, float ps, int score) {
    float hitW, hitH;

    if (score >= 201) {
      hitW = size / 3;
      hitH = size * 3;
    } else {
      hitW = size;
      hitH = size;
    }

    return x + hitW / 2 > px
        && x - hitW / 2 < px + ps
        && y + hitH / 2 > py
        && y - hitH / 2 < py + ps;
  }
}
