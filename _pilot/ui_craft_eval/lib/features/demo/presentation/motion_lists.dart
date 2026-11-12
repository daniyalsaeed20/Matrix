import 'package:flutter/material.dart';

/// Anti-pattern: per-row entrance AnimationController (avoid in product UI).
class OverAnimatedList extends StatefulWidget {
  const OverAnimatedList({super.key, required this.labels});

  final List<String> labels;

  @override
  State<OverAnimatedList> createState() => OverAnimatedListState();
}

class OverAnimatedListState extends State<OverAnimatedList>
    with TickerProviderStateMixin {
  late final List<AnimationController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = [
      for (var i = 0; i < widget.labels.length; i++)
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 400),
        )..forward(),
    ];
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < widget.labels.length; i++)
          FadeTransition(
            opacity: controllers[i],
            child: ListTile(title: Text(widget.labels[i])),
          ),
      ],
    );
  }
}

/// Preferred: static list — no decorative entrance motion.
class CalmList extends StatelessWidget {
  const CalmList({super.key, required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final label in labels) ListTile(title: Text(label)),
      ],
    );
  }
}
