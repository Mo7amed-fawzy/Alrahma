import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/features/payment/cubit/payments_cubit.dart';
import 'package:flutter/material.dart';

class RemainingCard extends StatefulWidget {
  final TextEditingController totalCtrl;
  final TextEditingController paidCtrl;
  final double screenWidth;
  final PaymentsCubit cubit;
  final String projectId; // 🔹 أضف ده

  const RemainingCard({
    super.key,
    required this.totalCtrl,
    required this.paidCtrl,
    required this.cubit,
    required this.screenWidth,
    required this.projectId, // 🔹 هنا برضه
  });

  @override
  _RemainingCardState createState() => _RemainingCardState();
}

class _RemainingCardState extends State<RemainingCard> {
  late VoidCallback _totalListener;
  late VoidCallback _paidListener;

  double _remaining = 0.0;

  @override
  void initState() {
    super.initState();
    _computeRemaining();

    _totalListener = () => _computeRemaining();
    _paidListener = () => _computeRemaining();

    widget.totalCtrl.addListener(_totalListener);
    widget.paidCtrl.addListener(_paidListener);
  }

  void _computeRemaining() {
    final total = double.tryParse(widget.totalCtrl.text) ?? 0.0;

    // المدفوع القديم (history + آخر قيمة مدفوعة محفوظة)
    final paidFromHistory = widget.cubit.calculatePaidForProject(
      widget.projectId,
      widget.cubit.state.payments,
    );

    // المدفوع الجديد اللي المستخدم بيكتبه في TextField
    final localPaid = double.tryParse(widget.paidCtrl.text) ?? 0.0;

    // مجموعهم
    final totalPaid = paidFromHistory + localPaid;

    final r = total - totalPaid;
    final newVal = r < 0 ? 0.0 : r;

    if (newVal != _remaining) {
      setState(() => _remaining = newVal);
    }
  }

  @override
  void dispose() {
    widget.totalCtrl.removeListener(_totalListener);
    widget.paidCtrl.removeListener(_paidListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.alrahmaSecondColor.withOpacity(0.6),
          width: 1.2,
        ),
      ),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.screenWidth * 0.05,
          vertical: widget.screenWidth * 0.03,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // الرقم على الشمال
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: Text(
                "ج.م${_remaining.toStringAsFixed(2)}",
                key: ValueKey<double>(_remaining),
                style: TextStyle(
                  fontSize: widget.screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                  color: AppColors.alrahmaSecondColor,
                ),
              ),
            ),

            // النص + الأيقونة على اليمين
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ":المتبقي",
                  style: TextStyle(
                    fontSize: widget.screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    color: AppColors.alrahmaSecondColor,
                  ),
                ),
                const SizedBox(width: 4), // مسافة صغيرة بين النص والأيقونة
                Icon(
                  Icons.calculate,
                  color: AppColors.alrahmaSecondColor,
                  size: widget.screenWidth * 0.07,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
