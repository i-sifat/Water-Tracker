import 'package:flutter/material.dart';
import 'package:watertracker/core/design_system/app_colors.dart';
import 'package:watertracker/core/widgets/buttons/primary_button.dart';
import 'package:watertracker/core/widgets/cards/app_card.dart';

/// Enhanced empty state widget with animations and multiple styles
class EmptyStateWidget extends StatefulWidget {
  const EmptyStateWidget({
    required this.title, required this.subtitle, super.key,
    this.icon,
    this.actionText,
    this.onAction,
    this.onActionPressed,
    this.style = EmptyStateStyle.default_,
    this.showCard = false,
    this.customIllustration,
    this.illustration,
  });

  final String title;
  final String subtitle;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onAction;
  final VoidCallback? onActionPressed; // For backward compatibility
  final EmptyStateStyle style;
  final bool showCard;
  final Widget? customIllustration;
  final Widget? illustration; // For backward compatibility

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<double>(
      begin: 30,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0, 0.5, curve: Curves.elasticOut),
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: _buildContent(),
          ),
        );
      },
    );

    if (widget.showCard) {
      return Center(
        child: AppCard(
          margin: const EdgeInsets.all(20),
          child: content,
        ),
      );
    }

    return Center(child: content);
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIllustration(),
          const SizedBox(height: 24),
          _buildTitle(),
          const SizedBox(height: 8),
          _buildSubtitle(),
          if (_hasAction()) ...[
            const SizedBox(height: 24),
            _buildAction(),
          ],
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    // Use custom illustration or backward compatibility illustration first
    if (widget.customIllustration != null) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: widget.customIllustration,
      );
    }
    
    if (widget.illustration != null) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: widget.illustration,
      );
    }

    final iconData = widget.icon ?? _getDefaultIcon();
    final iconColor = _getIconColor();
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          iconData,
          size: 40,
          color: iconColor,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.title,
      style: TextStyle(
        fontSize: _getTitleFontSize(),
        fontWeight: FontWeight.bold,
        color: _getTitleColor(),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return Text(
      widget.subtitle,
      style: TextStyle(
        fontSize: _getSubtitleFontSize(),
        color: _getSubtitleColor(),
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildAction() {
    final actionText = widget.actionText;
    final onAction = widget.onAction ?? widget.onActionPressed;
    
    if (actionText == null || onAction == null) {
      return const SizedBox.shrink();
    }
    
    return PrimaryButton(
      text: actionText,
      onPressed: onAction,
      width: 200,
    );
  }

  bool _hasAction() {
    return (widget.actionText != null) && 
           (widget.onAction != null || widget.onActionPressed != null);
  }

  IconData _getDefaultIcon() {
    switch (widget.style) {
      case EmptyStateStyle.default_:
        return Icons.inbox_outlined;
      case EmptyStateStyle.search:
        return Icons.search_off;
      case EmptyStateStyle.network:
        return Icons.wifi_off;
      case EmptyStateStyle.error:
        return Icons.error_outline;
      case EmptyStateStyle.hydration:
        return Icons.water_drop_outlined;
      case EmptyStateStyle.history:
        return Icons.history;
      case EmptyStateStyle.analytics:
        return Icons.analytics_outlined;
    }
  }

  Color _getIconColor() {
    switch (widget.style) {
      case EmptyStateStyle.default_:
        return AppColors.textSubtitle;
      case EmptyStateStyle.search:
        return Colors.blue;
      case EmptyStateStyle.network:
        return Colors.orange;
      case EmptyStateStyle.error:
        return Colors.red;
      case EmptyStateStyle.hydration:
        return AppColors.waterFull;
      case EmptyStateStyle.history:
        return AppColors.lightBlue;
      case EmptyStateStyle.analytics:
        return AppColors.chartBlue;
    }
  }

  Color _getTitleColor() {
    switch (widget.style) {
      case EmptyStateStyle.error:
        return Colors.red[700]!;
      default:
        return AppColors.textHeadline;
    }
  }

  Color _getSubtitleColor() {
    return AppColors.textSubtitle;
  }

  double _getTitleFontSize() {
    switch (widget.style) {
      case EmptyStateStyle.error:
        return 18;
      default:
        return 20;
    }
  }

  double _getSubtitleFontSize() {
    switch (widget.style) {
      case EmptyStateStyle.error:
        return 14;
      default:
        return 16;
    }
  }
}

enum EmptyStateStyle {
  default_,
  search,
  network,
  error,
  hydration,
  history,
  analytics,
}

/// Compact empty state for smaller spaces
class CompactEmptyState extends StatelessWidget {
  const CompactEmptyState({
    required this.message, super.key,
    this.icon,
    this.actionText,
    this.onAction,
  });

  final String message;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 32,
              color: AppColors.textSubtitle.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSubtitle,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onAction,
              child: Text(
                actionText!,
                style: const TextStyle(
                  color: AppColors.waterFull,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Inline empty state for list items
class InlineEmptyState extends StatelessWidget {
  const InlineEmptyState({
    required this.message, super.key,
    this.icon,
  });

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: AppColors.textSubtitle.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSubtitle,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Specialized empty states for common scenarios
class HydrationEmptyState extends StatelessWidget {
  const HydrationEmptyState({
    super.key,
    this.onAddWater,
  });

  final VoidCallback? onAddWater;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Water Logged Today',
      subtitle: 'Start tracking your hydration by adding your first glass of water.',
      style: EmptyStateStyle.hydration,
      actionText: onAddWater != null ? 'Add Water' : null,
      onAction: onAddWater,
      customIllustration: _buildWaterIllustration(),
    );
  }

  Widget _buildWaterIllustration() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.waterFull.withValues(alpha: 0.1),
            AppColors.waterFull.withValues(alpha: 0.3),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.water_drop,
        size: 50,
        color: AppColors.waterFull,
      ),
    );
  }
}

class HistoryEmptyState extends StatelessWidget {
  const HistoryEmptyState({
    super.key,
    this.onStartTracking,
  });

  final VoidCallback? onStartTracking;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No History Yet',
      subtitle: 'Your hydration history will appear here once you start tracking your water intake.',
      style: EmptyStateStyle.history,
      actionText: onStartTracking != null ? 'Start Tracking' : null,
      onAction: onStartTracking,
    );
  }
}

class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({
    required this.searchQuery, super.key,
    this.onClearSearch,
  });

  final String searchQuery;
  final VoidCallback? onClearSearch;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Results Found',
      subtitle: 'No results found for "$searchQuery". Try adjusting your search terms.',
      style: EmptyStateStyle.search,
      actionText: onClearSearch != null ? 'Clear Search' : null,
      onAction: onClearSearch,
    );
  }
}

class NetworkEmptyState extends StatelessWidget {
  const NetworkEmptyState({
    super.key,
    this.onRetry,
  });

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Connection Problem',
      subtitle: 'Please check your internet connection and try again.',
      style: EmptyStateStyle.network,
      actionText: onRetry != null ? 'Try Again' : null,
      onAction: onRetry,
    );
  }
}
