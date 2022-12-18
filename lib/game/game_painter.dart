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

    // debugDrawSprites(canvas, game.adjust);
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
    final sprite = this.game.assets[base.spritesCollectionName];

    if (sprite != null) {
      base.draw(canvas, sprite, adjust);
    }
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
    // TODO: use enum? map?
    final sprite = this.game.assets[unit.spritesCollectionName];

    if (sprite != null) {
      unit.draw(canvas, sprite, adjust);
    }
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

  void debugDrawSprites(Canvas canvas, Size? adjust) {
    var x = 20.0;

    Paint unitSpritePaint = Paint();

    this.game.assets.forEach((key, asset) {
      var y = 20.0;

      asset.forEach((sprite) {

        sprite.draw(canvas, Offset(x, y).adjust(adjust), unitSpritePaint);

        y += sprite.imageFrame.height + 2;
      });

      x += asset[0].imageFrame.width + 2;
    });
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) {
    return true;
  }
}
