import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

// 定義角色方向
enum RoleDirection { arrowDown, arrowLeft, arrowRight, arrowUp }

// 定義角色動畫
enum RoleAnimation {
  moveDown,
  moveLeft,
  moveRight,
  moveUp,

  attackDown,
  attackLeft,
  attackRight,
  attackUp,

  deadDown,
  deadLeft,
  deadRight,
  deadUp,
}

// 訂閱角色狀態
enum RoleState {
  idle,
  move,
  attack,
  dead,
}

// 地圖單位距離
const mapUnit = 48.0;
// 角色尺寸
const roleSize = 64.0;

// 定義遊戲角色
class Role<T extends FlameGame<World>> extends PositionComponent
    with HasGameReference<T> {
  Rect? rect;
  Role(
    this.assets, {
    RoleDirection direction = RoleDirection.arrowDown,
    CollisionType collisionType = CollisionType.passive,
    this.speed = 48.0,
  })  : _direction = direction,
        _collisionType = collisionType;
  final String assets;
  late SpriteAnimationGroupComponent<RoleAnimation> _animation;
  RoleDirection _direction;
  RoleDirection get direction => _direction;
  var _state = RoleState.idle;
  final CollisionType _collisionType;

  // 角色移動速度
  double speed;

  // 是否接收輸入控制
  bool get canAttack {
    switch (_state) {
      case RoleState.attack:
      case RoleState.dead:
        return false;
      default:
        return true;
    }
  }

  // 是否可以移動
  bool get canMove {
    switch (_state) {
      case RoleState.attack:
      case RoleState.dead:
        return false;
      default:
        return true;
    }
  }

  bool get isDead => _state == RoleState.dead;

  @override
  FutureOr<void> onLoad() async {
    size = Vector2(roleSize, roleSize);
    anchor = const Anchor(
        (roleSize - mapUnit) / 2 / roleSize, (roleSize - mapUnit) / roleSize);

    // 添加碰撞盒
    const x = 12.0;
    const y = 12.0;
    add(
      RectangleHitbox(
        collisionType: _collisionType,
        position: Vector2((roleSize - mapUnit + x * 2) / 2, y),
        size: Vector2(mapUnit - x * 2, roleSize - y * 2),
      ),
    );

    final animations = <RoleAnimation, SpriteAnimation>{};
    // 移動動畫
    var values = <RoleAnimation>[
      RoleAnimation.moveDown,
      RoleAnimation.moveLeft,
      RoleAnimation.moveRight,
      RoleAnimation.moveUp,
    ];
    for (var i = 0; i < values.length; i++) {
      animations[values[i]] = await game.loadSpriteAnimation(
        '${assets}_move.png',
        SpriteAnimationData.sequenced(
          textureSize: Vector2(48, 64),
          amount: 4,
          stepTime: 0.15,
          texturePosition: Vector2(0, roleSize * i),
        ),
      );
    }
    // 加載攻擊動畫
    values = <RoleAnimation>[
      RoleAnimation.attackDown,
      RoleAnimation.attackLeft,
      RoleAnimation.attackRight,
      RoleAnimation.attackUp,
    ];
    for (var i = 0; i < values.length; i++) {
      animations[values[i]] = await game.loadSpriteAnimation(
        '${assets}_attack.png',
        SpriteAnimationData.sequenced(
          textureSize: Vector2(64, 64),
          amount: 4,
          stepTime: 0.15,
          texturePosition: Vector2(0, 64.0 * i),
          loop: false,
        ),
      );
    }

    // 加載死亡動畫
    values = <RoleAnimation>[
      RoleAnimation.deadDown,
      RoleAnimation.deadLeft,
      RoleAnimation.deadRight,
      RoleAnimation.deadUp,
    ];
    for (var i = 0; i < values.length; i++) {
      animations[values[i]] = await game.loadSpriteAnimation(
        '${assets}_dead.png',
        SpriteAnimationData.sequenced(
          textureSize: Vector2(48, 48),
          amount: 4,
          stepTime: 0.15,
          texturePosition: Vector2(0, 48.0 * i),
          loop: false,
        ),
      );
    }
    // init
    RoleAnimation current;
    switch (_direction) {
      case RoleDirection.arrowDown:
        current = RoleAnimation.moveDown;
        break;
      case RoleDirection.arrowUp:
        current = RoleAnimation.moveUp;
        break;
      case RoleDirection.arrowLeft:
        current = RoleAnimation.moveLeft;
        break;
      case RoleDirection.arrowRight:
        current = RoleAnimation.moveRight;
        break;
    }
    final animation = SpriteAnimationGroupComponent<RoleAnimation>(
      animations: animations,
      current: current,
      anchor: Anchor.center,
      position: size / 2,
    );
    add(animation);
    _animation = animation;

    // 監聽攻擊狀態
    for (var key in [
      RoleAnimation.attackDown,
      RoleAnimation.attackLeft,
      RoleAnimation.attackRight,
      RoleAnimation.attackUp
    ]) {
      var found = animation.animationTickers?[key];
      if (found != null) {
        found
          ..onComplete = () {
            onCompleteAttack();
          }
          ..onFrame = (v) {
            if (v == 2) {
              onBulletAttack();
            }
          };
      }
    }
    // 監聽死亡完成
    for (var key in [
      RoleAnimation.deadDown,
      RoleAnimation.deadLeft,
      RoleAnimation.deadRight,
      RoleAnimation.deadUp
    ]) {
      var found = animation.animationTickers?[key];
      if (found != null) {
        found.onComplete = () {
          onCompleteDead();
        };
      }
    }
  }

  void onCompleteDead() {
    removeFromParent();
  }

  void onBulletAttack() {}
  @mustCallSuper
  void onCompleteAttack() {
    _state = RoleState.idle;
    switch (_direction) {
      case RoleDirection.arrowDown:
        _animation.current = RoleAnimation.moveDown;
        break;
      case RoleDirection.arrowUp:
        _animation.current = RoleAnimation.moveUp;
        break;
      case RoleDirection.arrowLeft:
        _animation.current = RoleAnimation.moveLeft;
        break;
      case RoleDirection.arrowRight:
        _animation.current = RoleAnimation.moveRight;
        break;
      default:
    }
  }

  // 執行空閒
  @mustCallSuper
  void executeIdle(double dt, {RoleDirection? direction}) {
    if (canMove) {
      _state = RoleState.idle;
      if (direction != null) {
        RoleAnimation animation;
        switch (direction) {
          case RoleDirection.arrowDown:
            animation = RoleAnimation.moveDown;
            break;
          case RoleDirection.arrowUp:
            animation = RoleAnimation.moveUp;
            break;
          case RoleDirection.arrowLeft:
            animation = RoleAnimation.moveLeft;
            break;
          case RoleDirection.arrowRight:
            animation = RoleAnimation.moveRight;
            break;
        }
        if (_animation.current != animation) {
          _animation.current = animation;
        }
        _direction = direction;
      }
    }
  }

  // 執行移動
  @mustCallSuper
  void executeMove(double dt, RoleDirection direction) {
    if (canMove) {
      _state = RoleState.move;
      RoleAnimation animation;
      switch (direction) {
        case RoleDirection.arrowDown:
          animation = RoleAnimation.moveDown;
          position.y += dt * speed;
          break;
        case RoleDirection.arrowUp:
          animation = RoleAnimation.moveUp;
          position.y -= dt * speed;
          break;
        case RoleDirection.arrowLeft:
          animation = RoleAnimation.moveLeft;
          position.x -= dt * speed;
          break;
        case RoleDirection.arrowRight:
          animation = RoleAnimation.moveRight;
          position.x += dt * speed;
          break;
      }
      if (_animation.current != animation) {
        _animation.current = animation;
      }
      _direction = direction;

      if (rect != null) {
        if (position.x < rect!.left) {
          position.x = rect!.left;
        } else if (position.x > rect!.right) {
          position.x = rect!.right;
        }
        if (position.y < rect!.top) {
          position.y = rect!.top;
        } else if (position.y > rect!.bottom) {
          position.y = rect!.bottom;
        }
      }
    }
  }

  // 執行攻擊
  @mustCallSuper
  void executeAttack() {
    if (canAttack) {
      _state = RoleState.attack;
      RoleAnimation animation;
      switch (_direction) {
        case RoleDirection.arrowDown:
          animation = RoleAnimation.attackDown;
          break;
        case RoleDirection.arrowUp:
          animation = RoleAnimation.attackUp;
          break;
        case RoleDirection.arrowLeft:
          animation = RoleAnimation.attackLeft;
          break;
        case RoleDirection.arrowRight:
          animation = RoleAnimation.attackRight;
          break;
      }
      if (_animation.current != animation) {
        _animation.current = animation;
      }
    }
  }

  // 殺死角色
  @mustCallSuper
  void executeKill() {
    if (isDead) {
      return;
    }
    _state = RoleState.dead;
    RoleAnimation animation;
    switch (_direction) {
      case RoleDirection.arrowDown:
        animation = RoleAnimation.deadDown;
        break;
      case RoleDirection.arrowUp:
        animation = RoleAnimation.deadUp;
        break;
      case RoleDirection.arrowLeft:
        animation = RoleAnimation.deadLeft;
        break;
      case RoleDirection.arrowRight:
        animation = RoleAnimation.deadRight;
        break;
    }
    if (_animation.current != animation) {
      _animation.current = animation;
    }
  }
}
