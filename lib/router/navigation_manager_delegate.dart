import 'package:castle_game/router/route_path.dart';

class NavigationManagerDelegate {
  Function(RoutePath)? _onPush;
  Function? _onPop;
  Function? _onReset;

  set onPush(Function(RoutePath) callback) => _onPush = callback;

  set onPop(Function callback) => _onPop = callback;

  set onReset(Function callback) => _onReset = callback;

  void push(RoutePath path) {
    _onPush!(path);
  }

  void pop() {
    _onPop!();
  }

  void reset() {
    _onReset!();
  }
}
