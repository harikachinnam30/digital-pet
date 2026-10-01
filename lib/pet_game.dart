enum GameStatus {
  playing,
  won,
  lost,
}

class PetGame {
  int happiness;
  int hunger;
  int energy;

  GameStatus status;

  PetGame({
    this.happiness = 50,
    this.hunger = 50,
    this.energy = 70,
    this.status = GameStatus.playing,
  });

  bool get isFinished => status != GameStatus.playing;

  int clampMeter(int value) {
    return value.clamp(0, 100).toInt();
  }

  // Feed:
  // Hunger decreases by 10.
  // Happiness depends on the RESULTING hunger value.
  void feed() {
    if (isFinished) return;

    final nextHunger = clampMeter(hunger - 10);

    hunger = nextHunger;

    if (nextHunger < 30) {
      happiness = clampMeter(happiness - 20);
    } else {
      happiness = clampMeter(happiness + 10);
    }

    energy = clampMeter(energy + 5);

    checkLoss();
  }

  // Play:
  // Happiness +15
  // Hunger +5
  // Energy -10
  bool play() {
    if (isFinished) return false;

    if (energy < 10) {
      return false;
    }

    happiness = clampMeter(happiness + 15);
    hunger = clampMeter(hunger + 5);
    energy = clampMeter(energy - 10);

    checkLoss();

    return true;
  }

  // Run:
  // Happiness +20
  // Hunger +10
  // Energy -20
  bool run() {
    if (isFinished) return false;

    if (energy < 20) {
      return false;
    }

    happiness = clampMeter(happiness + 20);
    hunger = clampMeter(hunger + 10);
    energy = clampMeter(energy - 20);

    checkLoss();

    return true;
  }

  // Rest:
  // Energy +20
  // Hunger +5
  void rest() {
    if (isFinished) return;

    energy = clampMeter(energy + 20);
    hunger = clampMeter(hunger + 5);

    checkLoss();
  }

  // Sleep:
  // Energy +35
  // Hunger +10
  // Happiness -5
  void sleep() {
    if (isFinished) return;

    energy = clampMeter(energy + 35);
    hunger = clampMeter(hunger + 10);
    happiness = clampMeter(happiness - 5);

    checkLoss();
  }

  // Automatic hunger tick.
  //
  // 95 -> 100:
  // Hunger becomes 100, but happiness does NOT decrease.
  //
  // If hunger is already 100 when another tick occurs:
  // happiness decreases by 20.
  void hungerTick() {
    if (isFinished) return;

    if (hunger < 100) {
      hunger = clampMeter(hunger + 5);
    } else {
      hunger = 100;
      happiness = clampMeter(happiness - 20);
    }

    checkLoss();
  }

  // Loss condition:
  // Hunger == 100 AND Happiness <= 10.
  void checkLoss() {
    if (hunger == 100 && happiness <= 10) {
      status = GameStatus.lost;
    }
  }

  // Called only after the continuous win timer finishes.
  void win() {
    if (!isFinished && happiness > 80) {
      status = GameStatus.won;
    }
  }

  // Restore initial state.
  void reset() {
    happiness = 50;
    hunger = 50;
    energy = 70;
    status = GameStatus.playing;
  }
}