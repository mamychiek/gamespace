import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:gapro/SpaceGame.dart';

class Enemy extends SpriteComponent
    with HasGameRef<SpaceGame>, CollisionCallbacks {
  final double speed;

  Enemy({this.speed = 100, required int baseSpeed})
      : super(size: Vector2.all(44));

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('star.png');
    position = Vector2(Random().nextDouble() * gameRef.size.x, -100);
    anchor = Anchor.center;

    add(CircleHitbox(radius: 10));
  }

  @override
  void update(double dt) {
    if (gameRef.gameStarted && !gameRef.isPaused && !gameRef.isGameOver) {
      position.y += speed * dt; // Constant speed for enemies
      if (position.y > gameRef.size.y) removeFromParent();
    }
  }
}

class Coin extends SpriteComponent
    with HasGameRef<SpaceGame>, CollisionCallbacks {
  Coin({required Vector2 position})
      : super(size: Vector2.all(44), position: position);

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('meteor.png');
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    if (gameRef.gameStarted && !gameRef.isPaused && !gameRef.isGameOver) {
      position.y += 100 * dt; // Constant speed for coins
      if (position.y > gameRef.size.y) removeFromParent();
    }
  }
}
