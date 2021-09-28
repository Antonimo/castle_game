import 'package:castle_game/game/drawn_line.dart';
import 'package:castle_game/game/game.dart';
import 'package:castle_game/game/player.dart';
import 'package:flutter/material.dart';

abstract class GameClient {
  Game? get game;

  void initGame(Size size);

  void givePathToUnit(DrawnLine line, Player player);
}