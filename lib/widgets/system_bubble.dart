import 'package:flutter/material.dart';
import 'package:flutter_gamelist_editor/models/game.dart';

class SystemBubble extends StatelessWidget {
  SystemBubble({Key key, this.system}) : super(key: key);

  final System system;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(45), color: system.color),
      child: Text(system.name),
    );
  }
}