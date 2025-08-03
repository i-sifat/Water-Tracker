import 'dart:math';
import 'package:flutter/material.dart';
import 'package:watertracker/core/utils/performance_utils.dart';

class CelebrationAnimation extends StatefulWidget {
  const CelebrationAnimation({
    super.key,
    this.duration = const Duration(seconds: 3),
    this.particleCount = 50,
    this.colors = const [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.yellow,
    ],
  });

  final Duration duration;
  final int particleCount;
  final List<Color> colors;

  @override
  State<CelebrationAnimation> createState() => _CelebrationAnimationState();
}

class _CelebrationAnimationState extends State<CelebrationAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  final Random _random = Random();
  int _frameCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _initializeParticles();
    _controller.forward();
  }

  void _initializeParticles() {
    _particles = List.generate(widget.particleCount, (index) {
      return Particle(
        x: 0.5, // Start from center
        y: 0.5, // Start from center
        velocityX: (_random.nextDouble() - 0.5) * 4,
        velocityY: -_random.nextDouble() * 3 - 1,
        color: widget.colors[_random.nextInt(widget.colors.length)],
        size: _random.nextDouble() * 8 + 4,
        gravity: _random.nextDouble() * 0.5 + 0.5,
        life: 1,
        decay: _random.nextDouble() * 0.02 + 0.01,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        _updateParticles();
        // Performance optimization: RepaintBoundary around expensive particle animation
        return PerformanceUtils.optimizedRepaintBoundary(
          debugLabel: 'CelebrationAnimation',
          child: CustomPaint(
            painter: CelebrationPainter(_particles),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  void _updateParticles() {
    _frameCount++;

    // Frame rate limiting: Only update every other frame for better performance
    if (_frameCount % 2 != 0) return;

    for (final particle in _particles) {
      if (particle.life > 0) {
        particle
          ..x +=
              particle.velocityX *
              0.032 // Compensate for half frame rate
          ..y += particle.velocityY * 0.032
          ..velocityY += particle.gravity * 0.032
          ..life -= particle.decay;
      }
    }
  }
}

class Particle {
  Particle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.color,
    required this.size,
    required this.gravity,
    required this.life,
    required this.decay,
  });

  double x;
  double y;
  double velocityX;
  double velocityY;
  final Color color;
  final double size;
  final double gravity;
  double life;
  final double decay;
}

class CelebrationPainter extends CustomPainter {
  CelebrationPainter(this.particles);

  final List<Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      if (particle.life > 0) {
        final paint =
            Paint()
              ..color = particle.color.withValues(alpha: particle.life)
              ..style = PaintingStyle.fill;

        final position = Offset(
          particle.x * size.width,
          particle.y * size.height,
        );

        canvas.drawCircle(position, particle.size, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CelebrationPainter oldDelegate) => true;
}

class GoalAchievementDialog extends StatefulWidget {
  const GoalAchievementDialog({
    super.key,
    this.title = 'Goal Achieved!',
    this.message = 'Congratulations on reaching your hydration goal!',
    this.onContinue,
  });

  final String title;
  final String message;
  final VoidCallback? onContinue;

  @override
  State<GoalAchievementDialog> createState() => _GoalAchievementDialogState();
}

class _GoalAchievementDialogState extends State<GoalAchievementDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    // Start animations
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _rotationController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Celebration particles with RepaintBoundary optimization
          Positioned.fill(
            child: PerformanceUtils.optimizedRepaintBoundary(
              debugLabel: 'CelebrationAnimationDialog',
              child: const CelebrationAnimation(),
            ),
          ),

          // Dialog content
          Center(
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated trophy icon
                        AnimatedBuilder(
                          animation: _rotationAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotationAnimation.value,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.emoji_events,
                                  size: 40,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // Title
                        Text(
                          widget.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        // Message
                        Text(
                          widget.message,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),

                        // Continue button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onContinue?.call();
                            },
                            child: const Text('Continue'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to show the celebration dialog
void showGoalAchievementDialog(
  BuildContext context, {
  String? title,
  String? message,
  VoidCallback? onContinue,
}) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => GoalAchievementDialog(
          title: title ?? 'Goal Achieved!',
          message:
              message ?? 'Congratulations on reaching your hydration goal!',
          onContinue: onContinue,
        ),
  );
}
