import 'package:castle_game/game/game.dart';
import 'package:flutter/material.dart';

abstract class GameClient {
  Game? get game;

  void initGame(Size size);
}