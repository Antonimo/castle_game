import 'dart:async';
import 'dart:ui' as ui;

import 'package:castle_game/game/game.dart';
import 'package:castle_game/game/game_consts.dart';
import 'package:castle_game/game/sprite.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;

Future<void> loadAssets(Game game) async {
  await loadCharacterSprites(game);
}

Future<void> loadCharacterSprites(Game game) async {
  for (var i = 1; i <= 10; i++) {
    await loadCharacterSprite(game, "assets/game_textures/chars/$i walk.png", "unit$i");
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
  print(' ');
  print('Loading Left');
  for (var row = 0; row < spriteRows; row++) {
    unitSprites.add(
      await Sprite.flip(unitSprites[spriteColumns * spriteRows - spriteRows + row]),
    );
  }

  game.assets[collectionName] = unitSprites;
}

Future<image.Image?> loadImage(String imageAssetPath) async {
  final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
  return image.decodeImage(assetImageByteData.buffer.asUint8List());
}
