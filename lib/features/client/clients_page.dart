// lib/features/client/pages/clients_page.dart

import 'package:alrahma/core/database/cache/app_preferences.dart';
import 'package:alrahma/core/funcs/init_and_load_databases.dart';
import 'package:alrahma/core/widgets/custom_app_bar.dart';
import 'package:alrahma/core/widgets/search_bar.dart';
import 'package:alrahma/features/client/card.dart';
import 'package:alrahma/features/client/client_profile_page.dart';
import 'package:alrahma/features/client/cubit/clients_cubit.dart';
import 'package:alrahma/features/client/cubit/clients_state.dart';
import 'package:alrahma/features/client/widgets/funcs/highlight_match.dart';
import 'package:alrahma/features/paint/cubit/drawings_nav_cubit.dart';
import 'package:alrahma/features/paint/repository/drawing_repository.dart';
import 'package:alrahma/features/project/cubit/projects_cubit.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:alrahma/core/widgets/show_confirm_delete_dialog.dart';
import 'package:alrahma/features/home/widgets/build_premium_loader.dart';

import '../../../core/models/client_model.dart';

// ===================== ClientsPage =====================
class ClientsPage extends StatelessWidget {
  ClientsPage({super.key});

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // breakpoint للتابلت — تقدر تعدل القيمة لو تحب
    final bool isTablet = width >= 800;
    // أقصى عرض لكل كارد في الـ Grid
    final double maxCardExtent = isTablet ? 420.w : 350.w;
    // ارتفاع تقريبي للكارد (يتناسب مع الحد الأقصى للعرض)
    final double desiredCardHeight = isTablet ? 140.h : 110.h;
    // نحسب aspect ratio بناءً على max extent وارتفاع الكارد
    final double childAspectRatio = maxCardExtent / desiredCardHeight;

    return RepositoryProvider(
      create: (_) =>
          DrawingRepository(drawingsPrefs: DatabasesNames.drawingsPrefs),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            appBar: customAppBar('العملاء', AppColors.primaryBlue, context),
            body: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // 🔍 Search Bar
                  CustomSearchBar<ClientsCubit, ClientsState>(
                    controller: searchController,
                    hintText: 'ابحث عن عميل...',
                    onSearch: (context, value) {
                      context.read<ClientsCubit>().filterClients(value);
                    },
                    isEmptyResult: (state) => state.filteredClients.isEmpty,
                  ),

                  SizedBox(height: 16.h),

                  // 🔄 Responsive Clients List
                  Expanded(
                    child: BlocBuilder<ClientsCubit, ClientsState>(
                      builder: (context, state) {
                        if (state.isLoading) {
                          return Center(child: buildPremiumLoader());
                        }
                        if (state.filteredClients.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 80.w,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'لا يوجد عملاء',
                                  style: CustomTextStyles.cairoRegular18
                                      .copyWith(fontSize: 18.sp),
                                ),
                              ],
                            ),
                          );
                        }

                        // 👇 responsive Grid / List
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final bool useGrid = constraints.maxWidth >= 600;

                            if (useGrid) {
                              return GridView.builder(
                                padding: EdgeInsets.zero,
                                gridDelegate:
                                    SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: maxCardExtent,
                                      mainAxisSpacing: 12.h,
                                      crossAxisSpacing: 12.w,
                                      childAspectRatio: (width < 600)
                                          ? childAspectRatio // موبايل
                                          : (MediaQuery.of(
                                                      context,
                                                    ).orientation ==
                                                    Orientation.landscape
                                                ? childAspectRatio / 4
                                                : childAspectRatio / 2),
                                    ),
                                itemCount: state.filteredClients.length,
                                itemBuilder: (context, index) {
                                  final client = state.filteredClients[index];
                                  return ClientCard(
                                    client: client,
                                    searchQuery: searchController.text,
                                    minHeight: desiredCardHeight,
                                    isTablet: isTablet,
                                    onEdit: () => showClientDialog(
                                      context: context,
                                      initial: client,
                                      isNew: false,
                                      onSave: (updated) => context
                                          .read<ClientsCubit>()
                                          .editClient(updated),
                                    ),
                                    onDelete: () async {
                                      final confirmed =
                                          await showConfirmDeleteDialog(
                                            context,
                                            itemName: client.name,
                                          );
                                      if (confirmed == true) {
                                        context.read<ClientsCubit>().deleteClient(
                                          client.id,
                                          context, // Pass the BuildContext or the appropriate second argument here
                                        );
                                      }
                                    },
                                    onTap: () async {
                                      final clientsCubit = context
                                          .read<ClientsCubit>();
                                      final drawingsCubit = context
                                          .read<DrawingsCubit>();
                                      final projectsCubit = context
                                          .read<ProjectsCubit>();

                                      await clientsCubit.repository
                                          .saveSelectedClientId(client.id);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (ctx) =>
                                              RepositoryProvider.value(
                                                value: context
                                                    .read<DrawingRepository>(),
                                                child: MultiBlocProvider(
                                                  providers: [
                                                    BlocProvider.value(
                                                      value: projectsCubit,
                                                    ),
                                                    BlocProvider.value(
                                                      value: drawingsCubit,
                                                    ),
                                                  ],
                                                  child: ClientProfilePage(
                                                    client: client,
                                                  ),
                                                ),
                                              ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            } else {
                              // موبايل: ListView عادية
                              return ListView.separated(
                                itemCount: state.filteredClients.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 5.h),
                                itemBuilder: (context, index) {
                                  final client = state.filteredClients[index];
                                  return ClientCard(
                                    client: client,
                                    searchQuery: searchController.text,
                                    isTablet: isTablet,
                                    onEdit: () => showClientDialog(
                                      context: context,
                                      initial: client,
                                      isNew: false,
                                      onSave: (updated) => context
                                          .read<ClientsCubit>()
                                          .editClient(updated),
                                    ),
                                    onDelete: () async {
                                      final confirmed =
                                          await showConfirmDeleteDialog(
                                            context,
                                            itemName: client.name,
                                          );
                                      if (confirmed == true) {
                                        context
                                            .read<ClientsCubit>()
                                            .deleteClient(client.id, context);
                                      }
                                    },
                                    onTap: () async {
                                      final clientsCubit = context
                                          .read<ClientsCubit>();
                                      final drawingsCubit = context
                                          .read<DrawingsCubit>();
                                      final projectsCubit = context
                                          .read<ProjectsCubit>();

                                      await clientsCubit.repository
                                          .saveSelectedClientId(client.id);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              RepositoryProvider.value(
                                                value: context
                                                    .read<DrawingRepository>(),

                                                child: MultiBlocProvider(
                                                  providers: [
                                                    BlocProvider.value(
                                                      value: projectsCubit,
                                                    ),
                                                    BlocProvider.value(
                                                      value: drawingsCubit,
                                                    ),
                                                  ],
                                                  child: ClientProfilePage(
                                                    client: client,
                                                  ),
                                                ),
                                              ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            floatingActionButton: FloatingActionButton(
              backgroundColor: AppColors.primaryBlue,
              onPressed: () {
                final id = DateTime.now().millisecondsSinceEpoch.toString();
                showClientDialog(
                  context: context,
                  initial: ClientModel(
                    id: id,
                    name: '',
                    phone: '',
                    address: '',
                  ),
                  isNew: true,
                  onSave: (updated) =>
                      context.read<ClientsCubit>().addClient(updated),
                );
              },
              child: Icon(Icons.add, color: AppColors.lightGray, size: 28.sp),
            ),
          ),
        ),
      ),
    );
  }
}

// ===================== ClientCard Widget =====================
// ملاحظات: ضفت متغيرات isTablet و minHeight علشان نتحكم بالريسبونسف
class ClientCard extends StatelessWidget {
  final ClientModel client;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final String? searchQuery;
  final bool isTablet;
  final double? minHeight;

  const ClientCard({
    this.searchQuery,
    required this.client,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
    this.isTablet = false,
    this.minHeight,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primaryBlue;
    final bool tablet = isTablet;
    final double avatarRadius = tablet ? 32.w : 25.w;
    final double iconSize = tablet ? 26.sp : 20.sp;
    final double titleSize = tablet ? 18.sp : 16.sp;
    final double subtitleSize = tablet ? 16.sp : 14.sp;
    final double gap = 12.w;

    return GestureDetector(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: minHeight ?? (tablet ? 120.h : 100.h),
        ),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor: color,
                child: Text(
                  client.name.isNotEmpty ? client.name[0] : '?',
                  style: CustomTextStyles.cairoBold20.copyWith(
                    fontSize: tablet ? 20.sp : 16.sp,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: gap),

              // نصوص وبادجات (مرن)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // 👈 مهم جداً
                  children: [
                    // العنوان: سطر واحد + ellipsis
                    // highlightMatch بيرجع Text.rich مع maxLines/ellipsis لو معرف مسبقًا
                    // لو مش معمول فيها maxLines، فعل ellipsis بإحاطة الـ widget
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final maxTitleWidth = constraints.maxWidth;
                        return SizedBox(
                          width: maxTitleWidth,
                          child: DefaultTextStyle(
                            style: CustomTextStyles.cairoBold20.copyWith(
                              fontSize: titleSize,
                              overflow: TextOverflow.ellipsis,
                            ),
                            child: highlightMatch(
                              client.name,
                              searchQuery,
                              style: CustomTextStyles.cairoBold20.copyWith(
                                fontSize: titleSize,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 6.h),

                    // البادجات
                    BlocBuilder<ProjectsCubit, ProjectsState>(
                      builder: (context, projectState) {
                        final projectCount = context
                            .read<ClientsCubit>()
                            .getProjectsCount(context, client.id);
                        final drawingsCount = context
                            .read<ClientsCubit>()
                            .getDrawingsCount(context, client.id);

                        // في التابلت نبين البادجات على سطرين بشكل منظم،
                        // في الموبايل نستخدم Wrap افتراضي
                        if (tablet) {
                          return IntrinsicHeight(
                            child: Row(
                              children: [
                                _buildBadge(
                                  context,
                                  icon: Icons.work_outline,
                                  color: AppColors.primaryBlue,
                                  count: projectCount,
                                  fontSize: subtitleSize,
                                ),
                                SizedBox(width: 8.w),
                                _buildBadge(
                                  context,
                                  icon: Icons.brush_outlined,
                                  color: Colors.orange,
                                  count: drawingsCount,
                                  fontSize: subtitleSize,
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Wrap(
                            spacing: 6.w,
                            runSpacing: 4.h,
                            children: [
                              _buildBadge(
                                context,
                                icon: Icons.work_outline,
                                color: AppColors.primaryBlue,
                                count: projectCount,
                                fontSize: subtitleSize,
                              ),
                              _buildBadge(
                                context,
                                icon: Icons.brush_outlined,
                                color: Colors.orange,
                                count: drawingsCount,
                                fontSize: subtitleSize,
                              ),
                            ],
                          );
                        }
                      },
                    ),

                    SizedBox(height: 8.h),

                    // phone + address responsive (سطر واحد أو اثنين بناءً على المساحة)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final maxLines = tablet ? 2 : 2;
                        return Text(
                          '${client.phone} • ${client.address}',
                          maxLines: maxLines,
                          overflow: TextOverflow.ellipsis,
                          style: CustomTextStyles.cairoRegular16.copyWith(
                            color: Colors.grey[700],
                            fontSize: subtitleSize,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // الأزرار (ثابتة يمين)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Colors.orange,
                      size: iconSize,
                    ),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: iconSize,
                    ),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required int count,
    required double fontSize,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: fontSize * 0.6, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize, color: color),
          SizedBox(width: 6.w),
          Text(
            '$count',
            style: CustomTextStyles.cairoRegular14.copyWith(
              fontSize: fontSize,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
