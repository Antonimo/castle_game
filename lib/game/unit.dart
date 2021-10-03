import 'package:castle_game/game/base.dart';
import 'package:castle_game/game/drawn_line.dart';
import 'package:castle_game/game/game.dart';
import 'package:castle_game/game/game_consts.dart';
import 'package:castle_game/util/json_offset.dart';
import 'package:flutter/material.dart';

class Unit {
  String player;
  Color color;
  Offset pos;
  DrawnLine? path;

  double maxHp = GameConsts.UNIT_MAX_HP;
  double hp = GameConsts.UNIT_MAX_HP;

  bool alive = true;

  // TODO: relation to player

  double speed = GameConsts.UNIT_SPEED; // pixels per second // TODO: use %

  bool moving = false;
  double? cooldown;

  Unit(this.player, this.color, this.pos);

  Map toPlayState() {
    return {
      'player': player,
      'color': color.value,
      'pos': pos.toJson(),
      'path': path?.toPlayState(),
      'maxHp': maxHp,
      'hp': hp,
      'alive': alive,
      'speed': speed,
      'moving': moving,
      'cooldown': cooldown,
    };
  }

  static Unit? fromPlayState(playState, {Size? flipCoords}) {
    if (playState == null) return null;

    final unit = Unit(
      playState['player'],
      Color(playState['color']),
      Offset.zero.fromJson(playState['pos']).flip(flipCoords),
    );
    unit.path = DrawnLine.fromPlayState(playState['path'], flipCoords: flipCoords);
    unit.maxHp = double.parse(playState['maxHp'].toString());
    unit.hp = double.parse(playState['hp'].toString());
    unit.alive = playState['alive'];
    unit.speed = double.parse(playState['speed'].toString());
    unit.moving = playState['moving'];
    unit.cooldown = playState['cooldown'] == null ? null : double.parse(playState['cooldown'].toString());
    return unit;
  }

  void play(double dt, Game game) {
    if (!alive) return;

    if (cooldown != null) {
      cooldown = cooldown! - dt;
      if (cooldown! < 0) {
        cooldown = null;
      } else {
        return;
      }
    }

    moving = true;

    final engaged = engage(game);

    if (engaged) {
      cooldown = GameConsts.UNIT_ENGAGED_COOLDOWN;
      moving = false;
    }

    checkForItems(game);

    if (moving && path != null && path!.path.isNotEmpty) {
      move(dt);
    }
  }

  /// Check if enemies are close enough to engage.
  /// Attack the closest enemy.
  /// If no nearby enemies, check if can engage base
  bool engage(Game game) {
    // Opponent Units nearby?
    for (var unit in game.units) {
      if (unit.player == player) continue;
      if ((pos - unit.pos).distance < GameConsts.UNIT_ENGAGE_DISTANCE) {
        attackUnit(unit);
        return true;
      }
    }

    // Opponent Base nearby?
    for (var base in game.bases) {
      if (base.player == player) continue;
      if ((pos - base.pos).distance < GameConsts.UNIT_ENGAGE_BASE_DISTANCE) {
        attackBase(base);
        return true;
      }
    }

    return false;
  }

  void attackUnit(Unit unit) {
    unit.damage(5); // TODO: random, dmg range
  }

  void attackBase(Base base) {
    base.damage(5); // TODO: random, dmg range
  }

  void damage(double damage) {
    hp -= damage;

    if (hp <= 0) {
      kill();
    }
  }

  void kill() {
    alive = false;
  }

  void checkForItems(Game game) {
    for (var item in game.items) {
      if ((pos - item.pos).distance < (GameConsts.UNIT_SIZE + GameConsts.POWERUP_SIZE)) {
        item.collect(this, game);
      }
    }
  }

  void move(double dt) {
    if (path == null) return;

    if (path!.path.isEmpty) return;

    double distance = speed * dt;

    while (distance > 0) {
      if (path!.path.isEmpty) {
        break;
      }
      final Offset nextPoint = path!.path.first;

      final diffOffset = (nextPoint - pos);

      final double distanceToPoint = diffOffset.distance;

      // print('distanceToPoint: $distanceToPoint remaining distance: $distance');

      if (distance <= distanceToPoint) {
        // print('distance <= distanceToPoint !!');

        pos = pos + Offset.fromDirection(diffOffset.direction, distance);

        return;
      }

      distance -= distanceToPoint;

      pos = path!.path.first;

      path!.path.removeAt(0);
    }
  }
}
