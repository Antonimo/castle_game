import 'dart:ui';

import 'package:castle_game/util/image.dart';
import 'package:image/image.dart' as imageLib;

class Sprite {
  final imageLib.Image image;
  final Image imageFrame;
  final Rect frame;
  final Size size;

  Sprite(this.image, this.imageFrame, this.frame, this.size);

  static Future<Sprite> cropFromImage(imageLib.Image image, Rect frame, Size size) async {
    imageLib.Image croppedImage = imageLib.copyCrop(image, frame.left.toInt(), frame.top.toInt(), frame.width.toInt(), frame.height.toInt());

    imageLib.Image resizedImage = imageLib.copyResize(croppedImage, width: size.width.toInt(), height: size.height.toInt());

    Image imageFrame = await getImageFrame(resizedImage);

    return Sprite(resizedImage, imageFrame, frame, size);
  }

  static Future<Sprite> flip(Sprite sprite) async {
    imageLib.Image flippedImage = imageLib.flipHorizontal(sprite.image);

    Image imageFrame = await getImageFrame(flippedImage);

    return Sprite(flippedImage, imageFrame, sprite.frame, sprite.size);
  }

  void draw(Canvas canvas, Offset drawPos, Paint paint) {
    var destination = Rect.fromCenter(center: drawPos, width: size.width, height: size.height);

    // canvas.drawImageRect(imageFrame, frame, destination, paint);
    canvas.drawImage(imageFrame, destination.topLeft, paint);
  }

  @override
  String toString() {
    return this.frame.toString();
  }
}
