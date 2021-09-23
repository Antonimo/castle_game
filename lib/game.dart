import 'dart:async';

import 'dart:math';
import 'dart:ui';

import 'package:castle_game/base.dart';
import 'package:castle_game/drawn_line.dart';
import 'package:castle_game/player.dart';
import 'package:castle_game/unit.dart';
import 'package:flutter/material.dart';

class Game {
  StreamController<double> stateStreamController = StreamController<double>.broadcast();

  var running = false;

  DateTime lastTime = DateTime.now();

  List<Player> players = [];

  List<Base> bases = [];

  final List<Unit> units = [];

  void toggleGame() {
    running = !running;
    _runTheGame();
  }

  void init(Size size) {
    print('Game init: $size');

    players.clear();
    units.cast();
    bases.clear();

    players.add(
      Player('p1'),
    );
    players.add(
      Player('p2'),
    );

    bases.add(
      Base(
        players[0],
        Offset(size.width / 2, 85 * size.height / 100),
        Colors.orange,
      ),
    );
    bases.add(
      Base(
        players[1],
        Offset(size.width / 2, 15 * size.height / 100),
        Colors.purple,
      ),
    );

    units.add(
      Unit(
        players[0],
        Offset(size.width / 2, size.height - 10),
      ),
    );

    toggleGame();
  }

  Future<void> _runTheGame() async {
    if (running) {
      lastTime = DateTime.now();
    }
    while (running) {
      // TODO: optimize the delay time to "race" frames
      await Future.delayed(Duration(milliseconds: 1000 ~/ 1));

      final DateTime now = DateTime.now();
      double dt = now.difference(lastTime).inMilliseconds / 1000.0;

      print('game loop ${now}  dt: $dt');

      units.forEach((unit) {
        unit.play(dt, this);
      });

      lastTime = now;
      stateStreamController.add(0);
    }
  }

  void givePathToUnit(DrawnLine line) {
    // TODO: pending unit should not be with all units, opponent could've added units also.

    units.last.path = line;
  }
}
