import 'package:flutter/material.dart';

class Box extends StatelessWidget {
  final Widget? child;

  const Box({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(1, 1),
              ),
              BoxShadow(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(1, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ],
    );
  }
}
