import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

/// A responsive scaffold that automatically handles safe areas, responsive padding,
/// and adapts to different screen sizes and orientations.
class ResponsiveScaffold extends StatelessWidget {
  /// The primary content of the scaffold
  final Widget body;

  /// An app bar to display at the top of the scaffold
  final PreferredSizeWidget? appBar;

  /// A bottom navigation bar to display at the bottom of the scaffold
  final Widget? bottomNavigationBar;

  /// A floating action button to display
  final Widget? floatingActionButton;

  /// The position of the floating action button
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// A drawer to display on the left side
  final Widget? drawer;

  /// A drawer to display on the right side
  final Widget? endDrawer;

  /// The background color of the scaffold
  final Color? backgroundColor;

  /// Whether to resize the body when the keyboard appears
  final bool? resizeToAvoidBottomInset;

  /// Custom padding to apply to the body (will be made responsive)
  final EdgeInsets? padding;

  /// Whether to automatically apply safe area padding
  final bool applySafeArea;

  /// Whether to apply responsive padding to the body
  final bool applyResponsivePadding;

  /// Maximum content width for tablets (prevents excessive stretching)
  final bool limitContentWidth;

  /// Custom safe area configuration
  final bool safeAreaTop;
  final bool safeAreaBottom;
  final bool safeAreaLeft;
  final bool safeAreaRight;

  const ResponsiveScaffold({
    Key? key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.padding,
    this.applySafeArea = true,
    this.applyResponsivePadding = true,
    this.limitContentWidth = true,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
    this.safeAreaLeft = true,
    this.safeAreaRight = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildResponsiveAppBar(context),
      body: _buildResponsiveBody(context),
      bottomNavigationBar: _buildResponsiveBottomNavigationBar(context),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }

  /// Builds a responsive app bar with appropriate height
  PreferredSizeWidget? _buildResponsiveAppBar(BuildContext context) {
    if (appBar == null) return null;

    // If it's already a responsive app bar, return as is
    if (appBar is ResponsiveAppBar) return appBar;

    // Wrap regular app bar with responsive sizing
    return PreferredSize(
      preferredSize: Size.fromHeight(
        ResponsiveHelper.getResponsiveAppBarHeight(context),
      ),
      child: appBar!,
    );
  }

  /// Builds the responsive body with appropriate padding and constraints
  Widget _buildResponsiveBody(BuildContext context) {
    Widget bodyWidget = body;

    // Apply content width limitation for tablets
    if (limitContentWidth) {
      final maxWidth = ResponsiveHelper.getMaxContentWidth(context);
      bodyWidget = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: bodyWidget,
        ),
      );
    }

    // Apply responsive padding
    if (applyResponsivePadding || padding != null) {
      EdgeInsets responsivePadding;

      if (padding != null) {
        // Use custom padding but make it responsive
        responsivePadding = ResponsiveHelper.getResponsivePadding(
          context,
          horizontal: padding!.horizontal / 2,
          vertical: padding!.vertical / 2,
        );
      } else {
        // Use default responsive padding
        responsivePadding = ResponsiveHelper.getResponsivePadding(context);
      }

      bodyWidget = Padding(padding: responsivePadding, child: bodyWidget);
    }

    // Apply safe area if requested
    if (applySafeArea) {
      bodyWidget = SafeArea(
        top: safeAreaTop,
        bottom: safeAreaBottom,
        left: safeAreaLeft,
        right: safeAreaRight,
        child: bodyWidget,
      );
    }

    return bodyWidget;
  }

  /// Builds a responsive bottom navigation bar
  Widget? _buildResponsiveBottomNavigationBar(BuildContext context) {
    if (bottomNavigationBar == null) return null;

    // If it's already responsive, return as is
    if (bottomNavigationBar is ResponsiveBottomNavigationBar) {
      return bottomNavigationBar;
    }

    // Wrap with responsive container
    return Container(
      height: ResponsiveHelper.getResponsiveBottomNavHeight(context),
      child: bottomNavigationBar,
    );
  }
}

/// A responsive app bar that adapts its height and content to different screen sizes
class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title widget
  final Widget? title;

  /// Leading widget (usually back button or menu)
  final Widget? leading;

  /// Actions to display on the right side
  final List<Widget>? actions;

  /// Background color
  final Color? backgroundColor;

  /// Elevation
  final double? elevation;

  /// Whether to automatically imply leading widget
  final bool automaticallyImplyLeading;

  /// Title spacing
  final double? titleSpacing;

  /// Center the title
  final bool centerTitle;

  /// Custom preferred size (will be made responsive)
  final Size? customPreferredSize;

  const ResponsiveAppBar({
    Key? key,
    this.title,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.elevation,
    this.automaticallyImplyLeading = true,
    this.titleSpacing,
    this.centerTitle = false,
    this.customPreferredSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _buildResponsiveTitle(context),
      leading: _buildResponsiveLeading(context),
      actions: _buildResponsiveActions(context),
      backgroundColor: backgroundColor,
      elevation: elevation,
      automaticallyImplyLeading: automaticallyImplyLeading,
      titleSpacing:
          titleSpacing != null
              ? ResponsiveHelper.getResponsiveSpacing(context, titleSpacing!)
              : null,
      centerTitle: centerTitle,
    );
  }

  /// Builds responsive title with appropriate text scaling
  Widget? _buildResponsiveTitle(BuildContext context) {
    if (title == null) return null;

    // If title is already a Text widget, make it responsive
    if (title is Text) {
      final textWidget = title as Text;
      return Text(
        textWidget.data ?? '',
        style:
            textWidget.style?.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                textWidget.style?.fontSize ?? 20.0,
              ),
            ) ??
            TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20.0),
            ),
        textAlign: textWidget.textAlign,
        overflow: textWidget.overflow,
        maxLines: textWidget.maxLines,
      );
    }

    return title;
  }

  /// Builds responsive leading widget
  Widget? _buildResponsiveLeading(BuildContext context) {
    if (leading == null) return null;

    // If leading is an icon, make it responsive
    if (leading is Icon) {
      final iconWidget = leading as Icon;
      return Icon(
        iconWidget.icon,
        size: ResponsiveHelper.getResponsiveIconSize(
          context,
          iconWidget.size ?? 24.0,
        ),
        color: iconWidget.color,
      );
    }

    return leading;
  }

  /// Builds responsive actions
  List<Widget>? _buildResponsiveActions(BuildContext context) {
    if (actions == null) return null;

    return actions!.map((action) {
      // Make icons responsive
      if (action is Icon) {
        return Icon(
          action.icon,
          size: ResponsiveHelper.getResponsiveIconSize(
            context,
            action.size ?? 24.0,
          ),
          color: action.color,
        );
      }

      // Make icon buttons responsive
      if (action is IconButton) {
        return IconButton(
          onPressed: action.onPressed,
          icon:
              action.icon is Icon
                  ? Icon(
                    (action.icon as Icon).icon,
                    size: ResponsiveHelper.getResponsiveIconSize(
                      context,
                      (action.icon as Icon).size ?? 24.0,
                    ),
                    color: (action.icon as Icon).color,
                  )
                  : action.icon,
          tooltip: action.tooltip,
          padding: EdgeInsets.all(
            ResponsiveHelper.getResponsiveSpacing(context, 8.0),
          ),
        );
      }

      return action;
    }).toList();
  }

  @override
  Size get preferredSize {
    // This will be overridden by the ResponsiveScaffold
    return customPreferredSize ?? const Size.fromHeight(kToolbarHeight);
  }
}

/// A responsive bottom navigation bar that adapts to different screen sizes
class ResponsiveBottomNavigationBar extends StatelessWidget {
  /// The navigation items
  final List<BottomNavigationBarItem> items;

  /// Current selected index
  final int currentIndex;

  /// Callback when item is tapped
  final ValueChanged<int>? onTap;

  /// Type of bottom navigation bar
  final BottomNavigationBarType? type;

  /// Background color
  final Color? backgroundColor;

  /// Selected item color
  final Color? selectedItemColor;

  /// Unselected item color
  final Color? unselectedItemColor;

  /// Selected label style
  final TextStyle? selectedLabelStyle;

  /// Unselected label style
  final TextStyle? unselectedLabelStyle;

  /// Icon size
  final double? iconSize;

  /// Elevation
  final double? elevation;

  const ResponsiveBottomNavigationBar({
    Key? key,
    required this.items,
    required this.currentIndex,
    this.onTap,
    this.type,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    this.iconSize,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsiveIconSize = ResponsiveHelper.getResponsiveIconSize(
      context,
      iconSize ?? 24.0,
    );

    return BottomNavigationBar(
      items: _buildResponsiveItems(context),
      currentIndex: currentIndex,
      onTap: onTap,
      type: type,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      selectedLabelStyle: _buildResponsiveLabelStyle(
        context,
        selectedLabelStyle,
      ),
      unselectedLabelStyle: _buildResponsiveLabelStyle(
        context,
        unselectedLabelStyle,
      ),
      iconSize: responsiveIconSize,
      elevation: elevation,
    );
  }

  /// Builds responsive navigation items
  List<BottomNavigationBarItem> _buildResponsiveItems(BuildContext context) {
    return items.map((item) {
      return BottomNavigationBarItem(
        icon: _buildResponsiveIcon(context, item.icon),
        activeIcon:
            item.activeIcon != null
                ? _buildResponsiveIcon(context, item.activeIcon!)
                : null,
        label: item.label,
        tooltip: item.tooltip,
        backgroundColor: item.backgroundColor,
      );
    }).toList();
  }

  /// Builds responsive icon
  Widget _buildResponsiveIcon(BuildContext context, Widget icon) {
    if (icon is Icon) {
      return Icon(
        icon.icon,
        size: ResponsiveHelper.getResponsiveIconSize(
          context,
          icon.size ?? iconSize ?? 24.0,
        ),
        color: icon.color,
      );
    }
    return icon;
  }

  /// Builds responsive label style
  TextStyle? _buildResponsiveLabelStyle(
    BuildContext context,
    TextStyle? style,
  ) {
    if (style == null) return null;

    return style.copyWith(
      fontSize: ResponsiveHelper.getResponsiveFontSize(
        context,
        style.fontSize ?? 12.0,
      ),
    );
  }
}

/// Extension to easily convert regular Scaffold to ResponsiveScaffold
extension ScaffoldExtension on Scaffold {
  /// Converts a regular Scaffold to a ResponsiveScaffold
  ResponsiveScaffold toResponsive({
    EdgeInsets? padding,
    bool applySafeArea = true,
    bool applyResponsivePadding = true,
    bool limitContentWidth = true,
  }) {
    return ResponsiveScaffold(
      body: body!,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      padding: padding,
      applySafeArea: applySafeArea,
      applyResponsivePadding: applyResponsivePadding,
      limitContentWidth: limitContentWidth,
    );
  }
}
