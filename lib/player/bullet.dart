import 'dart:async';

import 'package:flame/components.dart';

// 發射的子彈
class Bullet extends PositionComponent with HasGameRef {
  Bullet(this.assets);
  final String assets;
  @override
  FutureOr<void> onLoad() async {
    final bullet = SpriteAnimationComponent.fromFrameData(
      await game.images.load('${assets}_bullet.png'),
      SpriteAnimationData.sequenced(
        textureSize: Vector2(16, 48),
        amount: 4,
        stepTime: 0.2,
        texturePosition: Vector2(0, 48 * 0),
      ),
    );
    add(bullet);
  }
}
