import 'package:castle_game/game_painter.dart';
import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  GamePage({Key? key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(

        child: Stack(
          children: [
            // Add this
            buildCurrentPath(context),
          ],
        ),

      ),
    );
  }

  GestureDetector buildCurrentPath(BuildContext context) {
    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: RepaintBoundary(
        child: Container(
          color: Colors.transparent,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,

          child: CustomPaint(
            painter: GamePainter(),
          ),
        ),
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    print('User started drawing');
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    print(point);

    setState((){
      line = DrawnLine([point], selectedColor, selectedWidth);
    });
  }

  void onPanUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    print(point);
    final path = List.from(line.path)..add(point);
    setState((){
      line = DrawnLine(path, selectedColor, selectedWidth);
    });
  }

  void onPanEnd(DragEndDetails details) {
    print('User ended drawing');
    setState((){
      print('User ended drawing');
    });
  }

}