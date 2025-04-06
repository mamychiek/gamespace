import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:gapro/SpaceGame.dart';

class Astronaut extends SpriteComponent
    with
        HasGameRef<SpaceGame>,
        CollisionCallbacks,
        TapCallbacks,
        DragCallbacks {
  double movementSpeed = 200;
  bool isInvincible = false;
  double invincibilityTimer = 0;

  Astronaut() : super(size: Vector2.all(74));

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('asto.png');
    position = Vector2(gameRef.size.x / 2, gameRef.size.y - 100);
    anchor = Anchor.center;
    add(CircleHitbox(radius: 10));
  }

  void clearEffects() {
    // Logic to clear effects, e.g., removing applied effects
    removeAll(children.whereType<Effect>());
  }

  void changeColor(Color newColor) {
    paint.color = newColor;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Visual indication of invincibility
    if (isInvincible) {
      opacity = (opacity == 1.0) ? 0.5 : 1.0;
    } else {
      opacity = 1.0;
    }
  }

  void moveLeft(double dt, bool fastMovement) {
    final speed = movementSpeed * (fastMovement ? 2 : 1);
    position.x -= speed * dt;

    // Keep astronaut within screen bounds
    position.x = position.x.clamp(size.x / 2, gameRef.size.x - size.x / 2);
  }

  void moveRight(double dt, bool fastMovement) {
    final speed = movementSpeed * (fastMovement ? 2 : 1);
    position.x += speed * dt;

    // Keep astronaut within screen bounds
    position.x = position.x.clamp(size.x / 2, gameRef.size.x - size.x / 2);
  }

  // bool collidesWith(Component other) {
  //   // Simple collision detection function
  //   final distance = position.distanceTo(other.position);
  //   return distance < 32; // Using half of the size for collision detection
  // }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (gameRef.gameStarted && !gameRef.isPaused && !gameRef.isGameOver) {
      // Update player position based on finger movement
      position.x += event.delta.x;

      // Ensure player stays within screen bounds
      position.x = position.x.clamp(size.x / 2, gameRef.size.x - size.x / 2);

      // We keep vertical position fixed in this game
      position.y = gameRef.size.y - 100;
    }
  }

  // bool collidesWith(Component other) {
  // final distance = position.distanceTo(other.position);
  // return distance < 28; // تقليل الرقم لجعل التصادم أقرب
  // }
}
