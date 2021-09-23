import 'package:castle_game/base.dart';
import 'package:castle_game/drawn_line.dart';
import 'package:castle_game/game.dart';
import 'package:castle_game/player.dart';
import 'package:flutter/material.dart';

class Unit {
  Player player;
  MaterialColor color;
  Offset pos;
  DrawnLine? path;

  double maxHp = 60;
  double hp = 60;

  bool alive = true;

  // TODO: relation to player

  double speed = 40; // pixels per second // TODO: use %

  bool moving = false;
  double? cooldown;

  Unit(this.player, this.color, this.pos);

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
      cooldown = 3.0;
      moving = false;
    }

    if (moving && path != null && !path!.path.isEmpty) {
      move(dt);
    }
  }

  /// Check if enemies are close enough to engage.
  /// Attack the closest enemy.
  /// If no nearby enemies, check if can engage base
  bool engage(Game game) {
    // Oppinent Units nearby?
    for (var unit in game.units) {
      if (unit.player == player) continue;
      if ((pos - unit.pos).distance < 17) {
        // TODO: move to consts
        attackUnit(unit);
        return true;
      }
    }

    // Opponent Base nearby?
    for (var base in game.bases) {
      if (base.player == player) continue;
      if ((pos - base.pos).distance < 32) {
        // TODO: move to consts
        attackBase(base);
        return true;
      }
    }

    return false;
  }

  void attackUnit(Unit unit) {
    unit.damage(20); // TODO: random, dmg range
  }

  void attackBase(Base base) {
    base.damage(20); // TODO: random, dmg range
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
