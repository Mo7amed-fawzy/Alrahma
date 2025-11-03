import 'package:alrahma/features/paint/widgets/tool_shapes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:alrahma/features/paint/cubit/drawing_canvas_cubit.dart';
import 'package:alrahma/core/utils/app_colors.dart';

class DrawingToolbar extends StatelessWidget {
  final DrawingCanvasCubit cubit;
  final double strokeWidth;
  final void Function(double) onStrokeChanged;

  const DrawingToolbar({
    super.key,
    required this.cubit,
    required this.strokeWidth,
    required this.onStrokeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();
    final List<Color> availableColors = [
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
    ];

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (_scrollController.hasClients) {
    //     _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    //   }
    // });

    final tools = [
      // ✨ أضف أيقونة جديدة للأشكال الجاهزة
      {
        "icon": Icons.apps,
        "tooltip": "أشكال جاهزة",
        "tool": "customShapes",
        "extra": () {
          customToolShapes(context, cubit);
        },
      },
      {
        "icon": Icons.photo,
        "tooltip": "إضافة صورة من المعرض",
        "tool": "addGalleryImage",
        "extra": () => cubit.addImage(fromCamera: false),
      },
      {
        "icon": Icons.camera_alt,
        "tooltip": "التقاط صورة بالكاميرا",
        "tool": "addCameraImage",
        "extra": () => cubit.addImage(fromCamera: true),
      },
      {"icon": Icons.crop_square, "tooltip": "مستطيل", "tool": "rect"},
      {"icon": Icons.circle_outlined, "tooltip": "دائرة", "tool": "circle"},
      {"icon": Icons.straighten, "tooltip": "خط مستقيم", "tool": "line"},
      {"icon": Icons.text_fields, "tooltip": "نص", "tool": "text"},
      {"icon": Icons.create, "tooltip": "حر", "tool": "freehand"},
      // ----------------------------------------------------
      // أداة جديدة: تحديد/سحب الصور و النصوص
      {
        "icon": Icons.touch_app,
        "tooltip": "تحديد/تحريك العناصر",
        "tool": "select",
      },
      // ----------------------------------------------------
      {
        "icon": Icons.pan_tool,
        "tooltip": "يد / تحريك الكانفاس",
        "tool": "hand",
        "extra": () => cubit.toggleHandTool(!cubit.state.isHandTool),
      },
      {"icon": Icons.cleaning_services, "tooltip": "ممحاة", "tool": "eraser"},
      {
        "icon": Icons.undo,
        "tooltip": "تراجع",
        "tool": "undo",
        "extra": () => cubit.undo(),
      },
      {
        "icon": Icons.redo,
        "tooltip": "إعادة",
        "tool": "redo",
        "extra": () => cubit.redo(),
      },
      {
        "icon": Icons.clear,
        "tooltip": "مسح الكل",
        "tool": "clear",
        "extra": () => cubit.clearCanvas(),
      },
    ];

    Color selectedColor = cubit.state.selectedColor;

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          GestureDetector(
            onTap: () {
              selectedColor = Colors.black;
              cubit.changeColor(Colors.black);
            },
            child: Container(
              width: 32.w,
              height: 32.h,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selectedColor == Colors.black
                      ? AppColors.primaryBlue
                      : Colors.grey.shade400,
                  width: 2.w,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          DropdownButton<Color>(
            value: selectedColor != Colors.black ? selectedColor : null,
            underline: const SizedBox(),
            items: availableColors.where((c) => c != Colors.black).map((c) {
              return DropdownMenuItem(
                value: c,
                child: Container(
                  width: 24.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selectedColor == c
                          ? AppColors.primaryBlue
                          : Colors.grey.shade400,
                      width: 2.w,
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: (color) {
              if (color != null) {
                selectedColor = color;
                cubit.changeColor(color);
              }
            },
          ),
          SizedBox(width: 12.w),
          ...tools.reversed.map((t) {
            final isActive =
                cubit.state.tool == (t["tool"] as String) ||
                (t["tool"] == "hand" && cubit.state.isHandTool);
            return IconButton(
              icon: Icon(
                t["icon"] as IconData,
                color: isActive ? AppColors.primaryBlue : Colors.black,
                size: 24.sp,
              ),
              tooltip: t["tooltip"] as String,
              onPressed: () {
                final tool = t["tool"] as String;
                if (tool == "eraser") {
                  cubit.changeTool("eraser");
                } else if (t.containsKey("extra")) {
                  (t["extra"] as VoidCallback)();
                } else {
                  cubit.changeTool(tool);
                }
              },
            );
          }).toList(),
          SizedBox(width: 16.w),
          SizedBox(
            width: 200.w,
            child: Slider(
              min: 1,
              max: 10,
              activeColor: AppColors.primaryBlue,
              value: strokeWidth,
              label: "$strokeWidth px",
              onChanged: onStrokeChanged,
            ),
          ),
        ],
      ),
    );
  }
}
