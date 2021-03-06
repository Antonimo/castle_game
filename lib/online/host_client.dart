import 'package:castle_game/app_consts.dart';
import 'package:castle_game/app_router.dart';
import 'package:castle_game/game/base.dart';
import 'package:castle_game/game/drawn_line.dart';
import 'package:castle_game/game/game.dart';
import 'package:castle_game/game/game_client.dart';
import 'package:castle_game/game/game_consts.dart';
import 'package:castle_game/game/player.dart';
import 'package:castle_game/game/unit.dart';
import 'package:castle_game/online/online_player.dart';
import 'package:castle_game/util/json_size.dart';
import 'package:castle_game/util/logger.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class HostClient implements GameClient {
  static const String TAG = '[HostClient] ';

  HostClient._privateConstructor();

  static HostClient? _instance;

  static HostClient? get instance => _instance;

  static void init() {
    // create client singleton
    _instance = HostClient._privateConstructor();

    _instance!.createGame();
  }

  static void dispose() {
    Log.i(TAG, 'dispose()');
    _instance!._dispose();
    _instance = null;
  }

  Subject<double> stateSubject = BehaviorSubject<double>();

  Game? _game;
  IO.Socket? socket;

  List<OnlinePlayer> players = [];

  Game? get game => _game;

  void createGame() {
    _game = Game();
    _game!.player = 'p1'; // TODO: players ids system
    connect();
  }

  void connect() {
    Log.i(TAG, 'connect()');

    socket = IO.io(
      AppConsts.SRV_URL,
      IO.OptionBuilder().setTransports(["websocket"]).disableAutoConnect().build(),
    );

    socket!.onConnect((_) {
      print('socket!.onConnect: ${socket?.id}');
      socket!.emit('createGame');
    });

    socket!.on('gameState', (gameState) {
      // Log.i(TAG, 'gameState');
      // Log.i(TAG, gameState);

      setGameState(gameState);
    });

    socket!.on('attachPathToPendingUnit', (data) {
      attachPathToPendingUnit(data);
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

  // TODO: gameState interface
  void setGameState(dynamic gameState) {
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

    if (gameState['playing'] != _game!.playing) {
      _game!.playing = gameState['playing'];
      if (_game!.playing) {
        AppRouter.instance.navTo(AppRouter.routeGame, arguments: {'gameClient': this});
        initPlayingGameStateBroadcastLoop();
      }
    }

    stateSubject.add(0.0);
    _game!.setState();
  }

  void ready() {
    socket?.emit('ready');
  }

  void initGame(Size size) {
    _game?.init(size);
    _game?.initObjects();
  }

  Future<void> initPlayingGameStateBroadcastLoop() async {
    while (_game != null && _game!.playing) {
      await Future.delayed(Duration(milliseconds: 1000 ~/ GameConsts.PLAYING_GAME_STATE_EMITS_PER_SECOND));

      Log.i(TAG, 'initPlayingGameStateBroadcastLoop() current game id: ${_game!.id} ');

      socket?.emit('playingGameState', buildPlayingGameState());
    }
  }

  Map buildPlayingGameState() {
    Map playingGameState = {
      'size': _game!.size?.toJson(),
      'id': _game!.id,
      'players': [],
      'bases': [],
      'units': [],
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

    return playingGameState;
  }

  void attachPathToPendingUnit(dynamic data) {
    if (_game == null) return;
    final _data = data as Map;
    final _player = _game!.players.firstWhere((Player player) => player.id == _data['player']);
    if (_player.pendingUnit == null) return;
    _game!.givePathToUnit(
      DrawnLine.fromPlayState(_data['path'])!,
      _player,
    );
  }

  void givePathToUnit(DrawnLine line, Player player) {
    if (_game == null) return;

    _game!.givePathToUnit(line, player);

    _game!.drawPathForPlayer = null;
    _game!.canDrawPath = false;
  }

  void _dispose() {
    socket?.dispose();
    socket = null;
    _game?.dispose();
    _game = null;
    stateSubject.close();
  }
}
