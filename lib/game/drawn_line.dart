import 'package:castle_game/util/json_offset.dart';
import 'package:flutter/material.dart';

class DrawnLine {
  final List<Offset> path;
  final Color color;
  final double width;

  DrawnLine(this.path, this.color, this.width);

  Map toPlayState({Size? flip, Size? adjust}) {
    return {
      'path': path.map((Offset offset) => offset.adjust(adjust).flip(flip).toJson()).toList(),
    };
  }

  static DrawnLine? fromPlayState(playState, {Size? flipCoords}) {
    if (playState == null) return null;
    // TODO: colors

    final List<Offset> path = (playState['path'] as List).map((element) => Offset.zero.fromJson(element).flip(flipCoords)).toList();

    return DrawnLine(path, Colors.black, 5.0);
  }
}
