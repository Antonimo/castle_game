import 'package:castle_game/app_router.dart';
import 'package:castle_game/pages/menu_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';

// TODO: init settings

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
