import 'package:castle_game/app_router.dart';
import 'package:castle_game/game/drawn_line.dart';
import 'package:castle_game/game/game.dart';
import 'package:castle_game/game/game_client.dart';
import 'package:castle_game/game/player.dart';
import 'package:castle_game/util/logger.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

class MultiplayerClient extends GameClient {
  static const String TAG = '[MultiplayerClient] ';

  MultiplayerClient._privateConstructor();

  static MultiplayerClient? _instance;

  static MultiplayerClient? get instance => _instance;

  static void init() {
    // create the client singleton
    _instance = MultiplayerClient._privateConstructor();
  }

  static void startGame() {
    _instance!._startGame();
  }

  static void dispose() {
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

    AppRouter.instance.navTo(AppRouter.routeGame, arguments: {'gameClient': this});
  }

  void initGame(Size size) {
    _game?.resetGame();
    _game?.init(
      size,
      onChange: () {}, // joined client does not send game state
      getNextPlayerWithPendingUnit: getNextPlayerWithPendingUnit,
      onGameOver: onGameOver,
    );
    _game?.initObjects();
  }

  Player? getNextPlayerWithPendingUnit(List<Player> players) {
    if (_game!.drawPathForPlayer != null) return _game!.drawPathForPlayer;
    return players.firstWhereOrNull((player) => player.pendingUnit != null);
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
    _game?.dispose();
    _game = null;
    stateSubject.close();
  }
}
