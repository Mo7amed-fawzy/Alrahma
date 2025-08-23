import 'package:flutter/material.dart';

class TrialExpiredPage extends StatelessWidget {
  const TrialExpiredPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AlertDialog(
          title: const Text("انتهت فترة التجربة"),
          content: const Text(
            "عفواً، انتهت فترة التجربة المجانية لمدة 7 أيام.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                // غلق التطبيق أو العودة للخارج
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        ),
      ),
    );
  }
}
