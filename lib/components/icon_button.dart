import 'package:flutter/material.dart';

class NeuIconButton extends StatefulWidget {
  final VoidCallback? onTap;
  final Icon? btnIcon;
  final Color color;
  final bool loader;
  const NeuIconButton({
    super.key,
    required this.onTap,
    required this.btnIcon,
    required this.color,
    this.loader = false,
  });

  @override
  State<NeuIconButton> createState() => _NeuIconButtonState();
}

class _NeuIconButtonState extends State<NeuIconButton> {
  bool _isButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isButtonPressed = true),
      onTapUp: (_) => setState(() => _isButtonPressed = false),
      onTapCancel: () => setState(() => _isButtonPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 60,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          border: Border.all(
              color: _isButtonPressed
                  ? Colors.grey.shade200
                  : Colors.grey.shade300),
          boxShadow: _isButtonPressed
              ? []
              : [
                  // darker the shadow on bottom right
                  BoxShadow(
                    color: Colors.grey.shade500,
                    offset: const Offset(1, 1),
                    blurRadius: 7,
                    spreadRadius: 1,
                  ),
                  //darker the shadow on top left
                  const BoxShadow(
                    color: Colors.white70,
                    offset: Offset(-3, -3),
                    blurRadius: 7,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: widget.btnIcon,
        ),
      ),
    );
  }
}
