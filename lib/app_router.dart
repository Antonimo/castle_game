import 'package:castle_game/app_consts.dart';
import 'package:castle_game/app_navigator_observer.dart';
import 'package:castle_game/logger.dart';
import 'package:castle_game/pages/game_page.dart';
import 'package:castle_game/pages/host_page.dart';
import 'package:castle_game/pages/join_page.dart';
import 'package:castle_game/pages/menu_page.dart';
import 'package:castle_game/pages/unknown_page.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String TAG = '[AppRouter] ';

  AppRouter._privateConstructor();

  static final AppRouter _instance = AppRouter._privateConstructor();

  static AppRouter get instance => _instance;

  static final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey();

  AppNavigatorObserver? _observer;

  AppNavigatorObserver? get observer => _observer;

  /// Route Names
  static const String routeMenu = '/';
  static const String routeHost = 'host';
  static const String routeJoin = 'join';
  static const String routeGame = 'game';

  //default route
  static const String routeUnknown = 'unknown';

  static final List<String?> _routeStack = [];

  static bool get canPop => _routeStack.length != 1;

  static bool isLastRoute(String route) {
    return _routeStack.last == route;
  }

  void navTo(String routeName) {
    _debugPrint('<navTo> (path: $routeName)');

    if (_routeStack.isNotEmpty && _routeStack.last == routeName) {
      return;
    }

    switch (routeName) {
      case routeMenu:
        _pushAndRemoveUntil(routeMenu);
        break;
      case routeHost:
        _push(routeHost);
        break;
      case routeJoin:
        _push(routeJoin);
        break;
      case routeGame:
        _push(routeGame);
        break;

      default:
        _push(routeUnknown);
    }
  }

  void navBack() {
    _debugPrint('<navBack> ? canPop: ${appNavigatorKey.currentState?.canPop() ?? 'false'}');

    if (appNavigatorKey.currentState?.canPop() ?? false) {
      appNavigatorKey.currentState!.pop();
    }
  }

  void navBackUntil(String path) {
    _debugPrint('<navBackUntil> (path: $path)');

    appNavigatorKey.currentState!.popUntil((route) {
      bool shouldPop = false;
      if (route.settings.name == path) {
        shouldPop = true;
      }
      return shouldPop;
    });
  }

  PageRoute generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case routeMenu:
        return MaterialPageRoute(builder: (_) => MenuPage());

      case routeHost:
        return MaterialPageRoute(builder: (_) => HostPage());

      case routeJoin:
        return MaterialPageRoute(builder: (_) => JoinPage());

      case routeGame:
        return MaterialPageRoute(builder: (_) => GamePage());

      default:
        return _onUnknownRoute(settings);
    }
  }

  AppNavigatorObserver initNavigatorObserver() {
    return _observer ??= AppNavigatorObserver(
      onDidPush: (Route<dynamic> route, Route<dynamic>? previousRoute) {
        _routeStack.add(route.settings.name);

        _debugPrint('AppNavigatorObserver onDidPush: route: ${route.settings.name}, previousRoute: ${previousRoute?.settings.name}');
      },
      onDidPop: (Route<dynamic> route, Route<dynamic>? previousRoute) {
        _routeStack.removeLast();

        _debugPrint('AppNavigatorObserver onDidPop: route: ${route.settings.name}, previousRoute: ${previousRoute?.settings.name}');
      },
      onDidRemove: (Route<dynamic> route, Route<dynamic>? previousRoute) {
        final String lastRoute = _routeStack.last ?? '';

        // TODO: ??
        // if (lastRoute.isNotEmpty) {
        //   _routeStack.clear();
        //   _routeStack.add(lastRoute);
        // }

        _debugPrint('AppNavigatorObserver onDidPop: route: ${route.settings.name}, previousRoute: ${previousRoute?.settings.name}');
      },
      onDidReplace: ({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
        _debugPrint('AppNavigatorObserver onDidReplace: newRoute: ${newRoute?.settings.name}, oldRoute: ${oldRoute?.settings.name}');
      },
    );
  }

  void _push(String routeName) {
    appNavigatorKey.currentState!.pushNamed(routeName);
  }

  // void _replace(String routeName, {Object arguments}) {
  //   appNavigatorKey.currentState.pushReplacementNamed(routeName, arguments: arguments);
  // }

  void _pushAndRemoveUntil(String routeName) {
    appNavigatorKey.currentState!.pushNamedAndRemoveUntil(routeName, (routeName) => false);
  }

  static void _debugPrint(String text) {
    if (AppConsts.DEBUG_PRINT_ROUTER) {
      Log.i(TAG, text);
    }
  }

  MaterialPageRoute _onUnknownRoute(RouteSettings settings) {
    _debugPrint('onUnknownRoute: ${settings.name ?? 'null'} !!!!!!!!!!!!');
    return MaterialPageRoute(builder: (_) => UnknownPage());
  }

  static void debugPrintRouteStack() => _debugPrint(_routeStack.toString());
}
