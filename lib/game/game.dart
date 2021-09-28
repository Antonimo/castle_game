import 'dart:async';
import 'dart:ui';

import 'package:castle_game/app_router.dart';
import 'package:castle_game/game/base.dart';
import 'package:castle_game/game/drawn_line.dart';
import 'package:castle_game/game/player.dart';
import 'package:castle_game/game/unit.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

class Game {
  Subject<double> stateSubject = BehaviorSubject<double>();

  String? id;

  String? player; // the current game client player

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

  Size? size;
  Size? hostSize;
  Size? adjust;
  Size? adjustBack;

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

    this.size = size;

    // players.clear();
    // units.clear();
    // bases.clear();

    canDrawPath = false;

    players.add(
      Player(
        'p1',
        'p1',
        Colors.orange,
        // TODO: use %, cast to Offset
        Offset(size.width / 2, size.height - 10), // TODO: to consts
      ),
    );
    players.add(
      Player(
        'p2',
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
        players[0].id,
        Offset(size.width / 2, 85 * size.height / 100),
        players[0].color,
      ),
    );
    bases.add(
      Base(
        players[1].id,
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

      checkForPendingUnits();

      players.forEach((player) {
        player.play(dt, this);
      });

      units.forEach((unit) {
        unit.play(dt, this);
      });

      // Clear dead units
      units = units.where((unit) => unit.alive).toList();

      for (var base in bases) {
        if (base.hp <= 0) {
          // TODO: game over
          running = false;
        }
      }

      lastTime = now;
      stateSubject.add(0);
    }
    showGameOver();
  }

  void checkForPendingUnits() {
    // final Player? player = players.firstWhereOrNull((player) => player.pendingUnit != null);
    //
    // if (player != null) {
    //   canDrawPath = true;
    //   drawPathForPlayer = player;
    // }

    // fetch my player
    final myPlayer = players.firstWhere((_player) => _player.id == player);
    if (myPlayer.pendingUnit != null) {
      canDrawPath = true;
      drawPathForPlayer = myPlayer;
    } else {
      canDrawPath = false;
      drawPathForPlayer = null;
    }
  }

  Unit createPendingUnit(Player player) {
    return Unit(
      player.id,
      player.color,
      player.startPos,
    );
  }

  void removeUnit(Unit unit) {
    units.remove(unit);
  }

  // TODO: pending unit should not be with all units, opponent could've added units also.

  void givePathToUnit(DrawnLine line, Player player) {
    // if (drawPathForPlayer == null || canDrawPath == null) return;

    player.pendingUnit!.path = line;
    units.add(player.pendingUnit!);
    player.pendingUnit = null;
    player.nextUnitCooldown = 5.0;
  }

  double getDrawRemainingDistance() {
    return (drawDistanceMax - drawDistance) * 100 / drawDistanceMax;
  }

  Future<void> showGameOver() async {
    return showDialog<void>(
      context: AppRouter.appNavigatorKey.currentContext!,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over!'),
          // content: SingleChildScrollView(
          //   child: ListBody(
          //     children: const <Widget>[
          //       Text('Would you like to approve of this message?'),
          //     ],
          //   ),
          // ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                AppRouter.instance.navTo(AppRouter.routeMenu);
              },
            ),
          ],
        );
      },
    );
  }

  void dispose() {
    stateSubject.close();
  }
}
