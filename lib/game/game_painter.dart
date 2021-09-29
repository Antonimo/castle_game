import 'dart:math';

import 'package:castle_game/game/base.dart';
import 'package:castle_game/game/drawn_line.dart';
import 'package:castle_game/game/game.dart';
import 'package:castle_game/game/game_consts.dart';
import 'package:castle_game/game/unit.dart';
import 'package:castle_game/util/json_offset.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class GamePainter extends CustomPainter {
  final Game game;
  final List<DrawnLine> lines;

  GamePainter(this.game, this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    // print('GamePainter paint() size.height: ${size.height}');

    // if (!game.running) return;

    if (game.canDrawPath) {
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

    if (game.canDrawPath) {
      drawLine(canvas);
      drawRemainingDistanceIndicator(canvas, size, game.getDrawRemainingDistance());
    }

    game.units.forEach((unit) {
      drawUnit(canvas, unit, game.adjust);
    });
  }

  void drawLine(Canvas canvas) {
    Paint paint = Paint()
      ..color = Colors.redAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0; // TODO: adjusted?

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
      ..color = Colors.redAccent
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

    // Border
    Paint basePaint = Paint()
      ..color = base.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0 * (adjust?.shortestSide ?? 1);

    canvas.drawCircle(
      base.pos.adjust(adjust),
      GameConsts.BASE_SIZE * (adjust?.shortestSide ?? 1), // TODO: DRY
      basePaint,
    );
  }

  void drawUnit(Canvas canvas, Unit unit, Size? adjust) {
    // HP
    Paint hpPaint = Paint()
      ..color = Colors.redAccent
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
      ..strokeWidth = 3.0 * (adjust?.shortestSide ?? 1);

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

  @override
  bool shouldRepaint(GamePainter oldDelegate) {
    return true;
  }
}
