import 'package:castle_game/game/animation/animation_engine.dart';
import 'package:castle_game/game/animation/unit_attack/unit_attack_animation.dart';
import 'package:castle_game/game/animation/unit_walk/unit_walk_animation.dart';
import 'package:castle_game/game/base.dart';
import 'package:castle_game/game/drawn_line.dart';
import 'package:castle_game/game/game.dart';
import 'package:castle_game/game/game_consts.dart';
import 'package:castle_game/game/sprite.dart';
import 'package:castle_game/util/json_offset.dart';
import 'package:flutter/material.dart';

class Unit {
  String player;
  Color color;
  Offset pos;
  DrawnLine? path;

  double facingDirection = 0;

  // TODO: base game type that has pos
  dynamic engagedTarget;

  AnimationEngine animation = AnimationEngine();

  double maxHp = GameConsts.UNIT_MAX_HP;
  double hp = GameConsts.UNIT_MAX_HP;

  bool alive = true;

  // TODO: relation to player

  double speed = GameConsts.UNIT_SPEED; // pixels per second // TODO: use %

  bool moving = false;
  double? cooldown;

  Unit(this.player, this.color, this.pos) {
    initDefaultAnimation();
    // todo: for player 1 facing up, player 2 facing down
  }

  void initDefaultAnimation() {
    animation.setAnimation(UnitWalkAnimation(this));
  }

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

    // if (player == 'p1') {
    //   AnimationEngine.debug = true;
    // } else {
    //   AnimationEngine.debug = false;
    // }
    animation.animate(dt);

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
      animation.setAnimation(UnitAttackAnimation(this));
      // TODO: calculate facing direction
      // this.facingDirection
    }

    checkForItems(game);

    if (moving && path != null && path!.path.isNotEmpty) {
      move(dt);
      animation.setAnimation(UnitWalkAnimation(this));
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
        engagedTarget = unit;
        attackUnit(unit);
        return true;
      }
    }

    // Opponent Base nearby?
    for (var base in game.bases) {
      if (base.player == player) continue;
      if ((pos - base.pos).distance < GameConsts.UNIT_ENGAGE_BASE_DISTANCE) {
        engagedTarget = base;
        attackBase(base);
        return true;
      }
    }

    engagedTarget = null;
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

      this.facingDirection = diffOffset.direction;

      // print('distanceToPoint: $distanceToPoint remaining distance: $distance');

      if (distance <= distanceToPoint) {
        // print('distance <= distanceToPoint !!');

        pos = pos + Offset.fromDirection(this.facingDirection, distance);

        return;
      }

      distance -= distanceToPoint;

      pos = path!.path.first;

      path!.path.removeAt(0);
    }
  }

  void updateSpeed(double speedBonus) {
    speed += speedBonus;
  }

  void draw(Canvas canvas, List<Sprite> sprites, Size? adjust) {
    Offset drawPos = pos + animation.animationOffset;
    drawUnitAnimationState(canvas, sprites, drawPos, adjust);
    drawHP(canvas, drawPos, adjust);
    // drawDebug(canvas, pos, adjust);
  }

  void drawHP(Canvas canvas, Offset drawPos, Size? adjust) {
    Paint hpPaint = Paint()
      ..color = Color(0xff04fd08).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // print('hp angle: ${base.hp * 360 / base.maxHp}  radians: ${base.hp * 360 / base.maxHp * pi / 180}');

    final hpRect = Rect.fromCenter(
      center: drawPos.translate(0.0, -1 -GameConsts.UNIT_SIZE * (adjust?.shortestSide ?? 1)).adjust(adjust),
      width: GameConsts.UNIT_SIZE * 1.6 * (adjust?.shortestSide ?? 1),
      height: 2 * (adjust?.shortestSide ?? 1),
    );

    canvas.drawRect(
      Rect.fromLTRB(hpRect.left, hpRect.top, hpRect.left + hpRect.width * (this.hp / this.maxHp) , hpRect.bottom),
      hpPaint,
    );

    // canvas.drawArc(
    //   Rect.fromCircle(
    //     center: drawPos.adjust(adjust),
    //     radius: GameConsts.UNIT_SIZE * (adjust?.shortestSide ?? 1), // TODO: DRY
    //   ), // TODO: adjusted
    //   -90 * pi / 180,
    //   -this.hp * 360 / this.maxHp * pi / 180,
    //   true,
    //   hpPaint,
    // );
  }

  void drawUnitAnimationState(Canvas canvas, List<Sprite> sprites, Offset drawPos, Size? adjust) {
    // Border
    Paint unitPaint = Paint()
      ..color = this.color
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = 1.0 * (adjust?.shortestSide ?? 1);

    // canvas.drawCircle(
    //   drawPos.adjust(adjust),
    //   GameConsts.UNIT_SIZE * (adjust?.shortestSide ?? 1),
    //   unitPaint,
    // );

    Paint unitSpritePaint = Paint();

    sprites[animation.currentSprite].draw(canvas, drawPos.adjust(adjust), unitSpritePaint);
  }

  void drawDebug(Canvas canvas, Offset drawPos, Size? adjust) {
    // Border
    Paint unitPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill
      ..isAntiAlias = false
      ..strokeWidth = 2.5 * (adjust?.shortestSide ?? 1);

    canvas.drawCircle(
      drawPos.adjust(adjust),
      (adjust?.shortestSide ?? 1),
      unitPaint,
    );
  }
}
