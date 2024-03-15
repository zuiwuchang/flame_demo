import 'dart:async';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:flame_demo/player/monster.dart';
import 'package:flame_demo/player/role.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import './control.dart';
import './player.dart';

class MyGame extends ControlGame with HasCollisionDetection {
  MyGame({bool debugMode = false}) {
    this.debugMode = debugMode;
  }

  late UIComponent ui;
  @override
  FutureOr<void> onLoad() async {
    // 加載地圖
    final sprite = await Sprite.load('map_01.png');
    final map = SpriteComponent(
      sprite: sprite,
    );
    world.add(map);
    const space = (64 - 48) / 2;
    final rect = Rect.fromLTWH(-space, -space, map.width - 48 + space * 2,
        map.height - 48 + space * 2);

    // 加載角色
    final player = Player("archers");
    player.position = map.size / 2;
    player.position.y += mapUnit;
    player.rect = rect;
    world.add(player);
    // 添加怪物
    world.addAll([
      for (var i = 0; i < 4; i++)
        Monster(player, 'puppet')
          ..position = Vector2(
              player.position.x - mapUnit * (i + 3) - mapUnit * i,
              player.position.y - mapUnit * (i + 3) - mapUnit * i)
          ..rect = rect,
      for (var i = 0; i < 4; i++)
        Monster(player, 'doll')
          ..position = Vector2(
              player.position.x + mapUnit * (i + 3) + mapUnit * i,
              player.position.y - mapUnit * (i + 3) - mapUnit * i)
          ..rect = rect,
    ]);

    // 移動攝像機
    camera.viewfinder.position = player.position;

    add(HardwareKeyboardDetector(onKeyEvent: (event) {
      actionByKeyEvent(event, HardwareKeyboard.instance.logicalKeysPressed);
    }));

    // 添加 ui 層
    add(ui = UIComponent(priority: camera.priority + 1));

    player.joystick = ui.joystick;
  }

  @override
  void onRemove() {
    removeAll(children);
    processLifecycleEvents();
    images.clearCache();
    assets.clearCache();
  }
}

class UIComponent extends Component {
  UIComponent({super.priority});
  final camera = CameraComponent(
    world: World(),
    viewfinder: Viewfinder(),
  );
  final joystick = JoystickComponent(
    knob: CircleComponent(
      radius: 30,
      paint: BasicPalette.blue.withAlpha(200).paint(),
    ),
    background: CircleComponent(
      radius: 100,
      paint: BasicPalette.blue.withAlpha(100).paint(),
    ),
    margin: const EdgeInsets.only(left: 8, bottom: 8),
  );
  @override
  FutureOr<void> onLoad() {
    // 添加控制器
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewport.add(joystick);
    addAll([camera, camera.world!]);
  }
}
