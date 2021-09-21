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

  int count = 0;
  double distance = 0.0;

  // TODO: use relative size to screen
  double distanceMax = 1300;

  bool drawing = false;

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
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: RepaintBoundary(
        child: Container(
          // width: MediaQuery.of(context).size.width,
          // height: MediaQuery.of(context).size.height,
          // padding: EdgeInsets.all(4.0),
          // color: Colors.transparent,
          // alignment: Alignment.topLeft,
          child: StreamBuilder<DrawnLine>(
            stream: currentLineStreamController.stream,
            builder: (context, snapshot) {


              // print('line.path.length ${line.path.length} count: $count distance: $distance');


              return CustomPaint(
                painter: GamePainter(
                  lines: [line],
                  remainingDistance: (distanceMax - distance) * 100 / distanceMax,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    drawing = true;

    RenderBox? box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    List<Offset> path = [
      Offset(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height - 10),
      point
    ];
    line = DrawnLine(
        path,
        drawingColor,
        drawingWidth,
    );
    count = 1;
    distance = (path[path.length - 1] - path[path.length - 2]).distance;
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (!drawing) return;
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);

    count++;

    List<Offset> path = List.from(line.path)..add(point);
    line = DrawnLine(path, drawingColor, drawingWidth);

    distance += (path[path.length - 1] - path[path.length - 2]).distance;

    // check collision with opponent base
    final Size screen = MediaQuery.of(context).size;
    final Offset p2Base = Offset(
      screen.width / 2,
      15 * screen.height / 100,
    );

    if ((point - p2Base).distance < 30) {
      drawing = false;
    }


    // TODO: classes for game elements


    if (distance > distanceMax) {
      drawing = false;
      rejectLine();
    }

    currentLineStreamController.add(line);
  }

  void onPanEnd(DragEndDetails details) {
    if (!drawing) return;

    lines = List.from(lines)..add(line);

    currentLineStreamController.add(line);

    count++;

    drawing = false;
    rejectLine();

    // linesStreamController.add(lines);
  }

  void rejectLine() {
    line = DrawnLine([], Colors.black, 5.0);
  }
}