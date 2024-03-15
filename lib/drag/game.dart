import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import './star.dart';
import './target.dart';

class MyGame extends FlameGame {
  MyGame({bool debugMode = false}) {
    this.debugMode = debugMode;
  }
  @override
  Future<void> onLoad() async {
    addAll([
      DragTarget(),
      Star(
        n: 5,
        radius1: 40,
        radius2: 20,
        sharpness: 0.2,
        color: const Color(0xffbae5ad),
        position: Vector2(70, 70),
      ),
      Star(
        n: 3,
        radius1: 50,
        radius2: 40,
        sharpness: 0.3,
        color: const Color(0xff6ecbe5),
        position: Vector2(70, 160),
      ),
      Star(
        n: 12,
        radius1: 10,
        radius2: 75,
        sharpness: 1.3,
        color: const Color(0xfff6df6a),
        position: Vector2(70, 270),
      ),
      Star(
        n: 10,
        radius1: 20,
        radius2: 17,
        sharpness: 0.85,
        color: const Color(0xfff82a4b),
        position: Vector2(110, 110),
      ),
    ]);
  }
}
