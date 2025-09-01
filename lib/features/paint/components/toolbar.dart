import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:alrahma/features/paint/cubit/drawing_canvas_cubit.dart';
import 'package:alrahma/core/utils/app_colors.dart';

class DrawingToolbar extends StatefulWidget {
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
  State<DrawingToolbar> createState() => _DrawingToolbarState();
}

class _DrawingToolbarState extends State<DrawingToolbar> {
  late final ScrollController _scrollController;
  late Color selectedColor;

  final List<Color> availableColors = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    selectedColor = widget.cubit.state.selectedColor;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tools = [
      {"icon": Icons.text_fields, "tooltip": "نص", "tool": "text"},
      {"icon": Icons.crop_square, "tooltip": "مستطيل", "tool": "rect"},
      {"icon": Icons.circle_outlined, "tooltip": "دائرة", "tool": "circle"},
      {"icon": Icons.straighten, "tooltip": "خط مستقيم", "tool": "line"},
      {"icon": Icons.create, "tooltip": "حر", "tool": "freehand"},
      // {
      //   "icon": Icons.pan_tool,
      //   "tooltip": "يد / تحريك",
      //   "tool": "hand",
      //   "extra": () =>
      //       widget.cubit.toggleHandTool(!widget.cubit.state.isHandTool),
      // },
      {"icon": Icons.cleaning_services, "tooltip": "ممحاة", "tool": "eraser"},
      {
        "icon": Icons.undo,
        "tooltip": "تراجع",
        "tool": "undo",
        "extra": () => widget.cubit.undo(),
      },
      {
        "icon": Icons.redo,
        "tooltip": "إعادة",
        "tool": "redo",
        "extra": () => widget.cubit.redo(),
      },
      {
        "icon": Icons.clear,
        "tooltip": "مسح الكل",
        "tool": "clear",
        "extra": () => widget.cubit.clearCanvas(),
      },
    ];

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // زر أسود سريع
          GestureDetector(
            onTap: () {
              setState(() {
                selectedColor = Colors.black;
                widget.cubit.changeColor(Colors.black);
              });
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
                      ? AppColors.accentOrange
                      : Colors.grey.shade400,
                  width: 2.w,
                ),
              ),
            ),
          ),

          SizedBox(width: 8.w),

          // Dropdown للألوان الأخرى
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
                          ? AppColors.accentOrange
                          : Colors.grey.shade400,
                      width: 2.w,
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: (color) {
              if (color != null) {
                setState(() {
                  selectedColor = color;
                  widget.cubit.changeColor(color);
                });
              }
            },
          ),

          SizedBox(width: 12.w),

          // أدوات الرسم
          ...tools.reversed.map((t) {
            final isActive =
                widget.cubit.state.tool == (t["tool"] as String) ||
                (t["tool"] == "hand" && widget.cubit.state.isHandTool);

            return IconButton(
              icon: Icon(
                t["icon"] as IconData,
                color: isActive ? AppColors.accentOrange : Colors.black,
                size: 24.sp,
              ),
              tooltip: t["tooltip"] as String,
              onPressed: () {
                final tool = t["tool"] as String;

                if (tool == "eraser") {
                  widget.cubit.changeTool("eraser");
                } else if (t.containsKey("extra")) {
                  (t["extra"] as VoidCallback)();
                } else {
                  widget.cubit.changeTool(tool);
                }
              },
            );
          }).toList(),

          SizedBox(width: 16.w),

          // Slider لتغيير strokeWidth
          SizedBox(
            width: 200.w,
            child: Slider(
              min: 1,
              max: 10,
              activeColor: AppColors.accentOrange,
              value: widget.strokeWidth,
              label: "${widget.strokeWidth.toInt()} px",
              onChanged: widget.onStrokeChanged,
            ),
          ),
        ],
      ),
    );
  }
}
