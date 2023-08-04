import 'package:castle_game/app_router.dart';
import 'package:castle_game/pages/game_page.dart';
import 'package:castle_game/pages/host_page.dart';
import 'package:castle_game/pages/join_page.dart';
import 'package:castle_game/pages/menu_page.dart';
import 'package:castle_game/pages/multiplayer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock/wakelock.dart';

// TODO: init settings

final _router = GoRouter(
  navigatorKey: AppRouter.appNavigatorKey,
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => MenuPage(),
      routes: [
        GoRoute(
          path: 'host',
          builder: (context, state) => HostPage(),
        ),
        GoRoute(
          path: 'join',
          builder: (context, state) => JoinPage(inviteToken: state.uri.queryParameters['inviteToken']),
        ),
        GoRoute(
          path: 'multiplayer',
          builder: (context, state) => MultiplayerPage(),
        ),
        GoRoute(
          path: 'game',
          builder: (context, state) => GamePage(arguments: state.extra),
        ),
      ],
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  /// Use custom UI errors handler - mainly for printing the error stacktrace
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    print(errorDetails.toString());
    print(errorDetails.stack);
    return Container(color: Colors.red);
  };

  Wakelock.enable();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Castle game',
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
    // return MaterialApp(
    //   title: 'Castle game',
    //   theme: ThemeData(
    //     primarySwatch: Colors.blue,
    //   ),
    //   debugShowCheckedModeBanner: false,
    //   navigatorKey: AppRouter.appNavigatorKey,
    //   onGenerateRoute: AppRouter.instance.generateRoute,
    //   navigatorObservers: <NavigatorObserver>[
    //     AppRouter.instance.initNavigatorObserver(),
    //   ],
    //   home: MenuPage(),
    // );
  }
}
