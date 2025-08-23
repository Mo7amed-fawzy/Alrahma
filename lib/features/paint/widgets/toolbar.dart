import 'package:flutter/material.dart';
import 'package:tabea/features/paint/cubit/drawing_canvas_cubit.dart';
import 'package:tabea/core/utils/app_colors.dart';
import 'build_color_button.dart';

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
    final colors = [Colors.black, Colors.red, Colors.blue, Colors.green];
    final tools = [
      {"icon": Icons.create, "tooltip": "حر", "tool": "freehand"},
      {
        "icon": Icons.straighten,
        "tooltip": "خط مستقيم",
        "tool": "line",
        "extra": () => cubit.toggleStraightLine(),
      },
      {"icon": Icons.crop_square, "tooltip": "مستطيل", "tool": "rect"},
      {"icon": Icons.circle, "tooltip": "دائرة", "tool": "circle"},
      {"icon": Icons.text_fields, "tooltip": "نص", "tool": "text"},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...colors.map((c) => buildColorButton(cubit, c)),
          ...tools.map((t) {
            final isActive = cubit.state.tool == (t["tool"] as String);
            return IconButton(
              icon: Icon(
                t["icon"] as IconData,
                color: isActive ? AppColors.accentOrange : Colors.black,
              ),
              tooltip: t["tooltip"] as String,
              onPressed: () {
                cubit.changeTool(t["tool"] as String);
                if (t.containsKey("extra")) (t["extra"] as VoidCallback)();

                // لو الأداة text شغالة، اضبط الـ Canvas لإنشاء نص عند الضغط
                if (t["tool"] == "text") {
                  // هنا ما نعملش حاجة مباشرة، الرسم بيتعامل مع onTapDown
                }
              },
            );
          }),

          const SizedBox(width: 16),
          SizedBox(
            width: 200,
            child: Slider(
              min: 1,
              max: 10,
              activeColor: AppColors.accentOrange,
              value: strokeWidth,
              label: "${strokeWidth.toInt()} px",
              onChanged: onStrokeChanged,
            ),
          ),
        ],
      ),
    );
  }
}
