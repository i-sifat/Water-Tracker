import 'dart:math';
import 'package:flutter/material.dart';

class RollingSwitchButton extends StatefulWidget {
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChange;
  final String textOff;
  final String textOn;
  final Duration animationDuration;
  final IconData iconOn;
  final IconData iconOff;

  const RollingSwitchButton({
    super.key,
    required this.value,
    this.enabled = true,
    required this.onChange,
    this.textOff = 'OFF',
    this.textOn = 'ON',
    this.iconOff = Icons.alarm_off_rounded,
    this.iconOn = Icons.alarm_on_rounded,
    this.animationDuration = const Duration(milliseconds: 450),
  });

  @override
  State<RollingSwitchButton> createState() => _RollingSwitchState();
}

class _RollingSwitchState extends State<RollingSwitchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      value: widget.value ? 1.0 : 0.0,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(RollingSwitchButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: widget.enabled ? () => widget.onChange(!widget.value) : null,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final isOn = _animation.value > 0.5;
          final color = Color.lerp(
            colorScheme.error,
            colorScheme.primary,
            _animation.value,
          )!
              .withOpacity(widget.enabled ? 1.0 : 0.5);

          return Container(
            width: 130,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Stack(
              children: [
                // Text
                AnimatedOpacity(
                  opacity: isOn ? 1.0 : 0.0,
                  duration: widget.animationDuration,
                  child: Container(
                    padding: const EdgeInsets.only(left: 16),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.textOn,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: isOn ? 0.0 : 1.0,
                  duration: widget.animationDuration,
                  child: Container(
                    padding: const EdgeInsets.only(right: 16),
                    alignment: Alignment.centerRight,
                    child: Text(
                      widget.textOff,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onError,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Animated Thumb
                Transform.translate(
                  offset: Offset(80 * _animation.value, 0),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Transform.rotate(
                      angle: 2 * pi * _animation.value,
                      child: Icon(
                        isOn ? widget.iconOn : widget.iconOff,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
