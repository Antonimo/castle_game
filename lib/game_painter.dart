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

    drawBases(canvas, size); // TODO: use flutter widgets instead?
    drawLine(canvas);
    drawRemainingDistanceIndicator(canvas, size);

    game.units.forEach((unit){
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

  void drawBases(Canvas canvas, Size size) {
    Paint myBase = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    Paint opponentBase = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    canvas.drawCircle(
      Offset(
        size.width / 2,
        85 * size.height / 100,
      ),
      30,
      myBase,
    );

    canvas.drawCircle(
      Offset(
        size.width / 2,
        15 * size.height / 100,
      ),
      30,
      opponentBase,
    );
  }

  void drawUnit(Canvas canvas, Unit unit){
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

  @override
  bool shouldRepaint(GamePainter oldDelegate) {
    return true;
  }
}
