import 'package:flutter/material.dart';

typedef AppNavigatorObserverEventHandler = void Function(Route<dynamic> route, Route<dynamic>? previousRoute);
typedef AppNavigatorObserverReplaceEventHandler = void Function({Route<dynamic>? newRoute, Route<dynamic>? oldRoute});

class AppNavigatorObserver extends NavigatorObserver {
  final AppNavigatorObserverEventHandler? onDidPush;
  final AppNavigatorObserverEventHandler? onDidPop;
  final AppNavigatorObserverEventHandler? onDidRemove;
  final AppNavigatorObserverReplaceEventHandler? onDidReplace;

  AppNavigatorObserver({
    this.onDidPush,
    this.onDidPop,
    this.onDidRemove,
    this.onDidReplace,
  });

  /// The [Navigator] pushed `route`.
  ///
  /// The route immediately below that one, and thus the previously active
  /// route, is `previousRoute`.
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => onDidPush!(route, previousRoute);

  /// The [Navigator] popped `route`.
  ///
  /// The route immediately below that one, and thus the newly active
  /// route, is `previousRoute`.
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => onDidPop!(route, previousRoute);

  /// The [Navigator] removed `route`.
  ///
  /// If only one route is being removed, then the route immediately below
  /// that one, if any, is `previousRoute`.
  ///
  /// If multiple routes are being removed, then the route below the
  /// bottommost route being removed, if any, is `previousRoute`, and this
  /// method will be called once for each removed route, from the topmost route
  /// to the bottommost route.
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => onDidRemove!(route, previousRoute);

  /// The [Navigator] replaced `oldRoute` with `newRoute`.
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => onDidReplace!(newRoute: newRoute, oldRoute: oldRoute);
}
