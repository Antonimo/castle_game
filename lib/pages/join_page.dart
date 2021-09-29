import 'package:castle_game/online/join_client.dart';
import 'package:castle_game/online/online_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JoinPage extends StatefulWidget {
  const JoinPage({Key? key}) : super(key: key);

  @override
  _JoinPageState createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  final gameIdController = TextEditingController();

  @override
  void initState() {
    super.initState();

    JoinClient.init();
  }

  @override
  void dispose() {
    JoinClient.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Online Game'),
      ),
      body: StreamBuilder<double>(
        // TODO: use separate streams for lobby and for game, so that the lobby pages in the background would not redraw on updares
        // TODO: do not keep lobby pages in the stack? game page should be the only page?
        stream: JoinClient.instance?.stateSubject.stream,
        builder: (context, snapshot) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(32.0),
              child: Column(
                children: _buildPageItems(),
              ),
            ),
          );
        },
      ),
    );
  }

  // TODO: show errors
  List<Widget> _buildPageItems() {
    if (JoinClient.instance?.game?.id != null) {
      List<Widget> items = [
        SizedBox(height: 32.0),
        Text('Game Id: ${JoinClient.instance!.game!.id}'),
        SizedBox(height: 32.0),
      ];

      if (JoinClient.instance!.players.length > 1) {
        JoinClient.instance!.players.forEach((OnlinePlayer player) {
          items.addAll([
            Text('player ${player.name}: ${player.ready ? 'ready' : 'not ready'}'),
          ]);
        });

        items.addAll([
          SizedBox(height: 32.0),
          ElevatedButton(
            onPressed: () {
              JoinClient.instance!.ready();
            },
            child: const Text('Ready'),
          ),
        ]);

        return items;
      }

      items.addAll([
        Text('Connecting...'),
        SizedBox(height: 32.0),
        CircularProgressIndicator(),
      ]);
      return items;
    }

    return [
      SizedBox(height: 32.0),
      Text('Game Id:'),
      SizedBox(height: 32.0),
      Container(
        width: 100.0,
        child: TextField(
          controller: gameIdController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ),
      SizedBox(height: 32.0),
      ElevatedButton(
        onPressed: () {
          JoinClient.join(gameIdController.text);
        },
        child: const Text('Join'),
      ),
    ];
  }
}
