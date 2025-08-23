import 'package:flutter/material.dart';

class PremiumDropdownMenu extends StatefulWidget {
  final List<String> menuItems;
  final Function(String) onItemSelected;
  final Duration animationDuration;

  const PremiumDropdownMenu({
    super.key,
    required this.menuItems,
    required this.onItemSelected,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  PremiumDropdownMenuState createState() => PremiumDropdownMenuState();
}

class PremiumDropdownMenuState extends State<PremiumDropdownMenu> {
  late List<Widget> animatedItems;

  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    animatedItems = List.generate(widget.menuItems.length, (index) {
      return AnimatedOpacity(
        opacity: 0.0,
        duration: widget.animationDuration,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            widget.menuItems[index],
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      );
    });
  }

  void showMenuItems() {
    for (int i = 0; i < animatedItems.length; i++) {
      Future.delayed(Duration(milliseconds: 300 * i), () {
        setState(() {
          animatedItems[i] = AnimatedOpacity(
            opacity: 1.0,
            duration: widget.animationDuration,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                widget.menuItems[i],
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          );
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _key,
      onTap: () {
        final RenderBox renderBox =
            _key.currentContext!.findRenderObject() as RenderBox;
        final position = renderBox.localToGlobal(Offset.zero);
        final double dx = position.dx;
        final double dy = position.dy + renderBox.size.height;

        showMenuItems();
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(dx, dy, dx + 200.0, dy + 100.0),
          items:
              widget.menuItems.map((String item) {
                return PopupMenuItem<String>(value: item, child: Text(item));
              }).toList(),
        ).then((value) {
          widget.onItemSelected(value ?? '');
        });
      },
      child: const Icon(Icons.arrow_drop_down_outlined, size: 22),
    );
  }
}
