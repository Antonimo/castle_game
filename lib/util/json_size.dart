import 'package:flutter/material.dart';

extension JsonSize on Size {
  Map<String, dynamic> toJson() => <String, double>{
        'width': width,
        'height': height,
      };

  Size fromJson(Map<String, dynamic> json) => Size(
        (json['width'] as num).toDouble(),
        (json['height'] as num).toDouble(),
      );
}
