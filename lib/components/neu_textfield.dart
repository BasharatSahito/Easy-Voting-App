import 'package:flutter/material.dart';

class NeuTextfield extends StatelessWidget {
  final TextFormField child;

  const NeuTextfield({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          const BoxShadow(
            color: Colors.white70,
            offset: Offset(-4, -4),
            blurRadius: 4,
          ),
          BoxShadow(
            color: Colors.grey.shade400,
            offset: const Offset(4, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: child,
    );
  }
}
