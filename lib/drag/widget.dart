import 'package:flame/game.dart';
import './game.dart';
import 'package:flutter/material.dart';

class MyDragPage extends StatelessWidget {
  const MyDragPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Drag Events'),
      ),
      body: GameWidget(
        game: MyGame(
            // debugMode: true,
            ),
      ),
    );
  }
}
