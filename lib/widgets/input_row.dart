import 'package:flutter/material.dart';

class InputRow extends StatelessWidget {
  final List<Widget> children;
  final double gapSize;

  const InputRow({super.key, required this.children, this.gapSize = 5});

  @override
  Widget build(BuildContext context) {
    List<Widget> _children = [];
    for (var child in children) {
      _children.addAll([
        Expanded(child: child),
        SizedBox(width: gapSize),
      ]);
    }
    _children.removeLast();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _children,
    );
  }
}
