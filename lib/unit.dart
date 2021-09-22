

import 'package:castle_game/drawn_line.dart';
import 'package:flutter/material.dart';

class Unit {
  Offset pos;
  DrawnLine? path;

  // TODO: relation to player

  double speed = 50; // pixels per second // TODO: use %

  Unit(this.pos);

  void move(double dt){
    if(path == null) return;

    if (path!.path.isEmpty) return;

    double distance = speed * dt;

    while (distance > 0) {
      final Offset nextPoint = path!.path.first;

      final diffOffset = (nextPoint - pos);

      final double distanceToPoint = diffOffset.distance;

      print('distanceToPoint: $distanceToPoint remaining distance: $distance');

      if (distance <= distanceToPoint) {

        print('distance <= distanceToPoint !!');

        pos = pos + Offset.fromDirection(diffOffset.direction, distance);

        return;
      }

      distance -= distanceToPoint;

      pos = path!.path.first;

      path!.path.removeAt(0);
    }
  }
}