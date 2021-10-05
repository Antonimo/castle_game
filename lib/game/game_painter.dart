import 'dart:math';
import 'dart:ui';

import 'package:castle_game/game/base.dart';
import 'package:castle_game/game/drawn_line.dart';
import 'package:castle_game/game/game.dart';
import 'package:castle_game/game/game_consts.dart';
import 'package:castle_game/game/unit.dart';
import 'package:castle_game/util/json_offset.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'item.dart';

class GamePainter extends CustomPainter {
  final Game game;
  final List<DrawnLine> lines;

  GamePainter(this.game, this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    // print('GamePainter paint() size.height: ${size.height}');

    // if (!game.running) return;

    if (game.canDrawPath && game.drawPathForPlayer?.pendingUnit != null) {
      // Highlight the pending unit
      drawPendingUnit(canvas, game.drawPathForPlayer!.pendingUnit!, game.adjust);
    }

    game.players.forEach((player) {
      if (player.pendingUnit != null) {
        drawUnit(canvas, player.pendingUnit!, game.adjust);
      }
    });

    game.bases.forEach((base) {
      drawBase(canvas, base, game.adjust);
    });

    game.units.forEach((unit) {
      if (unit.player == game.player && unit.path != null) {
        drawUnitPath(canvas, unit.path!, game.adjust);
      }
      drawUnit(canvas, unit, game.adjust);
    });

    game.items.forEach((item) {
      drawItem(canvas, item, game.adjust);
    });

    if (game.canDrawPath) {
      drawLine(canvas);
      drawRemainingDistanceIndicator(canvas, size, game.getDrawRemainingDistance());
    }
  }

  void drawLine(Canvas canvas) {
    Paint paint = Paint()
      ..color = lines[0].color
      ..isAntiAlias = true
      // ..strokeCap = StrokeCap.round
      ..strokeWidth = lines[0].width; // TODO: adjusted?

    canvas.drawPoints(PointMode.polygon, lines[0].path, paint);
  }

  void drawRemainingDistanceIndicator(Canvas canvas, Size size, double remainingDistance) {
    Paint paint = Paint()
      ..color = Colors.redAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8.0; // TODO: adjusted?

    canvas.drawLine(
      Offset(4.0, 0.0),
      Offset(4.0, remainingDistance * size.height / 100),
      paint,
    );
  }

  void drawBase(Canvas canvas, Base base, Size? adjust) {
    // HP
    Paint hpPaint = Paint()
      ..color = Colors.redAccent.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..style = PaintingStyle.fill
      ..strokeWidth = GameConsts.BASE_SIZE // TODO: adjusted
      ..isAntiAlias = true;

    // print('hp angle: ${base.hp * 360 / base.maxHp}  radians: ${base.hp * 360 / base.maxHp * pi / 180}');

    canvas.drawArc(
      // TODO: adjust sizes of all elements too.
      Rect.fromCircle(
        center: base.pos.adjust(adjust),
        radius: GameConsts.BASE_SIZE * (adjust?.shortestSide ?? 1),
      ),
      -90 * pi / 180,
      -base.hp * 360 / base.maxHp * pi / 180,
      true,
      hpPaint,
    );


    if (base.hp > base.maxHp) {

      // Extra HP
      Paint hpPaint = Paint()
        ..color = Colors.purple.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..style = PaintingStyle.fill
        ..strokeWidth = GameConsts.BASE_SIZE // TODO: adjusted
        ..isAntiAlias = true;

      // print('hp angle: ${base.hp * 360 / base.maxHp}  radians: ${base.hp * 360 / base.maxHp * pi / 180}');

      final extraHp = base.maxHp - base.hp;

      canvas.drawArc(
        // TODO: adjust sizes of all elements too.
        Rect.fromCircle(
          center: base.pos.adjust(adjust),
          radius: GameConsts.BASE_SIZE * (adjust?.shortestSide ?? 1),
        ),
        -90 * pi / 180,
        -extraHp * 360 / base.maxHp * pi / 180,
        true,
        hpPaint,
      );
    }


    // Border
    Paint basePaint = Paint()
      ..color = base.color
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = 3.0 * (adjust?.shortestSide ?? 1);

    canvas.drawCircle(
      base.pos.adjust(adjust),
      GameConsts.BASE_SIZE * (adjust?.shortestSide ?? 1), // TODO: DRY
      basePaint,
    );
  }

  void drawUnitPath(Canvas canvas, DrawnLine line, Size? adjust) {
    Paint paint = Paint()
      ..color = Colors.teal.withOpacity(0.4)
      // ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..strokeWidth = 1.0; // TODO: adjusted?

    // for (int j = 0; j < line.path.length - 1; ++j) {
    //   canvas.drawLine(line.path[j].adjust(adjust), line.path[j + 1].adjust(adjust), paint);
    // }
    canvas.drawPoints(PointMode.polygon, line.path.map((offset) => offset.adjust(adjust)).toList(), paint);
  }

  void drawUnit(Canvas canvas, Unit unit, Size? adjust) {
    // HP
    Paint hpPaint = Paint()
      ..color = Colors.redAccent.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..style = PaintingStyle.fill
      ..strokeWidth = GameConsts.UNIT_SIZE * (adjust?.shortestSide ?? 1)
      ..isAntiAlias = true;

    // print('hp angle: ${base.hp * 360 / base.maxHp}  radians: ${base.hp * 360 / base.maxHp * pi / 180}');

    canvas.drawArc(
      Rect.fromCircle(
        center: unit.pos.adjust(adjust),
        radius: GameConsts.UNIT_SIZE * (adjust?.shortestSide ?? 1), // TODO: DRY
      ), // TODO: adjusted
      -90 * pi / 180,
      -unit.hp * 360 / unit.maxHp * pi / 180,
      true,
      hpPaint,
    );

    // Border
    Paint unitPaint = Paint()
      ..color = unit.color
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = 1.0 * (adjust?.shortestSide ?? 1);

    canvas.drawCircle(
      unit.pos.adjust(adjust),
      GameConsts.UNIT_SIZE * (adjust?.shortestSide ?? 1),
      unitPaint,
    );
  }

  void drawPendingUnit(Canvas canvas, Unit unit, Size? adjust) {
    Paint unitPaint = Paint()
      ..color = Colors.blueGrey
      // ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0; // TODO: adjusted

    canvas.drawCircle(
      unit.pos.adjust(adjust),
      GameConsts.PENDING_UNIT_MARKER_SIZE * (adjust?.shortestSide ?? 1),
      unitPaint,
    );
  }

  void drawItem(Canvas canvas, Item item, Size? adjust) {
    final pos = item.pos.adjust(adjust);

    Paint itemPaint = Paint()
      ..color = Colors.black38
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = 1.5; // TODO: adjusted

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: pos,
          height: GameConsts.POWERUP_SIZE * 2,
          width: GameConsts.POWERUP_SIZE * 2,
        ),
        Radius.circular(3.0),
      ),
      itemPaint,
    );

    final IconData icon = Item.icons[item.type]!;

    TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: GameConsts.POWERUP_SIZE * 2,
        fontFamily: icon.fontFamily,
        color: Colors.redAccent,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, pos.translate(-GameConsts.POWERUP_SIZE, -GameConsts.POWERUP_SIZE));
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) {
    return true;
  }
}
