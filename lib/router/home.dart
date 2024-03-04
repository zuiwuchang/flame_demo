import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_demo/router/rate.dart';
import './router.dart';
import './ui.dart';
import 'package:flutter/material.dart';

class HomePage extends Component with HasGameReference<RouterGame> {
  late final TextComponent _logo;
  late final RoundedButton _button1;
  late final RoundedButton _button2;
  late final RoundedButton _button3;
  late final RoundedButton _button4;
  late final RoundedButton _button5;
  late final TextComponent _text;
  @override
  FutureOr<void> onLoad() async {
    addAll([
      _logo = TextComponent(
        text: 'Cerberus',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 64,
            color: Color(0xFFC8FFF5),
            fontWeight: FontWeight.w800,
          ),
        ),
        anchor: Anchor.center,
      ),
      _button1 = RoundedButton(
        text: 'Level 1',
        action: () => game.router.pushNamed('level1'),
        color: const Color(0xffadde6c),
        borderColor: const Color(0xffedffab),
      ),
      _button2 = RoundedButton(
        text: 'Level 2',
        action: () => game.router.pushNamed('level2'),
        color: const Color(0xffdebe6c),
        borderColor: const Color(0xfffff4c7),
      ),
      _button3 = RoundedButton(
        text: 'pushOverlay',
        action: () => game.router.pushOverlay('star'),
        color: const Color(0xffdebe6c),
        borderColor: const Color(0xfffff4c7),
      ),
      _button4 = RoundedButton(
        text: 'pop',
        action: () {
          if (game.router.currentRoute.name == 'star') {
            game.router.pop();
          }
        },
        color: const Color(0xffdebe6c),
        borderColor: const Color(0xfffff4c7),
      ),
      _button5 = RoundedButton(
        text: 'Rate me',
        action: () async {
          final score = await game.router.pushAndWait(RateRoute());
          _text.text = 'Score: $score';
        },
        color: const Color(0xff758f9a),
        borderColor: const Color(0xff60d5ff),
      ),
      _text = TextComponent(
        text: 'Score: –',
        anchor: Anchor.topCenter,
        position: game.size / 2 + Vector2(0, 30),
        scale: Vector2.all(0.7),
      ),
    ]);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _logo.position = Vector2(size.x / 2, size.y / 3);
    _button1.position = Vector2(size.x / 2, _logo.y + 80);
    _button2.position = Vector2(size.x / 2, _logo.y + 140);
    _button3.position = Vector2(size.x / 2 - 80, _logo.y + 200);
    _button4.position = Vector2(size.x / 2 + 80, _logo.y + 200);
    _button5.position = Vector2(size.x / 2, _logo.y + 260);
    _text.position = Vector2(size.x / 2, _logo.y + 300);
  }
}
