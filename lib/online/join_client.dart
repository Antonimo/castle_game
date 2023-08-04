import 'package:castle_game/app_consts.dart';
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
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'online_player.dart';

// TODO: another game - bug?
class JoinClient extends GameClient {
  static const String TAG = '[JoinClient] ';

  JoinClient._privateConstructor();

  static JoinClient? _instance;

  static JoinClient? get instance => _instance;

  static void init(String? inviteToken) {
    // create client singleton
    _instance = JoinClient._privateConstructor();

    _instance!.createGame();
    _instance!.inviteToken = inviteToken;
  }

  static void join(String gameId) {
    _instance!.joinGame(gameId);
  }

  static void dispose() {
    Log.i(TAG, 'dispose()');
    _instance!._dispose();
    _instance = null;
  }

  String? inviteToken;

  Subject<double> stateSubject = BehaviorSubject<double>();

  Game? _game;
  IO.Socket? socket;

  List<OnlinePlayer> players = [];

  Game? get game => _game;

  int lastPlayingGameStateTime = 0;

  void createGame() {
    _game = Game();
    _game!.player = 'p2'; // TODO: players ids system
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
      // TODO: emit player username?

      // print('emit( joinGame, ${_game?.id} )');

      // socket!.emit('joinGame', _game?.id);

      if (inviteToken != null) {
        acceptInvite(inviteToken!);
      }
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

  void joinGame(String gameId) {
    // TODO: fix joining
    return;
    Log.i(TAG, 'joinGame() game id: $gameId');

    // _game = Game();
    // _game!.id = gameId;

    _game!.player = 'p2';

    stateSubject.add(0.0);
  }

  void acceptInvite(String inviteToken) {
    Log.i(TAG, 'acceptInvite() inviteToken: $inviteToken');
    socket!.emit('acceptInvite', inviteToken);
  }

  // TODO: add 'game does not exist' error
  // TODO: gameState interface
  void setGameState(dynamic gameState) {
    // Log.i(TAG, 'setGameState()');

    if (_game == null) return;
    // TODO: if no game, clear everything and go back to main menu?

    Log.i(TAG, 'setGameState() current game id: ${_game!.id}  gameState: ${gameState['id']}');

    if (gameState['playingState'] != null) {
      if (gameState['playingState']['playerSpritesIndexes'] != null) {
        _game!.playerSpritesIndexes = gameState['playingState']['playerSpritesIndexes'].cast<int>();
      }
    }
    // TODO: if assets of playerSpritesIndexes are not loaded, load them now?

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
        // AppRouter.instance.navTo(AppRouter.routeGame, arguments: {'gameClient': this});

        GoRouter.of(AppRouter.appNavigatorKey.currentContext!).push('/game', extra: {'gameClient': this});
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
      onPlay: (double dt) {},
      onChange: () {}, // joined client does not send game state
      getNextPlayerWithPendingUnit: getNextPlayerWithPendingUnit, // joined client does not send game state
      onGameOver: onGameOver,
    );
  }

  Player? getNextPlayerWithPendingUnit(List<Player> players) {
    return players.firstWhereOrNull((_player) => (_player.id == _game!.player && _player.pendingUnit != null));
  }

  void onTap(Offset point) {
    final base = _game!.bases.firstWhereOrNull((Base base) => base.player == _game!.player && (base.pos - point).distance < GameConsts.BASE_SIZE);

    if (base != null && base.hasTrap) {
      base.activateTrap();
      emitActivateBaseTrap(base.player);
      return;
    }
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
    List<Item> items = [];

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
    (gameState['playingState']['items'] as List).forEach((item) {
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

  void givePathToUnit(DrawnLine line, Player player) {
    socket?.emit('attachPathToPendingUnit', {
      'path': line.toPlayState(
        flip: Game.gameSize,
        // adjust: _game?.adjustBack,
      ),
      'player': player.id,
    });
  }

  void emitActivateBaseTrap(String player) {
    socket?.emit('gameAction', {
      'player': player,
      'action': 'ActivateBaseTrap',
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
