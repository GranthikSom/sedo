import 'package:flutter/material.dart';

class Box extends StatelessWidget {
  final Widget? child;

  const Box({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.secondary,
            blurRadius: 10,
            offset: const Offset(1, 1),
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.secondary,
            blurRadius: 10,
            offset: const Offset(-1, -1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }
}
