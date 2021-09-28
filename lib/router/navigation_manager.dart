import 'package:castle_game/router/navigation_manager_delegate.dart';
import 'package:castle_game/router/route_path.dart';

class NavigationManager {
  late NavigationManagerDelegate _delegate;

  NavigationManager(NavigationManagerDelegate delegate) {
    this._delegate = delegate;
  }

  void push(RoutePath path) {
    _delegate.push(path);
  }

  void pop() {
    _delegate.pop();
  }

  void reset() {
    _delegate.reset();
  }
}
