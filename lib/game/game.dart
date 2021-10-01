import 'dart:async';
import 'dart:ui';

import 'package:castle_game/game/base.dart';
import 'package:castle_game/game/drawn_line.dart';
import 'package:castle_game/game/game_consts.dart';
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

  bool gameOver = false;

  Function? onChange;

  Function? onGameOver;

  bool canDrawPath = false;

  double drawDistanceMax = GameConsts.DRAW_DISTANCE_MAX;
  double drawDistance = 0.0;

  // TODO: move this to LocalMultiplayerClient
  Player? drawPathForPlayer;

  DateTime lastTime = DateTime.now();

  bool queuedOnChange = false;

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

  void init(
    Size size, {
    required Function onChange,
    required Function onGameOver,
  }) {
    // TODO: use Log everywhere
    print('Game init: $size');

    this.size = size;

    this.onChange = onChange;

    this.onGameOver = onGameOver;

    canDrawPath = false;

    toggleGame();
  }

  void resetGame() {
    canDrawPath = false;

    players.clear();
    units.clear();
    bases.clear();
  }

  void initObjects() {
    resetGame();

    players.add(
      // TODO: attach connected players ids?
      Player(
        'p1',
        'p1',
        Colors.orange,
        // TODO: use %, cast to Offset
        Offset(size!.width / 2, size!.height - 10),
      ),
    );
    players.add(
      Player(
        'p2',
        'p2',
        Colors.purple,
        Offset(size!.width / 2, 10),
      ),
    );

    players.forEach((player) {
      player.nextUnitCooldown = GameConsts.INITIAL_NEXT_UNIT_COOLDOWN;
    });

    bases.add(
      Base(
        players[0].id,
        Offset(size!.width / 2, 85 * size!.height / 100),
        players[0].color,
      ),
    );
    bases.add(
      Base(
        players[1].id,
        Offset(size!.width / 2, 15 * size!.height / 100),
        players[1].color,
      ),
    );

    onChange!();
  }

  Future<void> _runTheGame() async {
    if (running) {
      lastTime = DateTime.now();
    }
    while (running) {
      // TODO: (nice to have) optimize the delay time to "race" frames
      await Future.delayed(Duration(milliseconds: 1000 ~/ GameConsts.CALCULATIONS_PER_SECOND));

      final DateTime now = DateTime.now();
      double dt = now.difference(lastTime).inMilliseconds / 1000.0;

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
          gameOver = true;
          onGameOver!();
        }
      }

      if (queuedOnChange) {
        onChange!();
        queuedOnChange = false;
      }

      lastTime = now;
      stateSubject.add(0);
    }
  }

  void queueOnChange() {
    queuedOnChange = true;
  }

  void checkForPendingUnits() {
    // final Player? player = players.firstWhereOrNull((player) => player.pendingUnit != null);
    //
    // if (player != null) {
    //   canDrawPath = true;
    //   drawPathForPlayer = player;
    // }

    // fetch my player
    if (players.isNotEmpty) {
      final myPlayer = players.firstWhere((_player) => _player.id == player);
      if (myPlayer.pendingUnit != null) {
        canDrawPath = true;
        drawPathForPlayer = myPlayer;
      } else {
        canDrawPath = false;
        drawPathForPlayer = null;
      }
    }
  }

  Unit createPendingUnit(Player player) {
    // TODO: setState system?
    queueOnChange();

    return Unit(
      player.id,
      player.color,
      player.startPos,
    );
  }

  void removeUnit(Unit unit) {
    units.remove(unit);
    queueOnChange();
  }

  // TODO: pending unit should not be with all units, opponent could've added units also.

  void givePathToUnit(DrawnLine line, Player player) {
    // if (drawPathForPlayer == null || canDrawPath == null) return;

    player.pendingUnit!.path = line;
    units.add(player.pendingUnit!);
    player.pendingUnit = null;
    player.nextUnitCooldown = GameConsts.NEXT_UNIT_COOLDOWN;

    queueOnChange();
  }

  double getDrawRemainingDistance() {
    return (drawDistanceMax - drawDistance) * 100 / drawDistanceMax;
  }

  void dispose() {
    stateSubject.close();
  }
}
