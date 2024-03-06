import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_demo/player/monster.dart';
import 'package:flame_demo/player/role.dart';
import 'package:flutter/services.dart';
import './control.dart';
import './player.dart';

class MyGame extends ControlGame with HasCollisionDetection {
  MyGame({bool debugMode = false}) {
    this.debugMode = debugMode;
  }
  @override
  FutureOr<void> onLoad() async {
    // 加載地圖
    final sprite = await Sprite.load('map_01.png');
    final map = SpriteComponent(
      sprite: sprite,
    );
    world.add(map);

    // 加載角色
    final player = Player("archers");
    player.position = map.size / 2;
    player.position.y += mapUnit;
    world.add(player);

    // 添加怪物
    world.addAll([
      for (var i = 0; i < 4; i++)
        Monster(player, 'puppet')
          ..position = Vector2(
              player.position.x - mapUnit * (i + 3) - mapUnit * i,
              player.position.y - mapUnit * (i + 3) - mapUnit * i),
      for (var i = 0; i < 4; i++)
        Monster(player, 'doll')
          ..position = Vector2(
              player.position.x + mapUnit * (i + 3) + mapUnit * i,
              player.position.y - mapUnit * (i + 3) - mapUnit * i),
    ]);

    // 移動攝像機
    camera.viewfinder.position = player.position;

    add(HardwareKeyboardDetector(onKeyEvent: (event) {
      actionByKeyEvent(event, HardwareKeyboard.instance.logicalKeysPressed);
    }));
  }

  @override
  void onRemove() {
    removeAll(children);
    processLifecycleEvents();
    images.clearCache();
    assets.clearCache();
  }
}
