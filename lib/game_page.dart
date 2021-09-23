import 'dart:async';

import 'package:castle_game/drawn_line.dart';
import 'package:castle_game/game.dart';
import 'package:castle_game/game_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GamePage extends StatefulWidget {
  GamePage({Key? key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final _game = Game();

  Color drawingColor = Colors.black; // TODO: player / unit colors
  double drawingWidth = 3.0;

  // List<DrawnLine> lines = <DrawnLine>[];
  DrawnLine line = DrawnLine([], Colors.black, 5.0);

  // drawing distance
  // double distance = 0.0;

  // TODO: use relative size to screen
  // double distanceMax = 1300;

  bool drawing = false;

  @override
  void initState() {
    super.initState();
    //Fullscreen display (still including appbar)
    SystemChrome.setEnabledSystemUIOverlays([]);

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      _game.init(MediaQuery.of(context).size);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: buildCurrentPath(context),
          ),
        ],
      ),
    );
  }

  Widget buildCurrentPath(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // _game.toggleGame();
        if (!_game.running) {
          _game.init(MediaQuery.of(context).size);
        }
      },
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: RepaintBoundary(
        child: Container(
          // width: MediaQuery.of(context).size.width,
          // height: MediaQuery.of(context).size.height,
          // color: Colors.transparent,
          // alignment: Alignment.topLeft,
          child: StreamBuilder<double>(
            stream: _game.stateStreamController.stream,
            builder: (context, snapshot) {
              // print('line.path.length ${line.path.length} count: $count distance: $distance');

              return CustomPaint(
                painter: GamePainter(_game, [line]),
              );
            },
          ),
        ),
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    if (!_game.canDrawPath) return;

    drawing = true;

    RenderBox? box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);

    List<Offset> path = [
      // Offset(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height - 10),
      _game.drawPathForPlayer!.startPos,
      point
    ];

    line = DrawnLine(
      path,
      drawingColor,
      drawingWidth,
    );

    _game.drawDistance = (path[path.length - 1] - path[path.length - 2]).distance;
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (!drawing) return;

    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);

    List<Offset> path = List.from(line.path)..add(point);
    line = DrawnLine(path, drawingColor, drawingWidth);

    _game.drawDistance += (path[path.length - 1] - path[path.length - 2]).distance;

    // check collision with opponent base
    for(var base in _game.bases){
      if (base.player == _game.drawPathForPlayer) continue;
      if ((point - base.pos).distance < 32) {
        // TODO: move to consts
        drawing = false;
        _game.givePathToUnit(line);
        clearLine();
      }
    }


    // TODO: classes for game elements

    if (_game.drawDistance > _game.drawDistanceMax) {
      drawing = false;
      rejectLine();
    }

    // _game.stateStreamController.add(0);
  }

  void onPanEnd(DragEndDetails details) {
    if (!drawing) return;

    // _game.stateStreamController.add(0);

    drawing = false;
    rejectLine();

    // linesStreamController.add(lines);
  }

  void rejectLine() {
    clearLine();
  }

  void clearLine() {
    line = DrawnLine([], Colors.black, 5.0);
    _game.drawDistance = 0.0;
  }
}
