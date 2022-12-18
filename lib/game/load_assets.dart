import 'dart:async';
import 'dart:ui' as ui;

import 'package:castle_game/game/game.dart';
import 'package:castle_game/game/game_consts.dart';
import 'package:castle_game/game/sprite.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;

Future<void> loadAssets(Game game) async {
  await loadCharacterSprites(game);
  await loadCastlesSprites(game);
}

Future<void> loadCharacterSprites(Game game) async {
  print('game.playerSpritesIndexes: ${game.playerSpritesIndexes}');

  for (var i = 0; i < game.playerSpritesIndexes.length; i++) {
    final spriteIndex = game.playerSpritesIndexes[i];
    await loadCharacterSprite(game, "assets/game_textures/chars/$spriteIndex walk.png", "unit$spriteIndex");
  }
}

Future<void> loadCharacterSprite(Game game, String path, String collectionName) async {
  image.Image? characterSpritesImage = await loadImage(path);

  if (characterSpritesImage == null) {
    // TODO: critical errors handling
    throw Exception('Failed to load assets.');
  }

  // print('characterSpritesImage: ${characterSpritesImage.width} ${characterSpritesImage.height}');

  const spriteSize = ui.Size(16, 16);
  const spriteColumns = 3;
  const spriteRows = 4;

  // create a map of Sprites from the image, using coordinates on the image

  final List<Sprite> unitSprites = [];

  for (var col = 0; col < spriteColumns; col++) {
    for (var row = 0; row < spriteRows; row++) {
      unitSprites.add(
        await Sprite.cropFromImage(
          characterSpritesImage,
          ui.Rect.fromLTWH(col * spriteSize.width, row * spriteSize.height, spriteSize.width, spriteSize.height),
          ui.Size(
            GameConsts.UNIT_SIZE * 2 * (game.adjust?.shortestSide ?? 1),
            GameConsts.UNIT_SIZE * 2 * (game.adjust?.shortestSide ?? 1),
          ),
        ),
      );
    }
  }

  // add left facing animation by flipping the right facing animation
  for (var row = 0; row < spriteRows; row++) {
    unitSprites.add(
      await Sprite.flip(unitSprites[spriteColumns * spriteRows - spriteRows + row]),
    );
  }

  game.assets[collectionName] = unitSprites;
}

Future<void> loadCastlesSprites(Game game) async {
  await loadCastleSprite(game, 'assets/game_textures/castles/castle1.png', 'castle1');
  await loadCastleSprite(game, 'assets/game_textures/castles/castle2.png', 'castle2');
}

Future<void> loadCastleSprite(Game game, String path, String collectionName) async {
  image.Image? castleSpriteImage = await loadImage(path);

  if (castleSpriteImage == null) {
    // TODO: critical errors handling
    throw Exception('Failed to load assets.');
  }

  final List<Sprite> castleSprites = [];

  castleSprites.add(await Sprite.fromImage(
    castleSpriteImage,
    ui.Size(
      GameConsts.BASE_SIZE * 4 * (game.adjust?.shortestSide ?? 1),
      GameConsts.BASE_SIZE * 4 * (game.adjust?.shortestSide ?? 1),
    ),
  ));

  game.assets[collectionName] = castleSprites;
}

Future<image.Image?> loadImage(String imageAssetPath) async {
  final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
  return image.decodeImage(assetImageByteData.buffer.asUint8List());
}
