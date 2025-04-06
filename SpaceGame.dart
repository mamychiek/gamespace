import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:gapro/astronaut.dart';
import 'package:gapro/enemy.dart';
import 'package:gapro/powerup.dart';
import 'package:gapro/spawner.dart';

enum PowerupType { shield, speedBoost, doublePoints }

class SpaceGame extends FlameGame
    with HasCollisionDetection, TapDetector, KeyboardEvents {
  late Astronaut astronaut;
  int score = 0;
  int level = 1;
  int coinsCollected = 0;
  int totalCoins = 0;
  bool isGameOver = false;
  bool isPaused = false;
  bool gameStarted = false;
  bool fastMovementEnabled = false;
  double speedMultiplier = 1.0;
  double superPowerTimer = 0;
  bool superPowerActive = false;
  bool doublePointsActive = false;

  final Map<String, int> upgrades = {
    'speed': 0,
    'shield': 0,
    'firepower': 0,
  };

  final Map<String, int> questProgress = {
    'collectStars': 0,
    'avoidMeteors': 0,
  };

  final List<String> completedQuests = [];
  final Map<String, int> upgradePrices = {
    'speed': 50,
    'shield': 100,
    'firepower': 75,
  };

  @override
  Future<void> onLoad() async {
    // Initialize astronaut before using it
    astronaut = Astronaut();

    await _initializeGame();
    overlays.add('MainMenu');
  }

  Future<void> _initializeGame() async {
    final background = SpriteComponent()
      ..sprite = await loadSprite('space_bg.png')
      ..size = size;
    add(background);

    add(astronaut);

    // Make sure these spawner classes are defined in the project
    add(EnemySpawner());
    add(PowerupSpawner());
    add(CoinSpawner());
  }

  void toggleFastMovement() {
    if (gameStarted && !isPaused) {
      fastMovementEnabled = !fastMovementEnabled;
    }
  }

  void startGame() {
    resetGameState();
    overlays.remove('MainMenu');
    overlays.add('HUD');
    resumeEngine();
    gameStarted = true;
  }

  void resetGameState() {
    score = 0;
    level = 1;
    coinsCollected = 0;
    isGameOver = false;
    speedMultiplier = 1.0;
    superPowerActive = false;
    fastMovementEnabled = false;
    gameStarted = false;
    upgrades['speed'] = 0;
    upgrades['shield'] = 0;
    upgrades['firepower'] = 0;
  }

  void collectCoin() {
    coinsCollected++;
    totalCoins++;
    questProgress['collectStars'] = (questProgress['collectStars'] ?? 0) + 1;

    int points = doublePointsActive
        ? 20
        : 10; // إذا كان التأثير نشطًا، يتم مضاعفة النقاط
    score += points;

    if (questProgress['collectStars']! >= 10 &&
        !completedQuests.contains('collectStars')) {
      completedQuests.add('collectStars');
      totalCoins += 50;
    }
  }

  void _handleCollisions() {
    children.whereType<Enemy>().forEach((enemy) {
      final double collisionDistance = enemy.width / 2;

      if (astronaut.position.distanceTo(enemy.position) < collisionDistance) {
        if (astronaut.isInvincible) {
          enemy.removeFromParent();
          score += 5;
        } else {
          gameOver();
        }
      }
    });

    children.whereType<Coin>().forEach((coin) {
      if (astronaut.toRect().overlaps(coin.toRect())) {
        collectCoin();
        coin.removeFromParent();
        score += 10;
      }
    });

    children.whereType<Powerup>().forEach((powerup) {
      if (astronaut.toRect().overlaps(powerup.toRect())) {
        activatePowerup(powerup.type);
        powerup.removeFromParent();
      }
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameStarted && !isPaused && !isGameOver) {
      _handleCollisions();
      _updateGameState(dt);
      _updatePowerups(dt);
    }
  }

  void _updateGameState(double dt) {
    if (score > 0 && score % 100 == 0) {
      level++;
      speedMultiplier *= 1.1;
    }
    score += (dt * 60 * speedMultiplier).floor();
  }

  void _updatePowerups(double dt) {
    if (astronaut.isInvincible) {
      astronaut.invincibilityTimer -= dt;
      if (astronaut.invincibilityTimer <= 0) {
        astronaut.isInvincible = false;
        astronaut.clearEffects(); // يرجع للونه الطبيعي
      }
    }

    if (superPowerActive) {
      superPowerTimer -= dt;
      if (superPowerTimer <= 0) {
        superPowerActive = false;
        speedMultiplier = 1.0; // نرجع السرعة العادية
        doublePointsActive = false;
      }
    }
  }

  void activatePowerup(PowerupType type) {
    switch (type) {
      case PowerupType.shield:
        astronaut.isInvincible = true;
        astronaut.invincibilityTimer = 10.0; // يستمر لمدة 10 ثواني
        astronaut.changeColor(Colors.blueAccent); // تغيير لون اللاعب
        Future.delayed(Duration(seconds: 10), () {
          astronaut.isInvincible = false; // تعطيل الحماية بعد 10 ثوانٍ
          astronaut.changeColor(Colors.white); // إعادة اللون الأصلي
        });
        break;

      case PowerupType.speedBoost:
        superPowerActive = true;
        superPowerTimer = 10.0;
        speedMultiplier *= 1.5;
        astronaut.changeColor(Colors.redAccent); // تغيير اللون أثناء البوست
        Future.delayed(Duration(seconds: 10), () {
          superPowerActive = false; // تعطيل السرعة بعد 10 ثوانٍ
          speedMultiplier /= 1.5;
          astronaut.changeColor(Colors.white); // إعادة اللون الأصلي
        });
        break;

      case PowerupType.doublePoints:
        // تنفيذ منطق مضاعفة النقاط إذا كنت تريد إضافته
        break;
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (gameStarted && !isPaused && !isGameOver) {
      final tapPos = info.eventPosition.global;
      final fixedDt = 1 / 60;

      if (tapPos.x < size.x / 2) {
        astronaut.moveLeft(fixedDt, fastMovementEnabled);
      } else {
        astronaut.moveRight(fixedDt, fastMovementEnabled);
      }
    }
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.escape)) {
        togglePause();
        return KeyEventResult.handled;
      }

      if (gameStarted && !isPaused && !isGameOver) {
        const fixedDt = 1 / 60;
        if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
          astronaut.moveLeft(fixedDt, fastMovementEnabled);
          return KeyEventResult.handled;
        }
        if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
          astronaut.moveRight(fixedDt, fastMovementEnabled);
          return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
  }

  void togglePause() {
    if (!gameStarted) return;
    isPaused = !isPaused;

    if (isPaused) {
      overlays.add('PauseMenu');
      pauseEngine();
    } else {
      overlays.remove('PauseMenu');
      resumeEngine();
    }
  }

  void gameOver() {
    isGameOver = true;
    pauseEngine();
    overlays.remove('HUD');
    overlays.add('GameOver');
  }

  void restartGame() {
    removeAll(children);
    _initializeGame();
    resetGameState();
    overlays.remove('GameOver');
    overlays.add('HUD');
    resumeEngine();
    gameStarted = true;
  }

  void openShop() {
    overlays.remove('MainMenu');
    overlays.add('Shop');
  }

  void openQuests() {
    overlays.remove('MainMenu');
    overlays.add('Quests');
  }

  void returnToMainMenu() {
    gameStarted = false;
    overlays.removeAll(['Shop', 'Quests', 'HUD', 'PauseMenu', 'GameOver']);
    overlays.add('MainMenu');
    pauseEngine();

    if (!isGameOver) {
      removeAll(children);
      _initializeGame();
      resetGameState();
    }
  }

  void purchaseUpgrade(String upgradeType) {
    final price = upgradePrices[upgradeType] ?? 0;

    if (totalCoins >= price) {
      totalCoins -= price;
      upgrades[upgradeType] = (upgrades[upgradeType] ?? 0) + 1;

      if (upgradeType == 'speed') {
        astronaut.movementSpeed = 200 + (upgrades['speed']! * 50);
      }

      overlays.remove('Shop');
      overlays.add('Shop');
    }
  }
}
