import 'package:castle_game/game/game.dart';
import 'package:castle_game/game/unit.dart';
import 'package:flutter/material.dart';

class Player {
  String name;
  bool ready;

  MaterialColor color;
  Offset startPos;

  double? nextUnitCooldown;
  Unit? pendingUnit;

  Player(
    this.name,
    this.ready,
    this.color,
    this.startPos,
  );

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
