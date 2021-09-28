import 'package:castle_game/pages/game_page.dart';
import 'package:castle_game/pages/host_page.dart';
import 'package:castle_game/pages/join_page.dart';
import 'package:castle_game/pages/menu_page.dart';
import 'package:castle_game/router/ui_pages.dart';
import 'package:castle_game/router/ui_pages.dart';
import 'package:castle_game/router/ui_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// TODO: init settings
// TODO: disable rotation

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  AppRouterDelegate _routerDelegate = AppRouterDelegate();
  AppRouteInformationParser _routeInformationParser = AppRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Castle game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
      //
      // initialRoute: UIPages.Menu,
      // routes: {
      //   UIPages.Menu: (context) => MenuPage(),
      //   UIPages.Host: (context) => HostPage(),
      //   UIPages.Join: (context) => JoinPage(),
      //   UIPages.Game: (context) => GamePage(),
      // },
    );
  }
}

