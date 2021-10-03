import 'package:castle_game/game/game.dart';
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
  }

  Map<ItemType, Function> actionMap = {
    ItemType.healBase: (Unit unit, Game game) {
      final base = game.bases.firstWhere((Base base) => base.player == unit.player);
      base.heal(30);
    }
  };
}


enum ItemType {
  healBase,
}
