import 'dart:typed_data';
import 'dart:ui';
import 'package:image/image.dart' as imageLib;

Future<Image> getImageFrame(imageLib.Image src) async {
  final codec = await instantiateImageCodec(Uint8List.fromList(imageLib.encodePng(src)));

  var imageFrame = await codec.getNextFrame();

  return imageFrame.image;
}
