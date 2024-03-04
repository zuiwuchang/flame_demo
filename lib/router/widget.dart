import 'package:flame/game.dart';
import './game.dart';
import 'package:flutter/material.dart';

class MyRouterPage extends StatelessWidget {
  const MyRouterPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Router'),
      ),
      body: GameWidget(
        game: MyGame(
            // debugMode: true,
            ),
        overlayBuilderMap: {
          'star': (context, MyGame game) {
            return IconButton(
              onPressed: () {
                debugPrint("on click star");
              },
              icon: const Icon(
                Icons.star,
                color: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }
}
