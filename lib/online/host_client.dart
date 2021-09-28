import 'package:castle_game/game/game.dart';
import 'package:castle_game/game/player.dart';
import 'package:castle_game/util/logger.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class HostClient {
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
    _instance!._dispose();
  }

  Game? _game;
  IO.Socket? socket;

  Game? get game => _game;

  void createGame() {
    _game = Game();
    connect();
  }

  void connect() {
    Log.i(TAG, 'connect()');

    socket = IO.io(
      'http://10.0.2.2:8001',
      IO.OptionBuilder().setTransports(["websocket"]).disableAutoConnect().build(),
    );

    socket!.onConnect((_) {
      print('socket!.onConnect: ${socket?.id}');
      socket!.emit('createGame');
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

    _game!.setState();
  }

  void ready() {
    socket?.emit('ready');
  }

  void _dispose() {
    socket?.dispose();
    _game?.dispose();
    _instance = null;
  }
}
