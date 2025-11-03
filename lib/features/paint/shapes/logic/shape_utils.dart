import 'package:flutter/material.dart';

class ShapeUtils {
  /// يعمل Scaling لنقطة حوالين Anchor
  static Offset scalePoint(Offset point, Offset anchor, double factor) {
    return Offset(
      anchor.dx + (point.dx - anchor.dx) * factor,
      anchor.dy + (point.dy - anchor.dy) * factor,
    );
  }

  /// يحسب مركز بين نقطتين
  static Offset midpoint(Offset a, Offset b) {
    return Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
  }

  /// يحسب حجم من نقطتين (كعرض وارتفاع)
  static Size sizeFromOffsets(Offset start, Offset end) {
    return Size((end.dx - start.dx).abs(), (end.dy - start.dy).abs());
  }
}
