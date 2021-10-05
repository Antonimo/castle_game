import 'package:castle_game/game/game.dart';
import 'package:castle_game/game/player.dart';
import 'package:castle_game/game/unit.dart';
import 'package:castle_game/util/json_offset.dart';
import 'package:flutter/material.dart';

import 'base.dart';

class Item {
  Offset pos;
  ItemType type;
  bool active = true;

  Item(
    this.pos,
    this.type,
  );

  Map toPlayState() {
    return {
      'pos': pos.toJson(),
      'type': type.index,
    };
  }

  static Item fromPlayState(playState, {Size? flipCoords}) {
    return Item(
      Offset.zero.fromJson(playState['pos']).flip(flipCoords),
      ItemType.values[playState['type']],
    );
  }

  void collect(Unit unit, Game game) {
    if (!active) return;
    actionMap[type]!(unit, game);
    active = false;
    game.queueOnChange();
  }

  Map<ItemType, Function> actionMap = {
    ItemType.healBase: (Unit unit, Game game) {
      final base = game.bases.firstWhere((Base base) => base.player == unit.player);
      base.heal(50);
    },
    ItemType.unitsSpeed: (Unit unit, Game game) {
      final player = game.players.firstWhere((Player player) => player.id == unit.player);
      player.updateUnitSpeed(10); // TODO: how to properly set changes + queue updates?
      game.units.where((Unit unit) => unit.player == player.id).forEach((Unit unit) {
        unit.updateSpeed(10);
      });
    },
    ItemType.baseTrap: (Unit unit, Game game) {
      // final base = game.bases.firstWhere((Base base) => base.player == unit.player);
      // base.heal(50);
    },
  };

  static const Map<ItemType, IconData>icons = {
    ItemType.healBase: Icons.add,
    ItemType.unitsSpeed: Icons.fast_forward,
    ItemType.baseTrap: Icons.star,
  };
}

enum ItemType {
  healBase,
  unitsSpeed,
  baseTrap,
}
