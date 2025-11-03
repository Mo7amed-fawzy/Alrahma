// import 'package:flutter/material.dart';

// class PathData {
//   final List<Offset> points;
//   final Color color;
//   final double strokeWidth;

//   PathData({
//     required this.points,
//     required this.color,
//     required this.strokeWidth,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'points': points.map((e) => {'dx': e.dx, 'dy': e.dy}).toList(),
//       'color': color.value,
//       'strokeWidth': strokeWidth,
//     };
//   }

//   factory PathData.fromMap(Map<String, dynamic> map) {
//     return PathData(
//       points: List<Offset>.from(
//         (map['points'] as List).map((e) => Offset(e['dx'], e['dy'])),
//       ),
//       color: Color(map['color']),
//       strokeWidth: map['strokeWidth'],
//     );
//   }
// }
