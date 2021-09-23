import 'dart:math';

import 'package:castle_game/base.dart';
import 'package:castle_game/drawn_line.dart';
import 'package:castle_game/game.dart';
import 'package:castle_game/unit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class GamePainter extends CustomPainter {
  final List<DrawnLine> lines;
  final double remainingDistance;
  final Game game;

  GamePainter({
    required this.lines,
    required this.remainingDistance,
    required this.game,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // print('size.height: ${size.height} remainingDistance: $remainingDistance');

    if (!game.running) return;

    game.bases.forEach((base) {
      drawBase(canvas, base);
    });

    drawLine(canvas);
    drawRemainingDistanceIndicator(canvas, size);

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

  void drawRemainingDistanceIndicator(Canvas canvas, Size size) {
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

    print('hp angle: ${base.hp * 360 / base.maxHp}  radians: ${base.hp * 360 / base.maxHp * pi / 180}');

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
    Paint unitPaint = Paint()
      ..color = Colors.redAccent
      // ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(
      unit.pos,
      8,
      unitPaint,
    );
  }

  void _drawArcWithCenter(
    Canvas canvas,
    Paint paint, {
    required Offset center,
    required double radius,
    startRadian = 0.0,
    sweepRadian = pi,
  }) {
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startRadian,
      sweepRadian,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) {
    return true;
  }
}
