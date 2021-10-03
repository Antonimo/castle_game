import 'package:castle_game/game/game_consts.dart';
import 'package:castle_game/util/json_offset.dart';
import 'package:flutter/material.dart';

class Base {
  String player;
  Offset pos;
  Color color;

  double maxHp = GameConsts.BASE_MAX_HP;
  double hp = GameConsts.BASE_MAX_HP;

  Base(this.player, this.pos, this.color);

  Map toPlayState() {
    return {
      'player': player,
      'pos': pos.toJson(),
      'color': color.value,
      'maxHp': maxHp,
      'hp': hp,
    };
  }

  static Base fromPlayState(playState, {Size? flipCoords}) {
    final base = Base(
      playState['player'],
      Offset.zero.fromJson(playState['pos']).flip(flipCoords),
      Color(playState['color']),
    );
    base.maxHp = (playState['maxHp'] as num).toDouble();
    base.hp = (playState['hp'] as num).toDouble();
    return base;
  }

  void damage(double damage) {
    hp -= damage;
  }

  void heal(double amount) {
    hp += amount;
  }
}
