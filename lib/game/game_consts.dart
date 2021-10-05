class GameConsts {
  // Core config
  static const CALCULATIONS_PER_SECOND = 40;
  static const PLAYING_GAME_STATE_EMITS_DELAY = 5000;

  // Sizes
  static const BASE_SIZE = 30.0;
  static const UNIT_SIZE = 8.0;
  static const PENDING_UNIT_MARKER_SIZE = 15.0;
  static const POWERUP_SIZE = 8.0;

  // Stats
  static const BASE_MAX_HP = 300.0;
  static const UNIT_MAX_HP = 60.0;

  static const UNIT_SPEED = 40.0; // pixels per second

  // Play Mechanics
  static const DRAW_DISTANCE_MAX = 1300.0;

  // Game Mechanics
  static const INITIAL_NEXT_UNIT_COOLDOWN = 3.0;
  static const NEXT_UNIT_COOLDOWN = 5.0;
  static const UNIT_ENGAGED_COOLDOWN = 1.0;
  static const NEXT_POWERUP_COOLDOWN = 8.0;

  static const UNIT_ENGAGE_DISTANCE = 17.0; // size * 2 + 1
  static const UNIT_ENGAGE_BASE_DISTANCE = 32.0; // base size + 2
}
