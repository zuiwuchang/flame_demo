import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_demo/player/bullet.dart';
import './control.dart';

// 地圖單位距離
const mapUnit = 48.0;
// 角色尺寸
const playerSize = 64.0;
// 移動速度
const playerSpeed = 48.0 * 2;

// 定義角色動畫
enum PlayerAnimation {
  moveDown,
  moveLeft,
  moveRight,
  moveUp,

  attackDown,
  attackLeft,
  attackRight,
  attackUp,
}

// 定義角色方向
enum Direction { arrowDown, arrowLeft, arrowRight, arrowUp }

// 訂閱角色狀態
enum PlayerState {
  idle,
  move,
  attack,
}

// 玩家控制的角色
class Player extends PositionComponent with HasGameRef<ControlGame> {
  Player(
    this.assets,
  );
  final String assets;
  late SpriteAnimationGroupComponent<PlayerAnimation> _animation;
  var _direction = Direction.arrowDown;
  var _state = PlayerState.idle;
  // 是否接收輸入控制
  bool get canAttack {
    switch (_state) {
      case PlayerState.attack:
        return false;
      default:
        return true;
    }
  }

  // 是否可以移動
  bool get canMove {
    switch (_state) {
      case PlayerState.attack:
        return false;
      default:
        return true;
    }
  }

  @override
  FutureOr<void> onLoad() async {
    size = Vector2(playerSize, playerSize);
    anchor = const Anchor((playerSize - mapUnit) / 2 / playerSize,
        (playerSize - mapUnit) / playerSize);

    final animations = <PlayerAnimation, SpriteAnimation>{};
    // 移動動畫
    var values = <PlayerAnimation>[
      PlayerAnimation.moveDown,
      PlayerAnimation.moveLeft,
      PlayerAnimation.moveRight,
      PlayerAnimation.moveUp,
    ];
    for (var i = 0; i < values.length; i++) {
      animations[values[i]] = await game.loadSpriteAnimation(
        '${assets}_move.png',
        SpriteAnimationData.sequenced(
          textureSize: Vector2(48, 64),
          amount: 4,
          stepTime: 0.15,
          texturePosition: Vector2(0, playerSize * i),
        ),
      );
    }
    // 加載攻擊動畫
    values = <PlayerAnimation>[
      PlayerAnimation.attackDown,
      PlayerAnimation.attackLeft,
      PlayerAnimation.attackRight,
      PlayerAnimation.attackUp,
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
    // init
    final animation = SpriteAnimationGroupComponent<PlayerAnimation>(
      animations: animations,
      current: PlayerAnimation.moveDown,
      anchor: Anchor.center,
      position: size / 2,
    );
    add(animation);
    _animation = animation;

    for (var key in [
      PlayerAnimation.attackDown,
      PlayerAnimation.attackLeft,
      PlayerAnimation.attackRight,
      PlayerAnimation.attackUp
    ]) {
      var found = animation.animationTickers?[key];
      if (found != null) {
        found
          ..onComplete = () {
            _completeAttack();
          }
          ..onFrame = (v) {
            if (v == 2) {
              _bulletAttack();
            }
          };
      }
    }
  }

  _bulletAttack() {
    switch (_direction) {
      case Direction.arrowDown:
        final bullet = Bullet(assets);
        bullet.position = Vector2(position.x + 16, position.y + 4);
        game.world.add(bullet);
        bullet.addAll([
          MoveEffect.by(Vector2(0, 48 * 5), EffectController(duration: 1)),
          RemoveEffect(delay: 1),
        ]);
        break;
      case Direction.arrowUp:
        final bullet = Bullet(assets);
        bullet.position = Vector2(position.x + (64 - 28), position.y + 4);
        bullet.angle = pi;
        game.world.add(bullet);
        bullet.addAll([
          MoveEffect.by(Vector2(0, -48 * 5), EffectController(duration: 1)),
          RemoveEffect(delay: 1),
        ]);
        break;
      case Direction.arrowLeft:
        final bullet = Bullet(assets);
        bullet.position = Vector2(position.x + 16 + 8, position.y + 8 + 4);
        bullet.angle = pi / 2;
        game.world.add(bullet);
        bullet.addAll([
          MoveEffect.by(Vector2(-48 * 5, 0), EffectController(duration: 1)),
          RemoveEffect(delay: 1),
        ]);
        break;
      case Direction.arrowRight:
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

  _completeAttack() {
    _state = PlayerState.idle;
    switch (_direction) {
      case Direction.arrowDown:
        _animation.current = PlayerAnimation.moveDown;
        break;
      case Direction.arrowUp:
        _animation.current = PlayerAnimation.moveUp;
        break;
      case Direction.arrowLeft:
        _animation.current = PlayerAnimation.moveLeft;
        break;
      case Direction.arrowRight:
        _animation.current = PlayerAnimation.moveRight;
        break;
      default:
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (canAttack) {
      if (game.actionSets.contains(Action.attack)) {
        _attack();
      }
    }
    if (canMove) {
      if (_move(dt)) {
        _state = PlayerState.move;
      } else {
        _state = PlayerState.idle;
      }
    }

    // 讓攝像機跟隨玩家
    game.camera.viewfinder.position = position;
  }

  bool _moveDirection(Direction direction, PlayerAnimation animation) {
    switch (_state) {
      case PlayerState.idle:
      case PlayerState.move:
        if (_animation.current != animation) {
          _animation.current = animation;
        }
        _direction = direction;
        return true;
      default:
    }
    return false;
  }

  // 執行移動
  bool _move(double dt) {
    if (game.actionSets.contains(Action.arrowUp)) {
      _moveDirection(Direction.arrowUp, PlayerAnimation.moveUp);
      position.y -= dt * playerSpeed;
      return true;
    } else if (game.actionSets.contains(Action.arrowDown)) {
      _moveDirection(Direction.arrowDown, PlayerAnimation.moveDown);
      position.y += dt * playerSpeed;
      return true;
    } else if (game.actionSets.contains(Action.arrowLeft)) {
      _moveDirection(Direction.arrowLeft, PlayerAnimation.moveLeft);
      position.x -= dt * playerSpeed;
      return true;
    } else if (game.actionSets.contains(Action.arrowRight)) {
      _moveDirection(Direction.arrowRight, PlayerAnimation.moveRight);
      position.x += dt * playerSpeed;
      return true;
    }
    return false;
  }

  // 執行攻擊
  _attack() {
    _state = PlayerState.attack;
    switch (_direction) {
      case Direction.arrowDown:
        _animation.current = PlayerAnimation.attackDown;
        break;
      case Direction.arrowUp:
        _animation.current = PlayerAnimation.attackUp;
        break;
      case Direction.arrowLeft:
        _animation.current = PlayerAnimation.attackLeft;
        break;
      case Direction.arrowRight:
        _animation.current = PlayerAnimation.attackRight;
        break;
    }
  }
}
