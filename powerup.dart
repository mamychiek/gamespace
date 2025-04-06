import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'dart:math';
import 'package:gapro/SpaceGame.dart';
import 'package:gapro/astronaut.dart';

class Powerup extends SpriteComponent
    with HasGameRef<SpaceGame>, CollisionCallbacks {
  final PowerupType type;

  Powerup(this.type) : super(size: Vector2.all(40));

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('rectangle.png');
    position = Vector2(Random().nextDouble() * gameRef.size.x, -40);
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    if (gameRef.gameStarted && !gameRef.isPaused && !gameRef.isGameOver) {
      position.y += 50 * dt; // حركة ثابتة لعنصر الطاقة
      if (position.y > gameRef.size.y) removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Astronaut) {
      gameRef.activatePowerup(type);
      removeFromParent(); // إزالة عنصر الطاقة بعد التقاطه
    }
  }
}
