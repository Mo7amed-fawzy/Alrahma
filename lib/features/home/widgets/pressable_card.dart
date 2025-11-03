import 'package:flutter/material.dart';

class PressableCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final double iconSize;
  final double textSize;
  final VoidCallback onTap;

  const PressableCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.iconSize,
    required this.textSize,
    required this.onTap,
    super.key,
  });

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 1.05 : 1.0),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: _isPressed
                ? [
                    widget.color.withValues(alpha: 0.8),
                    widget.color.withValues(alpha: 0.5),
                  ]
                : [
                    widget.color.withValues(alpha: 0.95),
                    widget.color.withValues(alpha: 0.65),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.3),
              offset: const Offset(0, 6),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, size: widget.iconSize, color: Colors.white),
            const SizedBox(height: 16),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.textSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
