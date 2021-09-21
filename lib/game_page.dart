import 'dart:async';

import 'package:castle_game/drawn_line.dart';
import 'package:castle_game/game_painter.dart';
import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  GamePage({Key? key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {

  Color drawingColor = Colors.black;
  double drawingWidth = 5.0;

  List<DrawnLine> lines = <DrawnLine>[];
  DrawnLine line = DrawnLine([], Colors.black, 5.0);

  StreamController<DrawnLine> currentLineStreamController = StreamController<DrawnLine>.broadcast();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          buildCurrentPath(context),
        ],
      ),
    );
  }

  Widget buildCurrentPath(BuildContext context) {
    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: RepaintBoundary(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(4.0),
          color: Colors.transparent,
          alignment: Alignment.topLeft,
          child: StreamBuilder<DrawnLine>(
            stream: currentLineStreamController.stream,
            builder: (context, snapshot) {
              print(line.path.length);
              return CustomPaint(
                painter: GamePainter(
                  lines: [line],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    RenderBox? box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    line = DrawnLine([point], drawingColor, drawingWidth);
  }

  void onPanUpdate(DragUpdateDetails details) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);

    List<Offset> path = List.from(line.path)..add(point);
    line = DrawnLine(path, drawingColor, drawingWidth);
    currentLineStreamController.add(line);
  }

  void onPanEnd(DragEndDetails details) {
    lines = List.from(lines)..add(line);

    currentLineStreamController.add(line);

    // linesStreamController.add(lines);
  }
}