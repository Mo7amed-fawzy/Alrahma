import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrahma/features/payment/cubit/payments_cubit.dart';
import 'package:alrahma/features/project/cubit/projects_cubit.dart';
import 'package:alrahma/features/client/cubit/clients_cubit.dart';
import 'package:alrahma/features/payment/payments_page.dart';
import 'package:alrahma/features/client/clients_page.dart';
import 'package:alrahma/core/models/payment_model.dart';
import 'package:alrahma/core/models/project_model.dart';
import 'package:alrahma/core/models/client_model.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:alrahma/core/utils/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  final IconButton? iconButton;

  const DashboardScreen({super.key, this.iconButton});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // final paymentsCubit = context.read<PaymentsCubit>();
    // final projectsCubit = context.read<ProjectsCubit>();
    // final clientsCubit = context.read<ClientsCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "لوحة المتابعة",
              style: CustomTextStyles.cairoBold24.copyWith(
                color: AppColors.alrahmaprimaryColor,
              ),
            ),
            const Spacer(),
            // iconButton,
          ],
        ),
        const SizedBox(height: 16),
        OverduePaymentsSection(screenWidth: screenWidth),
        ActiveClientsSection(screenWidth: screenWidth),
        RecentPaymentsSection(screenWidth: screenWidth),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ---------------- Sections ----------------

class OverduePaymentsSection extends StatelessWidget {
  final double screenWidth;
  const OverduePaymentsSection({super.key, required this.screenWidth});

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final paymentsCubit = context.watch<PaymentsCubit>();
    final payments = paymentsCubit.state.payments;
    final projects = paymentsCubit.state.projects;
    final clients = paymentsCubit.state.clients;
    final now = DateTime.now();

    final overdue = <Map<String, dynamic>>[];

    for (final proj in projects) {
      final remaining = paymentsCubit.calculateRemainingForProject(
        proj.id,
        payments,
      );
      if (remaining <= 0) continue;

      final projPayments = payments
          .where((p) => p.projectId == proj.id)
          .toList();
      DateTime? last;
      if (projPayments.isNotEmpty) {
        last = projPayments
            .map((p) => p.datePaid)
            .reduce((a, b) => a.isAfter(b) ? a : b);
      }
      last ??= proj.createdAt;

      final days = now.difference(last).inDays;
      if (days > 7) {
        final client = clients.firstWhere(
          (c) => c.id == proj.clientId,
          orElse: () =>
              ClientModel(id: '', name: 'غير معروف', phone: '', address: ''),
        );
        overdue.add({
          'project': proj,
          'client': client,
          'remaining': remaining,
          'lastPaid': last,
          'days': days,
        });
      }
    }

    if (overdue.isEmpty) return const SizedBox.shrink();

    return _buildSectionWrapper(
      title: "تذكيرات: مدفوعات متأخرة",
      color: AppColors.errorRed,
      child: Column(
        children: overdue.map((item) {
          final proj = item['project'] as ProjectModel;
          final client = item['client'] as ClientModel;
          final remaining = item['remaining'] as double;
          final lastPaid = item['lastPaid'] as DateTime;
          final days = item['days'] as int;

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: days > 1 ? AppColors.accentOrange : AppColors.accentOrange,
            margin: const EdgeInsets.symmetric(vertical: 6),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: days > 14
                    ? AppColors.errorRed
                    : AppColors.secondaryGolden,
                child: Text(
                  proj.type.isNotEmpty ? proj.type[0] : '?',
                  style: CustomTextStyles.buttonText,
                ),
              ),
              title: Text(
                '${proj.type} • ${client.name}',
                style: CustomTextStyles.cairoSemiBold16,
              ),
              subtitle: Text(
                'المتبقي: ${remaining.toStringAsFixed(2)} • آخر دفع: ${_formatDate(lastPaid)} • ($days يوم)',
                style: CustomTextStyles.cairoRegular14,
              ),
              trailing: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                ),
                child: const Text('عرض'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: paymentsCubit,
                        child: const PaymentsPageContent(),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ActiveClientsSection extends StatelessWidget {
  final double screenWidth;
  const ActiveClientsSection({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    final projectsCubit = context.watch<ProjectsCubit>();
    final paymentsCubit = context.watch<PaymentsCubit>();
    final clients = paymentsCubit.state.clients;
    final projects = projectsCubit.state.projects;

    final activeClients = <Map<String, dynamic>>[];

    for (final client in clients) {
      final clientProjects = projects
          .where((p) => p.clientId == client.id)
          .toList();
      final projectCount = clientProjects.length;

      bool hasOpen = clientProjects.any((p) {
        final rem = paymentsCubit.calculateRemainingForProject(
          p.id,
          paymentsCubit.state.payments,
        );
        return rem > 0;
      });

      bool recentPayment = paymentsCubit.state.payments.any((p) {
        final proj = projects.firstWhere(
          (pr) => pr.id == p.projectId,
          orElse: () => ProjectModel(
            id: '',
            clientId: '',
            type: 'غير معروف',
            description: '',
            createdAt: DateTime.now(),
          ),
        );
        if (proj.clientId != client.id) return false;
        return DateTime.now().difference(p.datePaid).inDays <= 7;
      });

      if (projectCount > 3 || hasOpen || recentPayment) {
        activeClients.add({
          'client': client,
          'projectCount': projectCount,
          'hasOpen': hasOpen,
          'recentPayment': recentPayment,
        });
      }
    }

    if (activeClients.isEmpty) return const SizedBox.shrink();

    return _buildSectionWrapper(
      title: "عملاء نشطين",
      color: AppColors.alrahmaSecondColor,
      child: Column(
        children: activeClients.map((it) {
          final client = it['client'] as ClientModel;
          final projectCount = it['projectCount'] as int;
          final hasOpen = it['hasOpen'] as bool;
          final recentPayment = it['recentPayment'] as bool;

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 6),
            elevation: 2,
            child: ListTile(
              title: Text(client.name, style: CustomTextStyles.cairoSemiBold16),
              subtitle: Text(
                'مشاريع: $projectCount • مفتوح: ${hasOpen ? "نعم" : "لا"} • دفعات حديثة: ${recentPayment ? "نعم" : "لا"}',
                style: CustomTextStyles.cairoRegular14,
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.person,
                  color: AppColors.alrahmaprimaryColor,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ClientsCubit>(),
                        child: ClientsPage(),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class RecentPaymentsSection extends StatelessWidget {
  final double screenWidth;
  final int limit;
  const RecentPaymentsSection({
    super.key,
    required this.screenWidth,
    this.limit = 5,
  });

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final paymentsCubit = context.watch<PaymentsCubit>();
    final payments = paymentsCubit.state.payments;
    final projects = paymentsCubit.state.projects;
    final clients = paymentsCubit.state.clients;

    if (payments.isEmpty) return const SizedBox.shrink();

    final sorted = List<PaymentModel>.from(payments)
      ..sort((a, b) => b.datePaid.compareTo(a.datePaid));
    final recent = sorted.take(limit).toList();

    return _buildSectionWrapper(
      title: "آخر المدفوعات",
      color: AppColors.alrahmaSecondColor,
      child: Column(
        children: recent.map((p) {
          final proj = projects.firstWhere(
            (pr) => pr.id == p.projectId,
            orElse: () => ProjectModel(
              id: '',
              clientId: '',
              type: 'غير معروف',
              description: '',
              createdAt: DateTime.now(),
            ),
          );
          final client = clients.firstWhere(
            (c) => c.id == proj.clientId,
            orElse: () =>
                ClientModel(id: '', name: 'غير معروف', phone: '', address: ''),
          );
          final dateStr = _formatDate(p.datePaid);

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 6),
            elevation: 2,
            child: ListTile(
              title: Text(
                '${proj.type} • ${client.name}',
                style: CustomTextStyles.cairoSemiBold16,
              ),
              subtitle: Text(
                'المدفوع: ${p.amountPaid.toStringAsFixed(2)} • $dateStr',
                style: CustomTextStyles.cairoRegular14,
              ),
              trailing: Text(
                p.amountTotal.toStringAsFixed(2),
                style: CustomTextStyles.cairoSemiBold16.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------- Helper Widget ----------------

Widget _buildSectionWrapper({
  required String title,
  required Color color,
  required Widget child,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            width: 6,
            height: 24,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: CustomTextStyles.cairoBold20.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      child,
      const SizedBox(height: 16),
    ],
  );
}
