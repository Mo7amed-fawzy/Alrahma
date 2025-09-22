import 'package:alrahma/features/client/repo/clients_repository.dart';
import 'package:alrahma/features/home/cubit/theme_cubit.dart';
import 'package:alrahma/features/home/widgets/home_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrahma/core/funcs/init_and_load_databases.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:alrahma/features/client/cubit/clients_cubit.dart';
import 'package:alrahma/features/home/cubit/home_cubit.dart';
import 'package:alrahma/features/home/widgets/build_premium_loader.dart';
import 'package:alrahma/features/home/widgets/build_stat_card.dart';
import 'package:alrahma/features/home/widgets/funcs/load_home_stats.dart';
import 'package:alrahma/features/home/widgets/pressable_card.dart';
import 'package:alrahma/features/splash_trail/welcome.dart';
import 'package:alrahma/features/paint/cubit/drawings_nav_cubit.dart';
import 'package:alrahma/features/client/clients_page.dart';
import 'package:alrahma/features/payment/cubit/payments_cubit.dart';
import 'package:alrahma/features/project/cubit/projects_cubit.dart';
import 'package:alrahma/features/payment/payments_page.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeCubit()..loadData()),
        BlocProvider(
          create: (_) => PaymentsCubit(
            paymentsPrefs: DatabasesNames.paymentsPrefs,
            projectsPrefs: DatabasesNames.projectsPrefs,
            clientsPrefs: DatabasesNames.clientsPrefs,
          )..loadPayments(),
        ),
        BlocProvider(
          create: (_) => ProjectsCubit(
            projectsPrefs: DatabasesNames.projectsPrefs,
            clientsPrefs: DatabasesNames.clientsPrefs,
          )..loadProjects(),
        ),
        BlocProvider(
          create: (context) => ClientsCubit(
            repository: ClientsRepository(
              drawingsPrefs: DatabasesNames.drawingsPrefs,
              projectsPrefs: DatabasesNames.projectsPrefs,
              clientsPrefs: DatabasesNames.clientsPrefs,
            ),
            projectsCubit: context.read<ProjectsCubit>(),
            paymentsCubit: context.read<PaymentsCubit>(),
          )..loadAllData(),
        ),
        BlocProvider(
          create: (_) => DrawingsCubit(
            drawingsPrefs: DatabasesNames.drawingsPrefs,
            projectsPrefs: DatabasesNames.projectsPrefs,
            clientPrefs: DatabasesNames.clientsPrefs,
          )..loadDrawings(),
        ),
      ],
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Scaffold(body: Center(child: buildPremiumLoader()));
          }

          final width = MediaQuery.of(context).size.width;
          final gridPadding = 20.0;
          double cardWidth = (width / 2) - (gridPadding * 1.5);
          if (cardWidth > 300) cardWidth = 300;
          if (cardWidth < 140) cardWidth = 140;

          final iconSize = cardWidth * 0.35;
          final textSize = cardWidth * 0.15;

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  'لوحة التحكم',
                  style: CustomTextStyles.cairoBold20.copyWith(
                    color: Colors.white,
                    fontSize: textSize * 0.9,
                  ),
                ),
                centerTitle: true,
                elevation: 4,
                backgroundColor: AppColors.primaryBlue,
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  await context.read<HomeCubit>().refreshAll(context);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(gridPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const WelcomeMessage(),

                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: gridPadding,
                          mainAxisSpacing: gridPadding,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: cardWidth / (cardWidth * 1.1),
                          children: [
                            // العملاء
                            PressableCard(
                              title: 'معلومات العميل',
                              icon: Icons.badge,
                              color: AppColors.primaryBlue,
                              iconSize: iconSize,
                              textSize: textSize,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider.value(
                                          value: context.read<ClientsCubit>(),
                                        ),
                                        BlocProvider.value(
                                          value: context.read<ProjectsCubit>(),
                                        ),
                                        BlocProvider.value(
                                          value: context.read<PaymentsCubit>(),
                                        ),
                                        BlocProvider.value(
                                          value: context.read<DrawingsCubit>(),
                                        ),
                                      ],
                                      child: ClientsPage(),
                                    ),
                                  ),
                                );
                              },
                            ),

                            // المدفوعات
                            PressableCard(
                              title: 'المدفوعات',
                              icon: Icons.payments_outlined,
                              color: AppColors.alrahmaSecondColor,
                              iconSize: iconSize,
                              textSize: textSize,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider.value(
                                          value: context.read<ClientsCubit>(),
                                        ),
                                        BlocProvider.value(
                                          value: context.read<ProjectsCubit>(),
                                        ),
                                        BlocProvider.value(
                                          value: context.read<PaymentsCubit>(),
                                        ),
                                        BlocProvider.value(
                                          value: context.read<DrawingsCubit>(),
                                        ),
                                      ],
                                      child: const PaymentsPageContent(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        FutureBuilder<Map<String, int>>(
                          future: loadHomeStats(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return buildPremiumLoader();
                            }
                            final stats = snapshot.data!;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                buildStatCard(
                                  'العملاء',
                                  '${stats['clients']}',
                                  AppColors.primaryBlue,
                                ),
                                buildStatCard(
                                  'مشاريع جارية',
                                  '${stats['projects']}',
                                  AppColors.secondaryGolden,
                                ),
                                buildStatCard(
                                  'مدفوعات مستلمة',
                                  '${stats['payments']}',
                                  AppColors.alrahmaSecondColor,
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 20),
                        DashboardScreen(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
