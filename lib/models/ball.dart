import 'package:flutter/material.dart';

class Ball extends StatelessWidget {
  final Widget? child;

  const Ball({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surface,

        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.secondary,
            blurRadius: 20,
            offset: const Offset(1, 1),
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.secondary,
            blurRadius: 20,
            offset: const Offset(-1, -1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(.1),
      child: child,
    );
  }
}
