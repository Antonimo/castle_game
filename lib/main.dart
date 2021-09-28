import 'package:castle_game/app_router.dart';
import 'package:castle_game/pages/game_page.dart';
import 'package:castle_game/pages/menu_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// TODO: init settings
// TODO: disable rotation

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

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Castle game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      navigatorKey: AppRouter.appNavigatorKey,
      onGenerateRoute: AppRouter.instance.generateRoute,
      navigatorObservers: <NavigatorObserver>[
        AppRouter.instance.initNavigatorObserver(),
      ],
      home: MenuPage(),
    );
  }
}
