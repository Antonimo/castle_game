import 'dart:async';

import 'dart:math';
import 'dart:ui';

import 'package:castle_game/drawn_line.dart';
import 'package:castle_game/unit.dart';

class Game {
  StreamController<double> stateStreamController = StreamController<double>.broadcast();

  var running = false;

  DateTime lastTime = DateTime.now();

  final List<Unit> units = [];

  void toggleGame() {
    running = !running;
    _runTheGame();
  }

  void init(Size size) {
    print('Game init: $size');

    units.add(
      Unit(
        Offset(size.width / 2, size.height - 10),
      )
    );

    toggleGame();
  }

  Future<void> _runTheGame() async {
    if (running){
      lastTime = DateTime.now();
    }
    while (running) {
      // TODO: optimize the delay time to "race" frames
      await Future.delayed(Duration(milliseconds: 1000 ~/ 30));

      final DateTime now = DateTime.now();
      double dt = now.difference(lastTime).inMilliseconds / 1000.0;

      print('game loop ${now}  dt: $dt');

      units.forEach((unit) {
        if (unit.path != null){
          unit.move(dt);
        }
      });

      lastTime = now;
      stateStreamController.add(0);
    }
  }

  void givePathToUnit(DrawnLine line){
    // TODO: pending unit should not be with all units, opponent could've added units also.

    units.last.path = line;
  }
}
