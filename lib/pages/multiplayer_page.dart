import 'package:castle_game/game/multiplayer_client.dart';
import 'package:flutter/material.dart';

class MultiplayerPage extends StatefulWidget {
  const MultiplayerPage({Key? key}) : super(key: key);

  @override
  _MultiplayerPageState createState() => _MultiplayerPageState();
}

class _MultiplayerPageState extends State<MultiplayerPage> {
  @override
  void initState() {
    super.initState();

    // MultiplayerClient.init();
  }

  @override
  void dispose() {
    MultiplayerClient.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiplayer Game'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32.0),
          child: Column(
            children: _buildPageItems(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPageItems() {
    return [
      SizedBox(height: 32.0),
      SizedBox(height: 32.0),
      ElevatedButton(
        onPressed: () {
          MultiplayerClient.dispose();
          MultiplayerClient.init();

          MultiplayerClient.startGame();

          // TODO: pause game, restart game;
        },
        child: const Text('Play!'),
      ),
    ];
  }
}
