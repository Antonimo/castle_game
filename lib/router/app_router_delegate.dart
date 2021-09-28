import 'package:castle_game/pages/menu_page.dart';
import 'package:castle_game/router/navigation_manager.dart';
import 'package:castle_game/router/navigation_manager_delegate.dart';
import 'package:castle_game/router/path_stack.dart';
import 'package:castle_game/router/route_path.dart';
import 'package:flutter/material.dart';

class AppRouterDelegate extends RouterDelegate<RoutePath> with ChangeNotifier, PopNavigatorRouterDelegateMixin<RoutePath> {
  @override
  final navigatorKey = GlobalKey<NavigatorState>();

  final PathStack stack = PathStack(root: RoutePath.lander());

  NavigationManagerDelegate _navigationManagerDelegate = NavigationManagerDelegate();

  late NavigationManager _navManager;

  AppRouterDelegate({Key? key}) : super() {
    NavigationManager(_navigationManagerDelegate);
    _navigationManagerDelegate.onPush = (RoutePath path) {
      stack.push(path);
    };
    _navigationManagerDelegate.onPop = () {
      stack.pop();
    };
    _navigationManagerDelegate.onReset = () {
      stack.reset();
    };
    stack.addListener(notifyListeners);
    print("1. AppRouterDelegate initialized");
    print(this);
  }

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => NavigationManager(_navigationManagerDelegate),
      child: Navigator(
        key: navigatorKey,
        pages: buildPages(),
        onPopPage: (route, result) {
          if (!route.didPop(result)) return false;
          if (stack.items.length == 1) return false;
          stack.pop();
          return true;
        },
      ),
    );
  }

  List<Page<dynamic>> buildPages() {
    return stack.items.map<Page<dynamic>>((e) {
      ValueKey key = ValueKey('${e.id}-${e.argument}');
      if (e.isLanderPage) return LanderPage();
      if (e.isDetailsPage) return DetailsPage(id: e.argument);
      return UnknownPage();
    }).toList();

    List<Page<dynamic>> pages = [];
    pages.add(
      MaterialPage(key: ValueKey('MenuPage'), child: MenuPage()),
    );
    return pages;
  }

  @override
  Future<void> setNewRoutePath(RoutePath configuration) async {
    if (configuration.isDetailsPage) {
      // bShowDetails = true;
      // currentDetailsId = configuration.argument;
    } else {
      // currentDetailsId = "";
      // bShowDetails = false;
    }
    notifyListeners();
  }
}
