import 'dart:math';

import 'package:castle_game/game/animation/animation_engine.dart';
import 'package:castle_game/game/animation/animation_step.dart';
import 'package:castle_game/game/animation/game_animation.dart';
import 'package:castle_game/game/unit.dart';

class UnitWalkAnimation extends GameAnimation {
  final Unit unit;

  UnitWalkAnimation(this.unit) {
    steps = [
      WalkAnimationStep(this, 0),
      WalkAnimationStep(this, 1),
      WalkAnimationStep(this, 2),
      WalkAnimationStep(this, 3),
    ];
  }
}

class WalkAnimationStep extends AnimationStep {
  final name = 'walk';
  final duration = 0.15;

  final UnitWalkAnimation animation;

  final int spriteIndex;

  WalkAnimationStep(this.animation, this.spriteIndex);

  calc(AnimationEngine a, double dt) {
    // facing direction?

    a.currentSprite = 4 * (directionSpriteIndex[getDirection(animation.unit.facingDirection)] ?? 0) + spriteIndex;
  }
}

const Map<Direction, int> directionSpriteIndex = {
  Direction.down: 0,
  Direction.up: 1,
  Direction.right: 2,
  Direction.left: 3,
};

enum Direction { down, up, right, left }

Direction getDirection(angle) {
  if (angle >= -pi / 4 && angle <= pi / 4) {
    return Direction.right;
  }
  if (angle < -pi / 4 && angle > -pi * 3 / 4) {
    return Direction.up;
  }
  if (angle < -pi * 3 / 4 || angle > pi * 3 / 4) {
    return Direction.left;
  }
  return Direction.down;
}