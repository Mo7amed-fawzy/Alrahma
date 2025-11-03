import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/features/paint/cubit/drawing_canvas_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> customToolShapes(BuildContext context, DrawingCanvasCubit cubit) {
  return showModalBottomSheet(
    context: context,
    builder: (_) {
      return Container(
        padding: EdgeInsets.all(16.w),
        height: 250.h,
        child: GridView.count(
          crossAxisCount: 3,
          children: [
            _buildShapeOption(
              icon: Icons.door_front_door,
              label: "باب بمقبض",
              isActive: cubit.state.tool == "door",
              onTap: () {
                Navigator.pop(context);
                cubit.changeTool("door");
              },
            ),
            _buildShapeOption(
              icon: Icons.window,
              label: "شباك بحواف",
              isActive: cubit.state.tool == "window",
              onTap: () {
                Navigator.pop(context);
                cubit.changeTool("window");
              },
            ),
            _buildShapeOption(
              icon: Icons.house_siding,
              label: "شباك بنوافذ",
              isActive: cubit.state.tool == "custom1",
              onTap: () {
                Navigator.pop(context);
                cubit.changeTool("custom1");
              },
            ),
            _buildShapeOption(
              icon: Icons.window_rounded,
              label: "شباك منغلق",
              isActive: cubit.state.tool == "custom2",
              onTap: () {
                Navigator.pop(context);
                cubit.changeTool("custom2");
              },
            ),
            _buildShapeOption(
              icon: Icons.window_rounded,
              label: "شباك منغلق مزدوج",
              isActive: cubit.state.tool == "custom3",
              onTap: () {
                Navigator.pop(context);
                cubit.changeTool("custom3");
              },
            ),
            _buildShapeOption(
              icon: Icons.width_normal_rounded,
              label: "شباك بنوافذ علوية",
              isActive: cubit.state.tool == "custom4",
              onTap: () {
                Navigator.pop(context);
                cubit.changeTool("custom4");
              },
            ),
            _buildShapeOption(
              icon: Icons.width_normal_rounded,
              label: "شباك بنوافذ سفلية",
              isActive: cubit.state.tool == "custom5",
              onTap: () {
                Navigator.pop(context);
                cubit.changeTool("custom5");
              },
            ),
            _buildShapeOption(
              icon: Icons.width_normal_outlined,
              label: "شباك ٤ نوافذ علوية",
              isActive: cubit.state.tool == "custom6",
              onTap: () {
                Navigator.pop(context);
                cubit.changeTool("custom6");
              },
            ),
            _buildShapeOption(
              icon: Icons.door_sliding_sharp,
              label: " باب بشبابيك",
              isActive: cubit.state.tool == "custom7",
              onTap: () {
                Navigator.pop(context);
                cubit.changeTool("custom7");
              },
            ),
            _buildShapeOption(
              icon: Icons.door_sliding_outlined,
              label: "باب فلات",
              isActive: cubit.state.tool == "custom8",
              onTap: () {
                Navigator.pop(context);
                cubit.changeTool("custom8");
              },
            ),
            _buildShapeOption(
              icon: Icons.space_dashboard_sharp,
              label: "باب دولاب",
              isActive: cubit.state.tool == "custom9",
              onTap: () {
                Navigator.pop(context);
                cubit.changeTool("custom9");
              },
            ),
            _buildShapeOption(
              icon: Icons.space_dashboard,
              label: "باب دولاب بالعكس ",
              isActive: cubit.state.tool == "custom10",
              onTap: () {
                Navigator.pop(context);
                cubit.changeTool("custom10");
              },
            ),
            _buildShapeOption(
              icon: Icons.width_full_rounded,
              label: " شباك بسطح مستوي",
              isActive: cubit.state.tool == "custom11",
              onTap: () {
                Navigator.pop(context);
                cubit.changeTool("custom11");
              },
            ),
            _buildShapeOption(
              icon: Icons.width_normal_outlined,
              label: "شباك بحواف متعددة",
              isActive: cubit.state.tool == "custom12",
              onTap: () {
                Navigator.pop(context);
                cubit.changeTool("custom12");
              },
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildShapeOption({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  bool isActive = false,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Material(
        color: isActive ? AppColors.primaryBlue : Colors.grey.shade200,
        shape: const CircleBorder(),
        elevation: isActive ? 4 : 2,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          splashColor: AppColors.primaryBlue.withOpacity(0.3),
          child: SizedBox(
            width: 60.r,
            height: 60.r,
            child: Icon(
              icon,
              size: 28.sp,
              color: isActive ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
      SizedBox(height: 8.h),
      Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          color: isActive ? AppColors.primaryBlue : Colors.black,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ],
  );
}
