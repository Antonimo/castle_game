import 'package:castle_game/app_router.dart';
import 'package:castle_game/game/drawn_line.dart';
import 'package:castle_game/game/game.dart';
import 'package:castle_game/game/player.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

///
/// Base Class for the game client
///
class GameClient {
  Game? get game => null;

  void initGame(Size size) {}

  void onTap(Offset point) {}

  void givePathToUnit(DrawnLine line, Player player) {}

  void saveState() {}

  void loadState() {}

  Future<void> showGameOver() async {
    return showDialog<void>(
      context: AppRouter.appNavigatorKey.currentContext!,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over!'),
          // content: SingleChildScrollView(
          //   child: ListBody(
          //     children: const <Widget>[
          //       Text('Would you like to approve of this message?'),
          //     ],
          //   ),
          // ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                context.pop();
                context.pop();
                // AppRouter.instance.navBack(); // Close this popup
                // AppRouter.instance.navBack(); // Close game page, go back to lobby
              },
            ),
          ],
        );
      },
    );
  }
}
