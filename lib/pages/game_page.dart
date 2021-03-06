import 'package:castle_game/game/drawn_line.dart';
import 'package:castle_game/game/game_client.dart';
import 'package:castle_game/game/game_consts.dart';
import 'package:castle_game/game/game_painter.dart';
import 'package:castle_game/util/json_offset.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GamePage extends StatefulWidget {
  Object? arguments;

  GamePage({Key? key, this.arguments}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static const String TAG = '[_GamePageState] ';

  GameClient? _gameClient;

  // final _game = Game();

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

    final arguments = widget.arguments as Map?;

    if (arguments != null) {
      print('arguments:');
      print(arguments);

      _gameClient = arguments['gameClient'];
    }

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      _gameClient!.initGame(MediaQuery.of(context).size);
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
      // TODO: restart game option
      // onTap: () {
      //   // _game.toggleGame();
      //   if (!_gameClient!.game!.running) {
      //     // _gameClient!.game!.init(MediaQuery.of(context).size);
      //   }
      // },
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
            stream: _gameClient!.game!.stateSubject.stream,
            builder: (context, snapshot) {
              // print('line.path.length ${line.path.length} count: $count distance: $distance');

              return CustomPaint(
                painter: GamePainter(_gameClient!.game!, [line]),
              );
            },
          ),
        ),
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    if (!_gameClient!.game!.canDrawPath) return;

    drawing = true;

    RenderBox? box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);

    List<Offset> path = [
      // Offset(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height - 10),
      _gameClient!.game!.drawPathForPlayer!.startPos.adjust(_gameClient!.game?.adjust),
      point
    ];

    line = DrawnLine(
      path,
      drawingColor,
      drawingWidth,
    );

    _gameClient!.game!.drawDistance = (path[path.length - 1] - path[path.length - 2]).distance;
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (!drawing) return;

    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);

    List<Offset> path = List.from(line.path)..add(point);
    line = DrawnLine(path, drawingColor, drawingWidth);

    _gameClient!.game!.drawDistance += (path[path.length - 1] - path[path.length - 2]).distance;

    if (!_gameClient!.game!.canDrawPath || _gameClient?.game?.drawPathForPlayer == null) {
      drawing = false;
      _gameClient!.game!.canDrawPath = false;
      _gameClient?.game?.drawPathForPlayer = null;
      rejectLine();
      return;
    }

    // check collision with opponent base
    for (var base in _gameClient!.game!.bases) {
      if (_gameClient?.game?.drawPathForPlayer == null) break;
      if (base.player == _gameClient!.game!.drawPathForPlayer!.id) continue;

      // Log.i(TAG, 'onPanUpdate distance: ${(point - base.pos.adjust(_gameClient!.game!.adjust!)).distance} adjust: ${_gameClient!.game!.adjust!.shortestSide} adjusted: ${(30 * (_gameClient!.game!.adjust == null ? 1 : _gameClient!.game!.adjust!.shortestSide))}');

      if ((point - base.pos.adjust(_gameClient?.game?.adjust)).distance <
          ((GameConsts.BASE_SIZE + 1) * (_gameClient!.game?.adjust == null ? 1 : _gameClient!.game!.adjust!.shortestSide))) {
        // Log.i(TAG, 'onPanUpdate distance: ${(point - base.pos.adjust(_gameClient!.game!.adjust!)).distance} adjust: ${_gameClient!.game!.adjust!.shortestSide} adjusted: ${(30 * (_gameClient!.game!.adjust == null ? 1 : _gameClient!.game!.adjust!.shortestSide))}');

        // TODO: move to consts
        drawing = false;
        _gameClient!.givePathToUnit(line, _gameClient!.game!.drawPathForPlayer!);
        _gameClient!.game!.drawPathForPlayer = null;
        _gameClient!.game!.canDrawPath = false; // TODO: DRY
        clearLine();
      }
    }

    // TODO: classes for game elements

    if (_gameClient!.game!.drawDistance > _gameClient!.game!.drawDistanceMax) {
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
    _gameClient!.game!.drawDistance = 0.0;
  }
}
