
import 'package:castle_game/util/json_offset.dart';
import 'package:flutter/material.dart';

class Base {
  String player;
  Offset pos;
  MaterialColor color;

  double maxHp = 300;
  double hp = 300;

  Base(this.player, this.pos, this.color);

  Map toPlayState() {
    return {
      'player': player,
      'pos': pos.toJson(),
      // 'color': color,
      'maxHp': maxHp,
      'hp': hp,
    };
  }

  static Base fromPlayState(playState, {Size? flipCoords}) {
    final base = Base(
      playState['player'],
      Offset.zero.fromJson(playState['pos']).flip(flipCoords),
      // TODO: colors
      Colors.orange,
    );
    base.maxHp = (playState['maxHp'] as num).toDouble();
    base.hp = (playState['hp'] as num).toDouble();
    return base;
  }

  void damage(double damage){
    hp -= damage;
  }
}