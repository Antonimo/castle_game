import 'package:castle_game/game_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// TODO: init settings
// TODO: disable rotation



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
      title: 'Castle game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GamePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

