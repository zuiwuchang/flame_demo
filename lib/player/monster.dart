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
      direction = _calculateDirection(0);
      executeIdle(dt, direction: direction);
    }

    _distance = null;
    if (canAttack) {
      final distance = _getDistance();
      if (distance <= mapUnit) {
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

  RoleDirection _calculateDirection(double unit) {
    final x = target.x - position.x;
    final y = target.y - position.y;

    switch (direction) {
      case RoleDirection.arrowDown:
        if (y >= unit) {
          return direction;
        }
        break;
      case RoleDirection.arrowUp:
        if (y <= -unit) {
          return direction;
        }
        break;
      case RoleDirection.arrowLeft:
        if (x <= -unit) {
          return direction;
        }
        break;
      case RoleDirection.arrowRight:
        if (x >= unit) {
          return direction;
        }
        break;
    }

    final absX = x.abs();
    final absY = y.abs();
    if (absX >= absY) {
      return x >= 0 ? RoleDirection.arrowRight : RoleDirection.arrowLeft;
    } else {
      return y >= 0 ? RoleDirection.arrowDown : RoleDirection.arrowUp;
    }
  }

  double? _distance;
  double _getDistance() {
    return _distance ??= position.distanceTo(target.position);
  }
}
