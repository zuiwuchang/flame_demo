import 'dart:async';
import 'dart:ffi';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_demo/player/bullet.dart';

import './role.dart';

class Monster extends Role with CollisionCallbacks {
  Monster(this.target, super.assets, {super.direction});

  final Role target;
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (isDead || target.isDead) {
      return;
    }
    super.onCollision(intersectionPoints, other);
    if (other is Role) {
      other.executeKill();
    } else if (other is Bullet) {
      other.removeFromParent();
      executeKill();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead || target.isDead) {
      return;
    }

    RoleDirection? direction;
    if (canMove) {
      final x = target.x - position.x;
      final y = target.y - position.y;

      final absX = x.abs();
      final absY = y.abs();
      if (absX >= absY) {
        if (x >= 0) {
          direction = RoleDirection.arrowRight;
        } else {
          direction = RoleDirection.arrowLeft;
        }
      } else {
        if (y >= 0) {
          direction = RoleDirection.arrowDown;
        } else {
          direction = RoleDirection.arrowUp;
        }
      }

      executeIdle(dt, direction: direction);
    }

    _distance = null;
    if (canAttack) {
      final distance = _getDistance();
      if (distance <= mapUnit * 2) {
        executeAttack();
        return;
      }
    }
    if (direction != null) {
      final distance = _getDistance();
      if (distance <= mapUnit * 4) {
        executeMove(dt, direction);
      }
    }
  }

  double? _distance;
  double _getDistance() {
    return _distance ??= position.distanceTo(target.position);
  }
}
