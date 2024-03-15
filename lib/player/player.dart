import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import './bullet.dart';
import './role.dart';
import './control.dart';

// 移動速度
const playerSpeed = 48.0 * 4;

// 玩家控制的角色
class Player extends Role<ControlGame> {
  Player(
    super.assets,
  ) : super(collisionType: CollisionType.active, speed: playerSpeed);

  JoystickComponent? joystick;
  @override
  void update(double dt) {
    super.update(dt);

    if (canAttack) {
      if (game.actionSets.contains(Action.attack)) {
        executeAttack();
      }
    }
    if (canMove) {
      _move(dt);
    }

    // 讓攝像機跟隨玩家
    game.camera.viewfinder.position = position;
  }

  // 執行移動
  void _move(double dt) {
    if (joystick != null && !joystick!.delta.isZero()) {
      final delta = joystick!.delta;
      if (delta.x < -10) {
        if (delta.y > -delta.x) {
          executeMove(dt, RoleDirection.arrowDown);
        } else if (delta.y < delta.x) {
          executeMove(dt, RoleDirection.arrowUp);
        } else {
          executeMove(dt, RoleDirection.arrowLeft);
        }
        return;
      } else if (delta.x > 10) {
        if (delta.y > delta.x) {
          executeMove(dt, RoleDirection.arrowDown);
        } else if (delta.y < -delta.x) {
          executeMove(dt, RoleDirection.arrowUp);
        } else {
          executeMove(dt, RoleDirection.arrowRight);
        }
        return;
      } else if (delta.y > 10) {
        executeMove(dt, RoleDirection.arrowDown);
        return;
      } else if (delta.y < -10) {
        executeMove(dt, RoleDirection.arrowUp);
        return;
      }
    }

    if (game.actionSets.contains(Action.arrowUp)) {
      executeMove(dt, RoleDirection.arrowUp);
    } else if (game.actionSets.contains(Action.arrowDown)) {
      executeMove(dt, RoleDirection.arrowDown);
    } else if (game.actionSets.contains(Action.arrowLeft)) {
      executeMove(dt, RoleDirection.arrowLeft);
    } else if (game.actionSets.contains(Action.arrowRight)) {
      executeMove(dt, RoleDirection.arrowRight);
    } else {
      executeIdle(dt);
    }
  }

  @override
  void onBulletAttack() {
    switch (direction) {
      case RoleDirection.arrowDown:
        final bullet = Bullet(assets);
        bullet.position = Vector2(position.x + 16, position.y + 4);
        game.world.add(bullet);
        bullet.addAll([
          MoveEffect.by(Vector2(0, 48 * 5), EffectController(duration: 1)),
          RemoveEffect(delay: 1),
        ]);
        break;
      case RoleDirection.arrowUp:
        final bullet = Bullet(assets);
        bullet.position = Vector2(position.x + (64 - 28), position.y + 4);
        bullet.angle = pi;
        game.world.add(bullet);
        bullet.addAll([
          MoveEffect.by(Vector2(0, -48 * 5), EffectController(duration: 1)),
          RemoveEffect(delay: 1),
        ]);
        break;
      case RoleDirection.arrowLeft:
        final bullet = Bullet(assets);
        bullet.position = Vector2(position.x + 16 + 8, position.y + 8 + 4);
        bullet.angle = pi / 2;
        game.world.add(bullet);
        bullet.addAll([
          MoveEffect.by(Vector2(-48 * 5, 0), EffectController(duration: 1)),
          RemoveEffect(delay: 1),
        ]);
        break;
      case RoleDirection.arrowRight:
        final bullet = Bullet(assets);
        bullet.position = Vector2(position.x + 16 + 8, position.y + 8 + 4);
        bullet.angle = -pi / 2;
        game.world.add(bullet);
        bullet.addAll([
          MoveEffect.by(Vector2(48 * 5, 0), EffectController(duration: 1)),
          RemoveEffect(delay: 1),
        ]);
        break;
      default:
    }
  }
}
