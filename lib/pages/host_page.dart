import 'package:castle_game/game/player.dart';
import 'package:castle_game/online/host_client.dart';
import 'package:flutter/material.dart';

class HostPage extends StatefulWidget {
  const HostPage({Key? key}) : super(key: key);

  @override
  _HostPageState createState() => _HostPageState();
}

class _HostPageState extends State<HostPage> {
  @override
  void initState() {
    super.initState();

    print('_HostPageState initState()');

    HostClient.init();
  }

  @override
  void dispose() {
    HostClient.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Host Online Game'),
      ),
      body: StreamBuilder<double>(
        stream: HostClient.instance?.game?.stateSubject.stream,
        builder: (context, snapshot) {
          return Center(
            child: Column(
              children: _buildPageItems(),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildPageItems() {
    if (HostClient.instance?.game?.id != null) {
      List<Widget> items = [
        SizedBox(height: 32.0),
        Text('Game Id: ${HostClient.instance!.game!.id}'),
        SizedBox(height: 32.0),
      ];

      if (HostClient.instance!.game!.players.length > 1) {
        HostClient.instance!.game?.players.forEach((Player player) {
          items.addAll([
            Text('player ${player.name}: ${player.ready ? 'ready' : 'not ready'}'),
          ]);
        });

        items.addAll([
          SizedBox(height: 32.0),
          ElevatedButton(
            onPressed: () {
              HostClient.instance!.ready();
            },
            child: const Text('Ready'),
          ),
        ]);

        return items;
      }

      items.addAll([
        Text('waiting for player2'),
      ]);
      return items;
    }

    return [
      SizedBox(height: 32.0),
      Text('Creating Online game...'),
      SizedBox(height: 32.0),
      CircularProgressIndicator(),
    ];
  }
}
