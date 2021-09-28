import 'package:castle_game/app_router.dart';
import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Castle Game'),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                AppRouter.instance.navTo(AppRouter.routeHost);
              },
              child: const Text('Host Online Game'),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                AppRouter.instance.navTo(AppRouter.routeJoin);
              },
              child: const Text('Join Online Game'),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}