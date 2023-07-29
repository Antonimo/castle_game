import 'dart:convert';

import 'package:castle_game/app_router.dart';
import 'package:castle_game/game/base.dart';
import 'package:castle_game/game/drawn_line.dart';
import 'package:castle_game/game/game.dart';
import 'package:castle_game/game/game_client.dart';
import 'package:castle_game/game/game_consts.dart';
import 'package:castle_game/game/item.dart';
import 'package:castle_game/game/player.dart';
import 'package:castle_game/game/unit.dart';
import 'package:castle_game/util/logger.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MultiplayerClient extends GameClient {
  static const String TAG = '[MultiplayerClient] ';

  MultiplayerClient._privateConstructor();

  static MultiplayerClient? _instance;

  static MultiplayerClient? get instance => _instance;

  static void init() {
    print('MultiplayerClient static init()');
    // create the client singleton
    _instance = MultiplayerClient._privateConstructor();
  }

  static void startGame() {
    _instance!._startGame();
  }

  static void dispose() {
    print('MultiplayerClient static dispose()');
    if (_instance == null) return;
    _instance!._dispose();
    _instance = null;
  }

  Subject<double> stateSubject = BehaviorSubject<double>();

  Game? _game;

  // List<OnlinePlayer> players = [];

  Game? get game => _game;

  void _startGame() {
    Log.i(TAG, 'startGame()');

    _game = Game();

    stateSubject.add(0.0);

    // AppRouter.instance.navTo(AppRouter.routeGame, arguments: {'gameClient': this});

    // TODO: refactor
    GoRouter.of(AppRouter.appNavigatorKey.currentContext!).push('/game', extra: {'gameClient': this});
  }

  void initGame(Size size) {
    // TODO: initObjects also resets game..
    _game?.resetGame();
    _game?.init(
      size,
      onPlay: onPlay,
      onChange: () {}, // joined client does not send game state
      getNextPlayerWithPendingUnit: getNextPlayerWithPendingUnit,
      onGameOver: onGameOver,
    );
    _game?.initObjects();

    // loadState();
  }

  void onPlay(double dt) {
    _game?.playPowerUps(dt);
  }

  Player? getNextPlayerWithPendingUnit(List<Player> players) {
    // TODO: fix gameClient cleanup: every _game! is a bug!
    // TODO: the dispose should wait for the game loop to finish before removing the game instance.
    if (_game!.drawPathForPlayer != null) return _game!.drawPathForPlayer;
    return players.firstWhereOrNull((player) => player.pendingUnit != null);
  }

  void onTap(Offset point) {
    final base = _game!.bases.firstWhereOrNull((Base base) => (base.pos - point).distance < GameConsts.BASE_SIZE);

    if (base != null && base.hasTrap) {
      base.activateTrap();
      return;
    }
  }

  void givePathToUnit(DrawnLine line, Player player) {
    if (_game == null) return;

    _game!.givePathToUnit(line, player);

    _game!.drawPathForPlayer = null;
    _game!.canDrawPath = false;
  }

  void onGameOver() {
    showGameOver();
    // _game!.playing = false;
    _game!.running = false;
    _game!.gameOver = false;

    _game!.setState();
  }

  void _dispose() {
    print('Multiplayer Client dispose()');
    _game?.dispose();
    _game = null;
    stateSubject.close();
  }

  void saveState() {
    print('saveState()');

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('gameState', json.encode(buildPlayingGameState()));
    });
  }

  Map buildPlayingGameState() {
    Map playingGameState = {
      // 'size': _game!.size?.toJson(),
      'id': _game!.id,
      // TODO: use relative game time, how much time elapsed
      'time': DateTime.now().millisecondsSinceEpoch,
      'players': [],
      'bases': [],
      'units': [],
      'items': [],
    };

    _game!.players.forEach((Player player) {
      playingGameState['players'].add(player.toPlayState());
    });
    _game!.bases.forEach((Base base) {
      playingGameState['bases'].add(base.toPlayState());
    });
    _game!.units.forEach((Unit unit) {
      playingGameState['units'].add(unit.toPlayState());
    });
    _game!.items.forEach((Item item) {
      playingGameState['items'].add(item.toPlayState());
    });

    return playingGameState;
  }

  void loadState() {
    SharedPreferences.getInstance().then((prefs) {
      String? encodedMap = prefs.getString('gameState');
      if (encodedMap == null) return;
      Map<String, dynamic> decodedMap = json.decode(encodedMap);
      setGameState(decodedMap);
    });
  }

  // TODO: DRY with join_client
  void setGameState(dynamic gameState) {
    Log.i(TAG, 'applyPlayingGameState() gameState == null: ${gameState == null}');

    // if (gameState == null || gameState['playingState'] == null) return;

    // Log.d(TAG, gameState);

    // Log.i(TAG, 'applyPlayingGameState() socket.id: ');

    // if (gameState['playingState']['time'] == null) return;

    List<Player> players = [];
    List<Base> bases = [];
    List<Unit> units = [];
    List<Item> items = [];

    (gameState['players'] as List).forEach((player) {
      players.add(Player.fromPlayState(
        player,
        flipCoords: Game.gameSize,
      ));
    });
    (gameState['bases'] as List).forEach((base) {
      bases.add(Base.fromPlayState(
        base,
        flipCoords: Game.gameSize,
      ));
    });
    (gameState['units'] as List).forEach((unit) {
      units.add(Unit.fromPlayState(
        unit,
        flipCoords: Game.gameSize,
      )!);
    });
    (gameState['items'] as List).forEach((item) {
      items.add(Item.fromPlayState(
        item,
        flipCoords: Game.gameSize,
      ));
    });

    _game?.players = players;
    _game?.bases = bases;
    _game?.units = units;
    _game?.items = items;
  }
}
