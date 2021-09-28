import 'package:flutter/material.dart';

extension JsonOffset on Offset {
  Map<String, dynamic> toJson() => <String, double>{
        'dx': dx,
        'dy': dy,
      };

  Offset fromJson(Map<String, dynamic> json) => Offset(
        (json['dx'] as num).toDouble(),
        (json['dy'] as num).toDouble(),
      );

  Offset flip(Size? size) => Offset(
    size == null ? dx : size.width - dx,
    size == null ? dy : size.height - dy,
  );

  Offset adjust(Size? size) {
    if (size == null) return this;

    return Offset(
      dx * size.width,
      dy * size.height,
    );
  }
}
