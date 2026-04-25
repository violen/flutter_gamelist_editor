import 'package:flutter/material.dart';
import 'package:flutter_gamelist_editor/models/game.dart';

class SystemBubble extends StatelessWidget {
  const SystemBubble({super.key, required this.system});

  final System system;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(45), 
        color: system.color ?? Colors.grey
      ),
      child: Text(system.name),
    );
  }
}
