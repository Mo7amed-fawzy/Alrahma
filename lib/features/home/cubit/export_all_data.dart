// import 'dart:convert';
// import 'package:flutter/widgets.dart';
// import 'package:flutter/foundation.dart';
// import 'package:alrahma/features/client/cubit/clients_cubit.dart';
// import 'package:alrahma/features/payment/cubit/payments_cubit.dart';
// import 'package:alrahma/features/project/cubit/projects_cubit.dart';
// import 'package:alrahma/features/paint/cubit/drawings_nav_cubit.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// Future<void> exportAllDataAsJson(BuildContext context) async {
//   final clientsCubit = context.read<ClientsCubit>();
//   final projectsCubit = context.read<ProjectsCubit>();
//   final paymentsCubit = context.read<PaymentsCubit>();
//   final drawingsCubit = context.read<DrawingsCubit>();

//   // 1) انتظر لحد ما كل Cubit يخلص تحميل (أو timeout بعد 5s)
//   Future<void> waitForLoaded(dynamic cubit, {int timeoutMs = 5000}) async {
//     final start = DateTime.now();
//     while (true) {
//       try {
//         final state = cubit.state;
//         final isLoading = (state as dynamic).isLoading as bool? ?? false;
//         if (!isLoading) return;
//       } catch (_) {
//         // لو الـ state ما فيه isLoading، نعتبره جاهز
//         return;
//       }
//       if (DateTime.now().difference(start).inMilliseconds > timeoutMs) return;
//       await Future.delayed(const Duration(milliseconds: 100));
//     }
//   }

//   await waitForLoaded(clientsCubit);
//   await waitForLoaded(projectsCubit);
//   await waitForLoaded(paymentsCubit);
//   await waitForLoaded(drawingsCubit);

//   // 2) جهّز الـ JSON (تأكد إن كل موديل عنده toJson)
//   final Map<String, dynamic> jsonData = {
//     "clients":
//         (clientsCubit.state as dynamic).clients
//             ?.map((c) => c.toJson())
//             .toList() ??
//         [],
//     "projects":
//         (projectsCubit.state as dynamic).projects
//             ?.map((p) => p.toJson())
//             .toList() ??
//         [],
//     "payments":
//         (paymentsCubit.state as dynamic).payments
//             ?.map((p) => p.toJson())
//             .toList() ??
//         [],
//     "drawings":
//         (drawingsCubit.state as dynamic).drawings
//             ?.map((d) => d.toJson())
//             .toList() ??
//         [],
//   };

//   // 3) حوّل لسلسلة JSON مُنسّقة
//   final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);

//   // 4) اطبع بس بآلية تقطع السلسلة إذا كانت طويلة جداً (Console يقص)
//   void printLong(String text, {int chunkSize = 800}) {
//     for (var i = 0; i < text.length; i += chunkSize) {
//       final end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
//       // استخدم debugPrint عشان Console في Flutter يدعمها أفضل
//       debugPrint(text.substring(i, end));
//     }
//   }

//   // Option: اطبع ملخص أولًا عشان تتأكد إني وصلت للداتا
//   debugPrint('--- EXPORT START ---');
//   debugPrint('clients: ${(jsonData["clients"] as List).length}');
//   debugPrint('projects: ${(jsonData["projects"] as List).length}');
//   debugPrint('payments: ${(jsonData["payments"] as List).length}');
//   debugPrint('drawings: ${(jsonData["drawings"] as List).length}');
//   // ثم اطبع الـ JSON الكامل مقسّم
//   printLong(jsonString);
//   debugPrint('--- EXPORT END ---');
// }
