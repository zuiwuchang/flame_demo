import 'dart:async';

import 'package:flame/game.dart';
import 'package:flame/rendering.dart';
import './level.dart';
import './pause.dart';
import './router.dart';
import './home.dart';

class MyGame extends RouterGame {
  MyGame({bool debugMode = false}) {
    this.debugMode = debugMode;
  }
  @override
  late final RouterComponent router;

  @override
  FutureOr<void> onLoad() async {
    add(
      router = RouterComponent(
        initialRoute: 'home',
        routes: {
          'home': Route(HomePage.new),
          'level1': Route(Level1Page.new),
          'level2': Route(Level2Page.new),
          'pause': PauseRoute(),
        },
      ),
    );
  }

  @override
  void onRemove() {
    removeAll(children);
    processLifecycleEvents();
    images.clearCache();
    assets.clearCache();
  }
}

class PauseRoute extends Route {
  PauseRoute() : super(PausePage.new, transparent: true);

  @override
  void onPush(Route? previousRoute) {
    previousRoute!
      ..stopTime()
      ..addRenderEffect(
        PaintDecorator.grayscale(opacity: 0.5)..addBlur(3.0),
      );
  }

  @override
  void onPop(Route nextRoute) {
    nextRoute
      ..resumeTime()
      ..removeRenderEffect();
  }
}
