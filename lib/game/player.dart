import 'package:castle_game/game/game.dart';
import 'package:castle_game/game/unit.dart';
import 'package:castle_game/util/json_offset.dart';
import 'package:flutter/material.dart';

class Player {
  String id;
  String name;

  MaterialColor color;
  Offset startPos;

  double? nextUnitCooldown;
  Unit? pendingUnit;

  Player(
    this.id,
    this.name,
    this.color,
    this.startPos,
  );

  Map toPlayState() {
    return {
      'id': id,
      'name': name,
      'startPos': startPos.toJson(),
      'nextUnitCooldown': nextUnitCooldown,
      'pendingUnit': pendingUnit?.toPlayState(),
    };
  }

  static Player fromPlayState(playState, {Size? flipCoords}) {
    final player = Player(
      playState['id'],
      playState['name'],
      // TODO: colors,
      Colors.orange,
      // TODO: startpos
      Offset.zero.fromJson(playState['startPos']).flip(flipCoords),
    );
    if (playState['nextUnitCooldown'] != null) {
      player.nextUnitCooldown = (playState['nextUnitCooldown'] as num).toDouble();
    }
    if (playState['pendingUnit'] != null) {
      player.pendingUnit = Unit.fromPlayState(playState['pendingUnit'], flipCoords: flipCoords);
    }
    return player;
  }

  void play(double dt, Game game) {
    if (nextUnitCooldown != null) {
      nextUnitCooldown = nextUnitCooldown! - dt;

      if (nextUnitCooldown! < 0.0) {
        nextUnitCooldown = null;
        pendingUnit = game.createPendingUnit(this);
      }
    }
  }
}
