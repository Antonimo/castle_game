import 'package:castle_game/game/animation/animation_engine.dart';
import 'package:castle_game/game/animation/game_animation.dart';
import 'package:castle_game/game/animation/unit_attack/unit_attack_animation_steps.dart';
import 'package:castle_game/game/unit.dart';

class UnitAttackAnimation extends GameAnimation {
  final Unit unit;

  UnitAttackAnimation(this.unit) {
    steps = [
      MoveToEnemyAnimationStep(this),
      MoveBackAnimationStep(this),
      IdleAnimationStep(this),
    ];
  }

  before(AnimationEngine animationEngine) {
    if (unit.engagedTarget == null) {
      animationEngine.clearAnimation();
    }
  }
}
