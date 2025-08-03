import 'package:flutter/material.dart';
import 'package:watertracker/core/models/hydration_progress.dart';
import 'package:watertracker/features/hydration/widgets/interactive_circular_progress.dart';

/// Wrapper widget that coordinates animations between circular progress and water addition
class AnimatedHydrationSection extends StatefulWidget {
  const AnimatedHydrationSection({
    required this.progress,
    this.animationDuration = const Duration(milliseconds: 800),
    super.key,
  });

  /// Hydration progress data to display
  final HydrationProgress progress;

  /// Duration for progress animation
  final Duration animationDuration;

  @override
  State<AnimatedHydrationSection> createState() =>
      _AnimatedHydrationSectionState();
}

class _AnimatedHydrationSectionState extends State<AnimatedHydrationSection> {
  final GlobalKey<_InteractiveCircularProgressState> _progressKey =
      GlobalKey<_InteractiveCircularProgressState>();

  /// Trigger water addition animation on the circular progress
  void triggerWaterAddedAnimation() {
    _progressKey.currentState?.triggerWaterAddedAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveCircularProgress(
      key: _progressKey,
      progress: widget.progress,
      animationDuration: widget.animationDuration,
    );
  }
}
