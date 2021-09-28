import 'dart:async';

import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:castle_game/game/base.dart';
import 'package:castle_game/game/drawn_line.dart';
import 'package:castle_game/game/player.dart';
import 'package:castle_game/game/unit.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

class Game {
  Subject<double> stateSubject = BehaviorSubject<double>();

  String? id;

  // We are in the game screen
  bool playing = false;

  // We are in the game screen and the game is running
  bool running = false;

  bool canDrawPath = false;

  double drawDistanceMax = 1300.0;
  double drawDistance = 0.0;

  // TODO: move this to LocalMultiplayerClient
  Player? drawPathForPlayer;

  DateTime lastTime = DateTime.now();

  List<Player> players = [];

  List<Base> bases = [];

  List<Unit> units = [];

  void setState() {
    stateSubject.add(0.0);
  }

  void toggleGame() {
    running = !running;
    _runTheGame();
  }

  void init(Size size) {
    print('Game init: $size');

    // players.clear();
    // units.clear();
    // bases.clear();

    canDrawPath = false;

    players.add(
      Player(
        'p1',
        Colors.orange,
        // TODO: use %, cast to Offset
        Offset(size.width / 2, size.height - 10), // TODO: to consts
      ),
    );
    players.add(
      Player(
        'p2',
        Colors.purple,
        Offset(size.width / 2, 10), // TODO: to consts
      ),
    );

    players.forEach((player) {
      player.nextUnitCooldown = 3.0;
    });

    bases.add(
      Base(
        players[0],
        Offset(size.width / 2, 85 * size.height / 100),
        players[0].color,
      ),
    );
    bases.add(
      Base(
        players[1],
        Offset(size.width / 2, 15 * size.height / 100),
        players[1].color,
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
      await Future.delayed(Duration(milliseconds: 1000 ~/ 400));

      final DateTime now = DateTime.now();
      double dt = now.difference(lastTime).inMilliseconds / 1000.0;

      // print('game loop ${now} ? dt: $dt  [${1000 ~/ 40}]');

      if (!canDrawPath) {
        checkForPendingUnits();
      }

      players.forEach((player) {
        player.play(dt, this);
      });

      units.forEach((unit) {
        unit.play(dt, this);
      });

      // Clear dead units
      units = units.where((unit) => unit.alive).toList();

      for(var base in bases){
        if (base.hp <= 0) {
          // TODO: game over
          running = false;
        }
      }

      lastTime = now;
      stateSubject.add(0);
    }
  }

  void checkForPendingUnits() {
    // final Player? player = players.firstWhereOrNull((player) => player.pendingUnit != null);
    //
    // if (player != null) {
    //   canDrawPath = true;
    //   drawPathForPlayer = player;
    // }

    // fetch my player
    if(players[0].pendingUnit != null) {
      canDrawPath = true;
      drawPathForPlayer = players[0];
    }
  }

  Unit createPendingUnit(Player player) {
    return Unit(
      player,
      player.color,
      player.startPos,
    );
  }

  void removeUnit(Unit unit){
    units.remove(unit);
  }

  // TODO: pending unit should not be with all units, opponent could've added units also.

  void givePathToUnit(DrawnLine line) {
    if (drawPathForPlayer == null || canDrawPath == null) return;

    drawPathForPlayer!.pendingUnit!.path = line;

    units.add(drawPathForPlayer!.pendingUnit!);

    drawPathForPlayer!.pendingUnit = null;
    drawPathForPlayer!.nextUnitCooldown = 5.0;

    drawPathForPlayer = null;
    canDrawPath = false;

    // TODO: force set draw Path for next player
  }

  double getDrawRemainingDistance() {
    return (drawDistanceMax - drawDistance) * 100 / drawDistanceMax;
  }

  void dispose() {
    stateSubject.close();
  }
}
