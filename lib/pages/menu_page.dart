import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // TODO: refactor routing paths and names
                context.go('/host');
              },
              child: const Text('Host 1v1 Online Game'),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                context.go('/join');
              },
              child: const Text('Join 1v1 Online Game'),
            ),
            SizedBox(height: 32.0),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                // TODO: rename multiplayer to something like onDevice2Players
                context.go('/multiplayer');
              },
              child: const Text('Play 1v1 on this device'),
            ),
          ],
        ),
      ),
    );
  }
}
