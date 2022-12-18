import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:castle_game/game/numbers.dart';
import 'package:image/image.dart' as image;
import 'package:castle_game/game/load_assets.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

import 'package:castle_game/game/base.dart';
import 'package:castle_game/game/drawn_line.dart';
import 'package:castle_game/game/game_consts.dart';
import 'package:castle_game/game/item.dart';
import 'package:castle_game/game/player.dart';
import 'package:castle_game/game/sprite.dart';
import 'package:castle_game/game/unit.dart';
import 'package:castle_game/util/typedef.dart';

class Game {
  static const String TAG = '[Game] ';

  Random random = Random();

  Subject<double> stateSubject = BehaviorSubject<double>();

  String? id;

  String? player; // the current game client player

  // We are in the game screen
  bool playing = false;

  // We are in the game screen and the game is running
  bool running = false;

  bool gameOver = false;

  Function onPlay = (double dt) {};

  Function onChange = noop;

  Function getNextPlayerWithPendingUnit = noop;

  Function onGameOver = noop;

  bool canDrawPath = false;

  double drawDistanceMax = GameConsts.DRAW_DISTANCE_MAX;
  double drawDistance = 0.0;

  // TODO: move this to LocalMultiplayerClient
  Player? drawPathForPlayer;

  DateTime lastTime = DateTime.now();

  bool queuedOnChange = false;

  static const gameSize = Size(360.0, 800.0);

  Size? size;

  // Size? hostSize;
  Size? adjust;
  Size? adjustBack;

  // Game play mechanics
  double nextPowerUpCooldown = GameConsts.NEXT_POWERUP_COOLDOWN;

  // Game play content
  List<Player> players = [];

  List<Base> bases = [];

  List<Unit> units = [];

  List<Item> items = [];

  // Game assets
  Map<String, List<Sprite>> assets = {};

  List<int> playerSpritesIndexes = [];

  void setState() {
    stateSubject.add(0.0);
  }

  void toggleGame() {
    running = !running;
    _runTheGame();
  }

  void runGame() {
    running = true;
    _runTheGame();
  }

  void stopGame() {
    running = false;
  }

  void init(
    Size size, {
    required Function onPlay,
    required Function onChange,
    required Function getNextPlayerWithPendingUnit,
    required Function onGameOver,
  }) {
    // TODO: use Log everywhere
    print('Game init: $size');

    this.onPlay = onPlay;

    this.onChange = onChange;

    this.getNextPlayerWithPendingUnit = getNextPlayerWithPendingUnit;

    this.onGameOver = onGameOver;

    updateSize(size);

    // TODO: make game map fit while maintaining aspect ratio

    canDrawPath = false;

    // Select random distinct sprite collection for each player
    playerSpritesIndexes = getTwoRandomDistinctNumbers();

    // TODO: load assets async? while showing loading animation?
    loadAssets(this).then((_) {
      // TODO: loading state?

      print('Loaded assets! ${assets}');

      // Toggle game only after _game?.initObjects ?
      toggleGame();
    });
  }

  void updateSize(Size size) {
    this.size = size;

    adjust = Size(
      size.width / gameSize.width,
      size.height / gameSize.height,
    );
    adjustBack = Size(
      gameSize.width / size.width,
      gameSize.height / size.height,
    );
  }

  void resetGame() {
    canDrawPath = false;

    players.clear();
    units.clear();
    bases.clear();
    items.clear();
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
        Offset(gameSize.width / 2, gameSize.height - GameConsts.UNIT_SIZE - 2),
        'unit${playerSpritesIndexes[0]}',
      ),
    );
    players.add(
      Player(
        'p2',
        'p2',
        Colors.purple,
        Offset(gameSize.width / 2, GameConsts.UNIT_SIZE + 2),
        'unit${playerSpritesIndexes[1]}',
      ),
    );

    players.forEach((player) {
      player.nextUnitCooldown = GameConsts.INITIAL_NEXT_UNIT_COOLDOWN;
    });

    players.first.nextUnitCooldown = 0;

    bases.add(
      Base(
        players[0].id,
        Offset(gameSize.width / 2, 85 * gameSize.height / 100),
        players[0].color,
        'castle1',
      ),
    );
    bases.add(
      Base(
        players[1].id,
        Offset(gameSize.width / 2, 15 * gameSize.height / 100),
        players[1].color,
        'castle2',
      ),
    );

    onChange();
  }

  Future<void> _runTheGame() async {
    if (running) {
      lastTime = DateTime.now();
    }
    while (running) {
      final DateTime now = DateTime.now();
      double dt = now.difference(lastTime).inMilliseconds / 1000.0;

      onPlay(dt);

      checkForPendingUnits();

      players.forEach((player) {
        player.play(dt, this);
      });

      units.forEach((unit) {
        unit.play(dt, this);
      });

      bases.forEach((base) {
        base.play(dt, this);
      });

      // Clear dead units
      units = units.where((unit) => unit.alive).toList();

      // Clear used items
      items = items.where((item) => item.active).toList();

      for (var base in bases) {
        if (base.hp <= 0) {
          // TODO: game over
          running = false;
          gameOver = true;
          onGameOver();
        }
      }

      if (queuedOnChange) {
        onChange();
        queuedOnChange = false;
      }

      lastTime = now;
      stateSubject.add(0);

      // TODO: (nice to have) optimize the delay time to "race" frames
      await Future.delayed(Duration(milliseconds: 1000 ~/ GameConsts.CALCULATIONS_PER_SECOND));
    }
  }

  void queueOnChange() {
    queuedOnChange = true;
  }

  void checkForPendingUnits() {
    final Player? _player = getNextPlayerWithPendingUnit(players);

    if (_player != null) {
      canDrawPath = true;
      drawPathForPlayer = _player;
    } else {
      canDrawPath = false;
      drawPathForPlayer = null;
    }
  }

  Unit createPendingUnit(Player player) {
    // TODO: setState system?
    queueOnChange();

    final unit = Unit(
      player.id,
      player.color,
      player.startPos,
      player.unitsSpritesCollectionName,
    );

    unit.speed = player.unitSpeed;

    return unit;
  }

  // TODO: emit on change on remove units and items
  void removeUnit(Unit unit) {
    units.remove(unit);
    queueOnChange();
  }

  // TODO: pending unit should not be with all units, opponent could've added units also.

  List<Offset> fillPath(Offset start, Offset end, double step) {
    Offset current = start;

    List<Offset> path = [
      current,
    ];

    int steps = 100;

    double direction = (end - start).direction;
    final stepOffset = Offset.fromDirection(direction, step);

    while (current != end && steps > 0) {
      steps--;

      if ((current - end).distance < step) {
        current = end;
      } else {
        current += stepOffset;
      }

      path.add(current);
    }

    return path;
  }

  void givePathToUnit(DrawnLine line, Player player) {
    // if (drawPathForPlayer == null || canDrawPath == null) return;

    player.pendingUnit!.path = line;
    units.add(player.pendingUnit!);
    player.pendingUnit = null;
    player.nextUnitCooldown = GameConsts.NEXT_UNIT_COOLDOWN;

    queueOnChange();
  }

  void playPowerUps(double dt) {
    // print('playPowerUps() dt: $dt | nextPowerUpCooldown: $nextPowerUpCooldown');

    nextPowerUpCooldown = nextPowerUpCooldown - dt;

    if (nextPowerUpCooldown <= 0.0) {
      nextPowerUpCooldown = GameConsts.NEXT_POWERUP_COOLDOWN;
      addPowerUp();
    }
  }

  // TODO: move to game client base?
  void addPowerUp() {
    // TODO: randomize powerups?
    final nextPowerUpType = getChancePowerUp();

    // TODO: find free spot
    Offset pos = getRandomPos(
      0,
      gameSize.width,
      30 * gameSize.height / 100,
      70 * gameSize.height / 100,
    );

    items.add(
      Item(
        pos,
        nextPowerUpType,
      ),
    );

    queueOnChange();
  }

  double getDrawRemainingDistance() {
    return (drawDistanceMax - drawDistance) * 100 / drawDistanceMax;
  }

  ItemType getChancePowerUp() {
    final score = random.nextDouble();

    if (score < 0.2) {
      return ItemType.baseTrap;
    }
    if (score < 0.6) {
      return ItemType.healBase;
    }

    return ItemType.unitsSpeed;
  }

  Offset getRandomPos(double startX, double endX, double startY, double endY) {
    return Offset(
      random.nextDouble() * (endX - startX + 1) + startX,
      random.nextDouble() * (endY - startY + 1) + startY,
    );
  }

  void dispose() {
    stateSubject.close();
  }
}
