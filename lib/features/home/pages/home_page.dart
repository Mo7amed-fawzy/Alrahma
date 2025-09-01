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
import 'package:alrahma/features/paint/screens/drawings_page.dart';
import 'package:alrahma/features/client/clients_page.dart';
import 'package:alrahma/features/payment/cubit/payments_cubit.dart';
import 'package:alrahma/features/project/cubit/projects_cubit.dart';
import 'package:alrahma/features/payment/payments_page.dart';
import 'package:alrahma/features/project/projects_page.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit()..loadData(),
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
              body: Padding(
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
                        PressableCard(
                          title: 'العملاء',
                          icon: Icons.people,
                          color: AppColors.primaryBlue,
                          iconSize: iconSize,
                          textSize: textSize,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider(
                                  create: (context) => ClientsCubit(
                                    clientsPrefs: DatabasesNames.clientsPrefs,
                                  ),
                                  child: const ClientsPageContent(),
                                ),
                              ),
                            );
                          },
                        ),
                        PressableCard(
                          title: 'المشاريع',
                          icon: Icons.work_outline,
                          color: AppColors.secondaryGolden,
                          iconSize: iconSize,
                          textSize: textSize,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider(
                                  create: (context) => ProjectsCubit(
                                    projectsPrefs: DatabasesNames.projectsPrefs,
                                    clientsPrefs: DatabasesNames.clientsPrefs,
                                  ),
                                  child: const ProjectsPageContent(),
                                ),
                              ),
                            );
                          },
                        ),
                        PressableCard(
                          title: 'المدفوعات',
                          icon: Icons.payments_outlined,
                          color: AppColors.successGreen,
                          iconSize: iconSize,
                          textSize: textSize,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider(
                                  create: (_) => PaymentsCubit(
                                    paymentsPrefs: DatabasesNames.paymentsPrefs,
                                    projectsPrefs: DatabasesNames.projectsPrefs,
                                    clientsPrefs: DatabasesNames.clientsPrefs,
                                  ),
                                  child: const PaymentsPageContent(),
                                ),
                              ),
                            );
                          },
                        ),
                        PressableCard(
                          title: 'الرسومات',
                          icon: Icons.draw_outlined,
                          color: AppColors.accentOrange,
                          iconSize: iconSize,
                          textSize: textSize,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider(
                                  create: (_) => DrawingsCubit(
                                    drawingsPrefs: DatabasesNames.drawingsPrefs,
                                    projectsPrefs: DatabasesNames.projectsPrefs,
                                    clientPrefs: DatabasesNames.clientsPrefs,
                                  )..load(),
                                  child: const DrawingsPage(),
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
                              'عملاء اليوم',
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
                              AppColors.successGreen,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
