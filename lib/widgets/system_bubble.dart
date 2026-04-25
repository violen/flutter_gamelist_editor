import 'package:flutter/material.dart';
import 'package:flutter_gamelist_editor/models/game.dart';

class SystemBubble extends StatelessWidget {
  const SystemBubble({super.key, required this.system});

  final System system;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = system.color;
    final textColor = backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), 
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          )
        ]
      ),
      child: Text(
        system.displayName.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
