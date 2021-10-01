import 'package:castle_game/app_consts.dart';
import 'package:castle_game/app_router.dart';
import 'package:castle_game/game/base.dart';
import 'package:castle_game/game/drawn_line.dart';
import 'package:castle_game/game/game.dart';
import 'package:castle_game/game/game_client.dart';
import 'package:castle_game/game/player.dart';
import 'package:castle_game/game/unit.dart';
import 'package:castle_game/util/logger.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'online_player.dart';

// TODO: another game - bug?
class JoinClient extends GameClient {
  static const String TAG = '[JoinClient] ';

  JoinClient._privateConstructor();

  static JoinClient? _instance;

  static JoinClient? get instance => _instance;

  static void init() {
    // create client singleton
    _instance = JoinClient._privateConstructor();
  }

  static void join(String gameId) {
    _instance!.joinGame(gameId);
  }

  static void dispose() {
    _instance!._dispose();
    _instance = null;
  }

  Subject<double> stateSubject = BehaviorSubject<double>();

  Game? _game;
  IO.Socket? socket;

  List<OnlinePlayer> players = [];

  Game? get game => _game;

  int lastPlayingGameStateTime = 0;

  void joinGame(String gameId) {
    _game = Game();

    _game!.id = gameId;

    _game!.player = 'p2';

    Log.i(TAG, 'joinGame() game id: $gameId');

    connect();

    stateSubject.add(0.0);
  }

  void connect() {
    Log.i(TAG, 'connect()');

    socket = IO.io(
      AppConsts.SRV_URL,
      IO.OptionBuilder().setTransports(["websocket"]).disableAutoConnect().build(),
    );

    socket!.onConnect((_) {
      print('socket!.onConnect: ${socket?.id}');
      print('emit( joinGame, ${_game?.id} )');

      socket!.emit('joinGame', _game?.id);
    });

    socket!.on('gameState', (gameState) {
      Log.i(TAG, 'gameState');
      // Log.d(TAG, gameState);

      setGameState(gameState);
    });

    socket!.onDisconnect((_) {
      print('socket!.onDisconnect');
    });

    // Handle Errors
    socket!.on('connecting', (data) {
      print('connecting');
      print(data);
    });
    socket!.on('connect_error', (data) {
      print('connect_error');
      print(data);
    });
    socket!.on('connect_timeout', (data) {
      print('connect_timeout');
      print(data);
    });
    socket!.on('error', (data) {
      print('error');
      print(data);
    });
    socket!.on('reconnect', (data) {
      print('reconnect');
      print(data);
    });
    socket!.on('reconnect_attempt', (data) {
      print('reconnect_attempt');
      print(data);
    });
    socket!.on('reconnect_failed', (data) {
      print('reconnect_failed');
      print(data);
    });
    socket!.on('reconnect_error', (data) {
      print('reconnect_error');
      print(data);
    });
    socket!.on('reconnecting', (data) {
      print('reconnecting');
      print(data);
    });
    socket!.on('ping', (data) {
      print('ping');
      print(data);
    });
    socket!.on('pong', (data) {
      print('pong');
      print(data);
    });

    socket!.connect();
  }

  // TODO: add 'game does not exist' error
  // TODO: gameState interface
  void setGameState(dynamic gameState) {
    // Log.i(TAG, 'setGameState()');

    if (_game == null) return;
    // TODO: if no game, clear everything and go back to main menu?

    Log.i(TAG, 'setGameState() current game id: ${_game!.id}  gameState: ${gameState['id']}');

    if (_game!.id == null) {
      _game!.id = gameState['id'];
    }

    players.clear();

    (gameState['players'] as List).forEach((player) {
      players.add(
        OnlinePlayer(
          player['name'],
          player['ready'],
        ),
      );
    });

    // Log.i(TAG, 'gameState[playing]: ${gameState['playing']}');
    // Log.i(TAG, '_game!.playing: ${_game!.playing}');

    if (gameState['playing'] != _game!.playing) {
      _game!.playing = gameState['playing'];
      if (_game!.playing) {
        _game!.resetGame();
        AppRouter.instance.navTo(AppRouter.routeGame, arguments: {'gameClient': this});
      }

      // TODO: show game over here?
    }

    if (!_game!.playing) {
      stateSubject.add(0.0);
    } else {
      applyPlayingGameState(gameState);
    }

    _game!.setState();
  }

  void ready() {
    socket?.emit('ready');
  }

  void initGame(Size size) {
    _game?.init(
      size,
      onChange: () {}, // joined client does not send game state
      getNextPlayerWithPendingUnit: getNextPlayerWithPendingUnit, // joined client does not send game state
      onGameOver: onGameOver,
    );
  }

  Player? getNextPlayerWithPendingUnit(List<Player> players) {
    return players.firstWhereOrNull((_player) => (_player.id == _game!.player && _player.pendingUnit != null));
  }

  void applyPlayingGameState(dynamic gameState) {
    // Log.i(TAG, 'applyPlayingGameState() gameState == null: ${gameState == null}');

    if (gameState == null || gameState['playingState'] == null) return;

    // Log.d(TAG, gameState);

    // Log.i(TAG, 'applyPlayingGameState() socket.id: ');

    if (gameState['playingState']['time'] == null) return;

    if (gameState['playingState']['time'] == lastPlayingGameStateTime) return;

    lastPlayingGameStateTime = gameState['playingState']['time'];

    // if (gameState['playingState']['size'] != null){
    //   _game?.hostSize = Size.zero.fromJson(gameState['playingState']['size']);
    // }

    // if (game?.hostSize != null && game?.size != null) {
    //   _game?.adjust = Size(
    //     game!.size!.width / game!.hostSize!.width,
    //     game!.size!.height / game!.hostSize!.height,
    //   );
    //   _game?.adjustBack = Size(
    //     game!.hostSize!.width / game!.size!.width,
    //     game!.hostSize!.height / game!.size!.height,
    //   );
    //   // print('adjust hostSize: ${game.hostSize} size: ${game.size} adjust: ${adjust}');
    // }

    List<Player> players = [];
    List<Base> bases = [];
    List<Unit> units = [];

    (gameState['playingState']['players'] as List).forEach((player) {
      players.add(Player.fromPlayState(
        player,
        flipCoords: Game.gameSize,
      ));
    });
    (gameState['playingState']['bases'] as List).forEach((base) {
      bases.add(Base.fromPlayState(
        base,
        flipCoords: Game.gameSize,
      ));
    });
    (gameState['playingState']['units'] as List).forEach((unit) {
      units.add(Unit.fromPlayState(
        unit,
        flipCoords: Game.gameSize,
      )!);
    });

    _game?.players = players;
    _game?.bases = bases;
    _game?.units = units;
  }

  void givePathToUnit(DrawnLine line, Player player) {
    socket?.emit('attachPathToPendingUnit', {
      'path': line.toPlayState(
        flip: Game.gameSize,
        // adjust: _game?.adjustBack,
      ),
      'player': player.id,
    });
  }

  void onGameOver() {
    // TODO: only when host sends game over
    showGameOver();
    // _game!.playing = false;
    _game!.running = false;
    _game!.gameOver = false;

    _game!.setState();
  }

  void _dispose() {
    socket?.dispose();
    socket = null;
    _game?.dispose();
    _game = null;
    stateSubject.close();
  }
}
