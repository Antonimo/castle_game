import 'dart:math';

import 'package:castle_game/game/base.dart';
import 'package:castle_game/game/drawn_line.dart';
import 'package:castle_game/game/game.dart';
import 'package:castle_game/game/unit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class GamePainter extends CustomPainter {
  final Game game;
  final List<DrawnLine> lines;

  GamePainter(this.game, this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    // print('size.height: ${size.height} remainingDistance: $remainingDistance');

    // if (!game.running) return;

    if (game.canDrawPath) {
      // Highlight the pending unit
      drawPendingUnit(canvas, game.drawPathForPlayer!.pendingUnit!);
    }

    game.players.forEach((player) {
      if (player.pendingUnit != null) {
        drawUnit(canvas, player.pendingUnit!);
      }
    });

    game.bases.forEach((base) {
      drawBase(canvas, base);
    });

    if (game.canDrawPath) {
      drawLine(canvas);
      drawRemainingDistanceIndicator(canvas, size, game.getDrawRemainingDistance());
    }

    game.units.forEach((unit) {
      drawUnit(canvas, unit);
    });
  }

  void drawLine(Canvas canvas) {
    Paint paint = Paint()
      ..color = Colors.redAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < lines.length; ++i) {
      if (lines[i] == null) continue;
      for (int j = 0; j < lines[i].path.length - 1; ++j) {
        if (lines[i].path[j] != null && lines[i].path[j + 1] != null) {
          paint.color = lines[i].color;
          paint.strokeWidth = lines[i].width;
          canvas.drawLine(lines[i].path[j], lines[i].path[j + 1], paint);
        }
      }
    }
  }

  void drawRemainingDistanceIndicator(Canvas canvas, Size size, double remainingDistance) {
    Paint paint = Paint()
      ..color = Colors.redAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8.0;

    canvas.drawLine(
      Offset(4.0, 0.0),
      Offset(4.0, remainingDistance * size.height / 100),
      paint,
    );
  }

  void drawBase(Canvas canvas, Base base) {
    // HP
    Paint hpPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..style = PaintingStyle.fill
      ..strokeWidth = 30.0
      ..isAntiAlias = true;

    // print('hp angle: ${base.hp * 360 / base.maxHp}  radians: ${base.hp * 360 / base.maxHp * pi / 180}');

    canvas.drawArc(
      Rect.fromCircle(center: base.pos, radius: 30.0),
      -90 * pi / 180,
      -base.hp * 360 / base.maxHp * pi / 180,
      true,
      hpPaint,
    );

    // Border
    Paint basePaint = Paint()
      ..color = base.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    canvas.drawCircle(base.pos, 30, basePaint);
  }

  void drawUnit(Canvas canvas, Unit unit) {
    // HP
    Paint hpPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..style = PaintingStyle.fill
      ..strokeWidth = 8.0
      ..isAntiAlias = true;

    // print('hp angle: ${base.hp * 360 / base.maxHp}  radians: ${base.hp * 360 / base.maxHp * pi / 180}');

    canvas.drawArc(
      Rect.fromCircle(center: unit.pos, radius: 8.0),
      -90 * pi / 180,
      -unit.hp * 360 / unit.maxHp * pi / 180,
      true,
      hpPaint,
    );

    // Border
    Paint unitPaint = Paint()
      ..color = unit.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(unit.pos, 9, unitPaint);
  }

  void drawPendingUnit(Canvas canvas, Unit unit) {
    Paint unitPaint = Paint()
      ..color = Colors.blueGrey
      // ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(unit.pos, 15, unitPaint);
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) {
    return true;
  }
}
