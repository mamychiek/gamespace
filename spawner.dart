import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:gapro/SpaceGame.dart';
import 'package:gapro/enemy.dart';
import 'package:gapro/powerup.dart' show Powerup, PowerupType;

// ========================
//      Spawner Systems
// ========================

//      gameRef.add(Enemy(baseSpeed: 100 + (gameRef.level * 10)));
class EnemySpawner extends Component with HasGameRef<SpaceGame> {
  double spawnTimer = 0.0;
  double spawnInterval = 3.0; // في البداية يظهر كل 3 ثوانٍ

  @override
  void update(double dt) {
    super.update(dt);

    // لا تولّد أعداء إذا اللعبة متوقفة أو غير شغالة
    if (!gameRef.gameStarted || gameRef.isPaused || gameRef.isGameOver) return;

    spawnTimer += dt;

    if (spawnTimer >= spawnInterval) {
      spawnTimer = 0.0;
      spawnEnemy();
    }

    // كلما زاد المستوى، قلّل وقت التوليد (لكن لا تقل عن حد معين)
    if (gameRef.level >= 5) {
      spawnInterval = 2.0;
    }
    if (gameRef.level >= 10) {
      spawnInterval = 1.5;
    }
    if (gameRef.level >= 15) {
      spawnInterval = 1.0;
    }
  }

  void spawnEnemy() {
    final enemy = Enemy(baseSpeed: 100 + (gameRef.level * 10));
    enemy.position = Vector2(
      Random().nextDouble() * gameRef.size.x,
      -50, // ابدأ من فوق الشاشة
    );
    gameRef.add(enemy);
  }
}

class CoinSpawner extends Component with HasGameRef<SpaceGame> {
  final Random _random = Random();
  double _timer = 0;

  @override
  void update(double dt) {
    if (!gameRef.gameStarted || gameRef.isPaused || gameRef.isGameOver) return;

    _timer += dt;
    if (_timer >= 3) {
      gameRef.add(
          Coin(position: Vector2(_random.nextDouble() * gameRef.size.x, -30)));
      _timer = 0;
    }
  }
}

class PowerupSpawner extends Component with HasGameRef<SpaceGame> {
  final Random _random = Random();
  double _timer = 0;

  @override
  void update(double dt) {
    if (!gameRef.gameStarted || gameRef.isPaused || gameRef.isGameOver) return;

    _timer += dt;
    if (_timer >= 15) {
      gameRef.add(Powerup(
          PowerupType.values[_random.nextInt(PowerupType.values.length)]));
      _timer = 0;
    }
  }
}
