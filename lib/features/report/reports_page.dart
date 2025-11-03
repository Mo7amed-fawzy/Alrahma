import 'package:alrahma/features/report/cubit/reports_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportsCubit()..loadReports(),
      child: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          if (state.loading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            appBar: AppBar(
              title: const Text('التقارير'),
              backgroundColor: AppColors.accentOrange,
              centerTitle: true,
              elevation: 4,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// 🟠 كروت إحصائيات من الـ state
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard(
                        "إجمالي العملاء",
                        "${state.clientsCount}",
                        Icons.people_alt,
                        AppColors.accentOrange,
                      ),
                      _buildStatCard(
                        "المشاريع الجارية",
                        "${state.projectsCount}",
                        Icons.work_outline,
                        AppColors.secondaryGolden,
                      ),
                      _buildStatCard(
                        "إجمالي المدفوعات",
                        "${state.paymentsCount}",
                        Icons.payments_outlined,
                        AppColors.errorRed,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  /// 🟡 عنوان الرسم البياني
                  Text(
                    "النمو الشهري",
                    style: CustomTextStyles.cairoBold20,
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 12),

                  /// 📊 رسم بياني
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: BarChart(
                          BarChartData(
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  getTitlesWidget: (value, meta) {
                                    const months = [
                                      "ينا",
                                      "فبر",
                                      "مارس",
                                      "أبريل",
                                      "مايو",
                                      "يونيو",
                                    ];
                                    if (value.toInt() < months.length) {
                                      return Text(
                                        months[value.toInt()],
                                        style: CustomTextStyles.cairoRegular14,
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                ),
                              ),
                            ),
                            barGroups: [
                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(
                                    toY: state.clientsCount.toDouble(),
                                    color: AppColors.accentOrange,
                                    width: 20,
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 1,
                                barRods: [
                                  BarChartRodData(
                                    toY: state.projectsCount.toDouble(),
                                    color: AppColors.secondaryGolden,
                                    width: 20,
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 2,
                                barRods: [
                                  BarChartRodData(
                                    toY: state.paymentsCount.toDouble(),
                                    color: AppColors.errorRed,
                                    width: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              value,
              style: CustomTextStyles.cairoBold24.copyWith(color: Colors.white),
            ),
            Text(
              title,
              style: CustomTextStyles.cairoRegular14.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
