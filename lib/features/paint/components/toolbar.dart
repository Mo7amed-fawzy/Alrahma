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
      // ✨ أضف أيقونة جديدة للأشكال الجاهزة
      {
        "icon": Icons.apps, // ممكن تغيرها لأيقونة أنسب
        "tooltip": "أشكال جاهزة",
        "tool": "customShapes",
        "extra": () {
          showModalBottomSheet(
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
                      isActive: widget.cubit.state.tool == "door",
                      onTap: () {
                        Navigator.pop(context);
                        widget.cubit.changeTool("door");
                      },
                    ),

                    _buildShapeOption(
                      icon: Icons.window,
                      label: "شباك بحواف",
                      isActive: widget.cubit.state.tool == "window",
                      onTap: () {
                        Navigator.pop(context);
                        widget.cubit.changeTool("window");
                      },
                    ),
                    _buildShapeOption(
                      icon: Icons.house_siding,
                      label: "شباك بنوافذ",
                      isActive: widget.cubit.state.tool == "custom1",

                      onTap: () {
                        Navigator.pop(context);
                        widget.cubit.changeTool("custom1");
                      },
                    ),
                    _buildShapeOption(
                      icon: Icons.window_rounded,
                      label: "شباك منغلق",
                      isActive: widget.cubit.state.tool == "custom2",

                      onTap: () {
                        Navigator.pop(context);
                        widget.cubit.changeTool("custom2");
                      },
                    ),
                    _buildShapeOption(
                      icon: Icons.window_rounded,
                      label: "شباك منغلق مزدوج",
                      isActive: widget.cubit.state.tool == "custom3",

                      onTap: () {
                        Navigator.pop(context);
                        widget.cubit.changeTool("custom3");
                      },
                    ),
                    _buildShapeOption(
                      icon: Icons.width_normal_rounded,
                      label: "شباك بنوافذ علوية",
                      isActive: widget.cubit.state.tool == "custom4",

                      onTap: () {
                        Navigator.pop(context);
                        widget.cubit.changeTool("custom4");
                      },
                    ),
                    _buildShapeOption(
                      icon: Icons.width_normal_rounded,
                      label: "شباك بنوافذ سفلية",
                      isActive: widget.cubit.state.tool == "custom5",

                      onTap: () {
                        Navigator.pop(context);
                        widget.cubit.changeTool("custom5");
                      },
                    ),
                    _buildShapeOption(
                      icon: Icons.width_normal_outlined,
                      label: "شباك ٤ نوافذ علوية",
                      isActive: widget.cubit.state.tool == "custom6",

                      onTap: () {
                        Navigator.pop(context);
                        widget.cubit.changeTool("custom6");
                      },
                    ),
                    _buildShapeOption(
                      icon: Icons.door_sliding_sharp,

                      label: " باب بشبابيك",
                      isActive: widget.cubit.state.tool == "custom7",

                      onTap: () {
                        Navigator.pop(context);
                        widget.cubit.changeTool("custom7");
                      },
                    ),
                    _buildShapeOption(
                      icon: Icons.door_sliding_outlined,

                      label: "باب فلات",
                      isActive: widget.cubit.state.tool == "custom8",

                      onTap: () {
                        Navigator.pop(context);
                        widget.cubit.changeTool("custom8");
                      },
                    ),
                    _buildShapeOption(
                      icon: Icons.space_dashboard_sharp,
                      label: "باب دولاب",
                      isActive: widget.cubit.state.tool == "custom9",

                      onTap: () {
                        Navigator.pop(context);
                        widget.cubit.changeTool("custom9");
                      },
                    ),
                    _buildShapeOption(
                      icon: Icons.space_dashboard,
                      label: "باب دولاب بالعكس ",
                      isActive: widget.cubit.state.tool == "custom10",
                      onTap: () {
                        Navigator.pop(context);
                        widget.cubit.changeTool("custom10");
                      },
                    ),
                    _buildShapeOption(
                      icon: Icons.width_full_rounded,
                      label: " شباك بسطح مستوي",
                      isActive: widget.cubit.state.tool == "custom11",

                      onTap: () {
                        Navigator.pop(context);
                        widget.cubit.changeTool("custom11");
                      },
                    ),
                    _buildShapeOption(
                      icon: Icons.width_normal_outlined,
                      label: "شباك بحواف متعددة",
                      isActive: widget.cubit.state.tool == "custom12",

                      onTap: () {
                        Navigator.pop(context);
                        widget.cubit.changeTool("custom12");
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      },

      {"icon": Icons.crop_square, "tooltip": "مستطيل", "tool": "rect"},
      {"icon": Icons.circle_outlined, "tooltip": "دائرة", "tool": "circle"},
      {"icon": Icons.straighten, "tooltip": "خط مستقيم", "tool": "line"},
      {"icon": Icons.text_fields, "tooltip": "نص", "tool": "text"},

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
                      ? AppColors.primaryBlue
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
                color: isActive ? AppColors.primaryBlue : Colors.black,
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
              activeColor: AppColors.primaryBlue,
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
