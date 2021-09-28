import 'package:castle_game/app_router.dart';
import 'package:castle_game/game/game.dart';
import 'package:castle_game/game/player.dart';
import 'package:castle_game/util/logger.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class JoinClient {
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
  }

  // TODO: lobby stream
  Subject<double> stateSubject = BehaviorSubject<double>();

  Game? _game;
  IO.Socket? socket;

  Game? get game => _game;

  void joinGame(String gameId) {
    _game = Game();

    _game!.id = gameId;

    Log.i(TAG, 'joinGame() game id: $gameId');

    connect();

    stateSubject.add(0.0);
  }

  void connect() {
    Log.i(TAG, 'connect()');

    socket = IO.io(
      'http://10.0.2.2:8001',
      IO.OptionBuilder().setTransports(["websocket"]).disableAutoConnect().build(),
    );

    socket!.onConnect((_) {
      print('socket!.onConnect: ${socket?.id}');
      socket!.emit('joinGame', _game?.id);
    });

    socket!.on('gameState', (gameState) {
      Log.i(TAG, 'gameState');
      Log.i(TAG, gameState);

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
    if (_game == null) return;
    // TODO: if no game, clear everything and go back to main menu?

    _game!.id = gameState['id'];

    _game!.players.clear();

    (gameState['players'] as List).forEach((player) {
      _game!.players.add(
        Player(
          player['name'],
          player['ready'],
          Colors.orange,
          // Offset(size.width / 2, size.height - 10),
          // TODO: use %, cast to Offset
          Offset(1, 1),
        ),
      );
    });

    if (gameState['playing'] != _game!.playing) {
      _game!.playing = gameState['playing'];
      if (_game!.playing) {
        AppRouter.instance.navTo(AppRouter.routeGame);
      }
    }

    stateSubject.add(0.0);

    _game!.setState();
  }

  void ready() {
    socket?.emit('ready');
  }

  void _dispose() {
    socket?.dispose();
    _game?.dispose();
    stateSubject.close();
    _instance = null;
  }
}
