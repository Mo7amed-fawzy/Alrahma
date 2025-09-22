// import 'package:flutter/material.dart';
// import 'package:alrahma/core/utils/app_colors.dart';
// import 'package:alrahma/core/utils/custom_text_styles.dart';

// /// Dialog لإدخال رقم التفعيل/الرقم السري للجهاز
// void showDeviceCodeDialog(
//   BuildContext context, {
//   required Function(String code) onSubmit, // الفعل لما يضغط المستخدم "تأكيد"
// }) {
//   final TextEditingController _controller = TextEditingController();

//   showDialog(
//     context: context,
//     barrierDismissible: false, // يمنع الإغلاق بالضغط خارج الـ dialog
//     builder: (context) => Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       backgroundColor: AppColors.primaryBlue, // لون متوافق مع الهوم
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'أدخل رقم التفعيل',
//               style: CustomTextStyles.cairoBold24.copyWith(color: Colors.white),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'أدخل الرقم الذي حصلت عليه لتفعيل التطبيق على جهازك.',
//               textAlign: TextAlign.center,
//               style: CustomTextStyles.cairoRegular16.copyWith(
//                 color: Colors.white70,
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _controller,
//               keyboardType: TextInputType.number,
//               style: CustomTextStyles.cairoBold20.copyWith(color: Colors.white),
//               decoration: InputDecoration(
//                 hintText: 'أدخل الرقم هنا',
//                 hintStyle: CustomTextStyles.cairoRegular16.copyWith(
//                   color: Colors.white54,
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.white54),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.white),
//                 ),
//                 filled: true,
//                 fillColor: AppColors.primaryBlue.withOpacity(0.2),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: AppColors.primaryBlue,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     onPressed: () {
//                       final code = _controller.text.trim();
//                       if (code.isNotEmpty) {
//                         Navigator.of(context).pop(); // غلق الـ dialog
//                         onSubmit(code); // إعادة الرقم للفعل المطلوب
//                       }
//                     },
//                     child: Text(
//                       'تأكيد',
//                       style: CustomTextStyles.cairoBold20.copyWith(
//                         color: AppColors.primaryBlue,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white24,
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     onPressed: () {
//                       Navigator.of(context).pop(); // غلق الـ dialog بدون فعل
//                     },
//                     child: Text(
//                       'إلغاء',
//                       style: CustomTextStyles.cairoBold20.copyWith(
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
