import 'package:flame/game.dart';
import 'package:flutter/services.dart';

// 定義角色允許的輸入控制
enum Action {
  idle,

  arrowDown,
  arrowLeft,
  arrowRight,
  arrowUp,

  attack,
}

final Map<LogicalKeyboardKey, Action> playerKeys = {
  LogicalKeyboardKey.keyW: Action.arrowUp,
  LogicalKeyboardKey.keyS: Action.arrowDown,
  LogicalKeyboardKey.keyA: Action.arrowLeft,
  LogicalKeyboardKey.keyD: Action.arrowRight,
  LogicalKeyboardKey.keyJ: Action.attack,
};

mixin PlayerControl {
  // 當前有效按鍵
  final actionSets = <Action>{};

// 通常鍵盤按下一個按鍵後如果按下新的按鍵原按鍵事件不會再接收
// 例如按下 w 移動但不擡去，此時按下 j 攻擊，如果不重新按下 w 不會收到移動指令，一種處理方案是
// 對於移動之類這種按下就不用擡去的控制，記錄按下的鍵並在 update 回調中判斷按鍵是否按下
  actionByKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // 清空當前按鍵
    actionSets.clear();

    // 設置當前按鍵
    for (final key in keysPressed) {
      final found = playerKeys[key];
      if (found != null) {
        actionSets.add(found);
      }
    }
  }
}

class ControlGame extends FlameGame with PlayerControl {}
