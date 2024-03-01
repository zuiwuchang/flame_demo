import 'package:flame_demo/player/widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flame Game Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flame Game Demo'),
      ),
      body: ListView(
        children: [
          Route(
            title: 'Player',
            builder: (context) => const MyPlayerPage(),
          ),
        ]
            .map((e) => ListTile(
                  title: Text(e.title),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => e.builder(context)));
                  },
                ))
            .toList(),
      ),
    );
  }
}

class Route {
  final String title;
  final Widget Function(BuildContext) builder;
  const Route({required this.title, required this.builder});
}
