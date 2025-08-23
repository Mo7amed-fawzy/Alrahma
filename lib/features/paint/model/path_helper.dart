// import 'dart:ui';
// import 'dart:convert';

// class PathHelper {
//   /// يحوّل الـ Path لنقاط (List<Offset>)
//   static List<Offset> extractPointsFromPath(Path path) {
//     final List<Offset> points = [];
//     path.computeMetrics().forEach((metric) {
//       for (double i = 0; i < metric.length; i += 1.0) {
//         final pos = metric.getTangentForOffset(i)!.position;
//         points.add(pos);
//       }
//     });
//     return points;
//   }

//   /// يحوّل Path لنص JSON جاهز للتخزين
//   static String pathToJson(
//     Path path, {
//     Color color = const Color(0xFF000000),
//     double strokeWidth = 3.0,
//   }) {
//     final points = extractPointsFromPath(path);
//     final data = {
//       "points": points.map((p) => {"x": p.dx, "y": p.dy}).toList(),
//       "color": color.value,
//       "strokeWidth": strokeWidth,
//     };
//     return jsonEncode(data);
//   }

//   /// يبني Path جديد من JSON (عشان الـ Preview)
//   static Path pathFromJson(String jsonStr) {
//     final data = jsonDecode(jsonStr);
//     final points = (data["points"] as List)
//         .map((e) => Offset(e["x"], e["y"]))
//         .toList();
//     final path = Path();
//     if (points.isNotEmpty) {
//       path.moveTo(points.first.dx, points.first.dy);
//       for (var p in points.skip(1)) {
//         path.lineTo(p.dx, p.dy);
//       }
//     }
//     return path;
//   }
// }

// class PathStorageHelper {
//   /// تحويل Path لنقاط وحفظها كـ JSON
//   static String pathToJson(Path path) {
//     final metrics = path.computeMetrics();
//     final List<Map<String, double>> points = [];

//     for (var metric in metrics) {
//       final extractPath = metric.extractPath(0, metric.length);
//       final pathMetrics = extractPath.computeMetrics();

//       for (var pm in pathMetrics) {
//         for (double distance = 0.0; distance < pm.length; distance += 1.0) {
//           final tangent = pm.getTangentForOffset(distance);
//           if (tangent != null) {
//             points.add({'dx': tangent.position.dx, 'dy': tangent.position.dy});
//           }
//         }
//       }
//     }

//     return jsonEncode(points);
//   }

//   /// تحويل JSON لنقاط عشان ترسمها تاني
//   static List<Offset> jsonToPoints(String jsonString) {
//     final List decoded = jsonDecode(jsonString);
//     return decoded
//         .map((p) => Offset(p['dx'] as double, p['dy'] as double))
//         .toList();
//   }
// }
