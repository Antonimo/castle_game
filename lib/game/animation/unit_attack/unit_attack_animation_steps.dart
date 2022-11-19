import 'dart:ui';

import 'package:castle_game/game/animation/animation_engine.dart';
import 'package:castle_game/game/animation/animation_step.dart';
import 'package:castle_game/game/animation/unit_attack/unit_attack_animation.dart';

// move towards enemy unit a distance equal to half unit size
class MoveToEnemyAnimationStep extends AnimationStep {
  final name = 'move to enemy unit';
  final duration = 0.1;

  final UnitAttackAnimation animation;

  MoveToEnemyAnimationStep(this.animation);

  calc(AnimationEngine a, double dt) {
    // enemy location
    // TODO: trigger stop animation
    if (animation.unit.engagedTarget == null) return;

    var direction = ((animation.unit.engagedTarget.pos as Offset) - (animation.unit.pos + a.animationOffset)).direction;

    // Speed
    double distance = 60.0 * dt;

    // TODO: setter?
    a.animationOffset = a.animationOffset + Offset.fromDirection(direction, distance);

    AnimationEngine.debugPrint('animationOffset: ${a.animationOffset}');
  }
}

class MoveBackAnimationStep extends AnimationStep {
  final name = 'move back';
  final duration = 0.1;

  final UnitAttackAnimation animation;

  MoveBackAnimationStep(this.animation);

  calc(AnimationEngine a, double dt) {
    var direction = (-a.animationOffset).direction;

    double distance = 60.0 * dt;

    // TODO: DRY
    a.animationOffset = a.animationOffset + Offset.fromDirection(direction, distance);

    AnimationEngine.debugPrint('animationOffset: ${a.animationOffset}');
  }
}

class IdleAnimationStep extends AnimationStep {
  final name = 'idle';

  // TODO: adjust to attack cooldown time
  final duration = 0.8;

  final UnitAttackAnimation animation;

  IdleAnimationStep(this.animation);

  calc(AnimationEngine a, double dt) {
    a.animationOffset = Offset.zero;

    AnimationEngine.debugPrint('animationOffset: ${a.animationOffset}');
  }
}
