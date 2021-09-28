
import 'package:castle_game/game/player.dart';
import 'package:flutter/material.dart';

class Base {
  Player player;
  Offset pos;
  double maxHp = 300;
  double hp = 300;
  MaterialColor color;

  Base(this.player, this.pos, this.color);

  void damage(double damage){
    hp -= damage;
  }
}