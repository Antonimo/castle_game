import 'package:castle_game/game/game.dart';
import 'package:castle_game/game/game_consts.dart';
import 'package:castle_game/game/sprite.dart';
import 'package:castle_game/game/unit.dart';
import 'package:castle_game/util/json_offset.dart';
import 'package:flutter/material.dart';

class Base {
  String player;
  Offset pos;
  Color color;

  double maxHp = GameConsts.BASE_MAX_HP;
  double hp = GameConsts.BASE_MAX_HP;

  bool hasTrap = false;
  double? trapActiveCooldown;

  String spritesCollectionName;

  Base(
    this.player,
    this.pos,
    this.color,
    this.spritesCollectionName,
  );

  Map toPlayState() {
    return {
      'player': player,
      'pos': pos.toJson(),
      'color': color.value,
      'maxHp': maxHp,
      'hp': hp,
      'hasTrap': hasTrap,
      'trapActiveCooldown': trapActiveCooldown,
    };
  }

  static Base fromPlayState(playState, {Size? flipCoords}) {
    final base = Base(
      playState['player'],
      Offset.zero.fromJson(playState['pos']).flip(flipCoords),
      Color(playState['color']),
      // TODO: get sprite name
      'castle1'
    );
    base.maxHp = (playState['maxHp'] as num).toDouble();
    base.hp = (playState['hp'] as num).toDouble();
    base.hasTrap = playState['hasTrap'];
    if (playState['trapActiveCooldown'] != null) {
      base.trapActiveCooldown = (playState['trapActiveCooldown'] as num).toDouble();
    }
    return base;
  }

  void play(double dt, Game game) {
    if (trapActiveCooldown != null) {
      trapActiveCooldown = trapActiveCooldown! - dt;

      game.units.forEach((Unit unit) {
        if ((unit.pos - pos).distance < GameConsts.BASE_TRAP_DISTANCE) {
          unit.damage(24 * dt);
        }
      });

      if (trapActiveCooldown! <= 0.0) {
        trapActiveCooldown = null;
      }
    }
  }

  void damage(double damage) {
    hp -= damage;
  }

  void heal(double amount) {
    hp += amount;
  }

  void addTrap() {
    hasTrap = true;
  }

  void activateTrap() {
    hasTrap = false;
    trapActiveCooldown = 3.0;
  }

  void draw(Canvas canvas, List<Sprite> sprites, Size? adjust) {
    Offset drawPos = pos;
    drawCastleSprite(canvas, sprites, drawPos, adjust);
    drawHP(canvas, drawPos, adjust);
    drawTrap(canvas, drawPos, adjust);
  }

  void drawCastleSprite(Canvas canvas, List<Sprite> sprites, Offset drawPos, Size? adjust) {
    // Draw Base Sprite
    Paint castleSpritePaint = Paint();

    sprites[0].draw(canvas, drawPos.translate(0.0, -GameConsts.BASE_SIZE / 2).adjust(adjust), castleSpritePaint);

    // Paint unitPaint = Paint()
    //   ..color = this.color
    //   ..style = PaintingStyle.stroke
    //   ..isAntiAlias = true
    //   ..strokeWidth = 1.0 * (adjust?.shortestSide ?? 1);
    //
    // canvas.drawRect(
    //   Rect.fromCenter(center: drawPos.adjust(adjust), width: sprites[0].imageFrame.width.toDouble(), height: sprites[0].imageFrame.height.toDouble()),
    //   unitPaint,
    // );
  }

  void drawHP(Canvas canvas, Offset drawPos, Size? adjust) {
    Paint hpPaint = Paint()
      ..color = Color(0xff04fd08).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final hpRect = Rect.fromCenter(
      center: drawPos.translate(0.0, GameConsts.BASE_SIZE * 1.8 * (adjust?.shortestSide ?? 1)).adjust(adjust),
      width: GameConsts.BASE_SIZE * 2.5 * (adjust?.shortestSide ?? 1),
      height: 2 * (adjust?.shortestSide ?? 1),
    );

    canvas.drawRect(
      Rect.fromLTRB(hpRect.left, hpRect.top, hpRect.left + hpRect.width * (this.hp / this.maxHp), hpRect.bottom),
      hpPaint,
    );

    if (hp > maxHp) {
      // Paint hpPaint = Paint()
      //   ..color = Colors.purple.withOpacity(0.8)
      //   ..style = PaintingStyle.stroke
      //   ..style = PaintingStyle.fill
      //   ..strokeWidth = GameConsts.BASE_SIZE // TODO: adjusted
      //   ..isAntiAlias = true;
      //
      // final extraHp = maxHp - hp;
      //
      // canvas.drawArc(
      //   // TODO: adjust sizes of all elements too.
      //   Rect.fromCircle(
      //     center: pos,
      //     radius: GameConsts.BASE_SIZE * (adjust?.shortestSide ?? 1),
      //   ),
      //   -90 * pi / 180,
      //   -extraHp * 360 / maxHp * pi / 180,
      //   true,
      //   hpPaint,
      // );
    }
  }

  void drawTrap(Canvas canvas, Offset drawPos, Size? adjust) {
    final trapPos = drawPos.adjust(adjust);

    if (hasTrap) {
      final icon = Icons.star;
      final iconSize = GameConsts.BASE_SIZE * 1.5;
      TextPainter textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontFamily: icon.fontFamily,
          color: Colors.red,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, trapPos.translate(-iconSize / 2, -iconSize / 2));
    }

    // Trap Active
    if (trapActiveCooldown != null) {
      Paint trapPaint = Paint()
        ..color = Colors.red.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true
        ..strokeWidth = (trapActiveCooldown! * 6) * (adjust?.shortestSide ?? 1);

      canvas.drawCircle(
        trapPos,
        (GameConsts.BASE_SIZE + 16 - (trapActiveCooldown! * 6)) * (adjust?.shortestSide ?? 1), // TODO: DRY
        trapPaint,
      );
    }
  }

  void drawBase() {
    // final pos = base.pos.adjust(adjust);
    //
    // // HP
    // Paint hpPaint = Paint()
    //   ..color = Colors.redAccent.withOpacity(0.8)
    //   ..style = PaintingStyle.stroke
    //   ..style = PaintingStyle.fill
    //   ..strokeWidth = GameConsts.BASE_SIZE // TODO: adjusted
    //   ..isAntiAlias = true;
    //
    // // print('hp angle: ${base.hp * 360 / base.maxHp}  radians: ${base.hp * 360 / base.maxHp * pi / 180}');
    //
    // canvas.drawArc(
    //   // TODO: adjust sizes of all elements too.
    //   Rect.fromCircle(
    //     center: pos,
    //     radius: GameConsts.BASE_SIZE * (adjust?.shortestSide ?? 1),
    //   ),
    //   -90 * pi / 180,
    //   -base.hp * 360 / base.maxHp * pi / 180,
    //   true,
    //   hpPaint,
    // );

    // if (base.hp > base.maxHp) {
    //   // Extra HP
    //   Paint hpPaint = Paint()
    //     ..color = Colors.purple.withOpacity(0.8)
    //     ..style = PaintingStyle.stroke
    //     ..style = PaintingStyle.fill
    //     ..strokeWidth = GameConsts.BASE_SIZE // TODO: adjusted
    //     ..isAntiAlias = true;
    //
    //   // print('hp angle: ${base.hp * 360 / base.maxHp}  radians: ${base.hp * 360 / base.maxHp * pi / 180}');
    //
    //   final extraHp = base.maxHp - base.hp;
    //
    //   canvas.drawArc(
    //     // TODO: adjust sizes of all elements too.
    //     Rect.fromCircle(
    //       center: pos,
    //       radius: GameConsts.BASE_SIZE * (adjust?.shortestSide ?? 1),
    //     ),
    //     -90 * pi / 180,
    //     -extraHp * 360 / base.maxHp * pi / 180,
    //     true,
    //     hpPaint,
    //   );
    // }

    // Border
    // Paint basePaint = Paint()
    //   ..color = base.color
    //   ..style = PaintingStyle.stroke
    //   ..isAntiAlias = true
    //   ..strokeWidth = 3.0 * (adjust?.shortestSide ?? 1);
    //
    // canvas.drawCircle(
    //   pos,
    //   GameConsts.BASE_SIZE * (adjust?.shortestSide ?? 1), // TODO: DRY
    //   basePaint,
    // );

  }
}
