// import 'package:flutter/material.dart';
// import 'package:alrahma/core/utils/app_colors.dart';
// import 'package:alrahma/core/utils/custom_text_styles.dart';

// void showTrialReminderDialog(BuildContext context, int remainingDays) {
//   showDialog(
//     context: context,
//     barrierDismissible: false, // يمنع الإغلاق بالضغط خارج الـ dialog
//     builder: (context) => Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       backgroundColor: AppColors.primaryBlue, // نفس اللون
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'تذكير بانتهاء الفترة المجانية',
//               style: CustomTextStyles.cairoBold24.copyWith(color: Colors.white),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'باقي $remainingDays يوم${remainingDays == 1 ? '' : 'ان'} فقط على انتهاء فترة التجربة.',
//               textAlign: TextAlign.center,
//               style: CustomTextStyles.cairoRegular16.copyWith(
//                 color: Colors.white70,
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white,
//                 foregroundColor: AppColors.primaryBlue,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.of(context).pop(); // يقفل الرسالة بس
//               },
//               child: Text(
//                 'موافق',
//                 style: CustomTextStyles.cairoBold20.copyWith(
//                   color: AppColors.primaryBlue,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
