import 'package:flutter/material.dart';

/// Utility class for handling RTL (Right-to-Left) layout support
class RTLUtils {
  RTLUtils._();

  /// Check if the current locale is RTL
  static bool isRTL(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl;
  }

  /// Get the appropriate edge insets for RTL support
  static EdgeInsetsDirectional getDirectionalPadding({
    double start = 0.0,
    double top = 0.0,
    double end = 0.0,
    double bottom = 0.0,
  }) {
    return EdgeInsetsDirectional.fromSTEB(start, top, end, bottom);
  }

  /// Get the appropriate margin for RTL support
  static EdgeInsetsDirectional getDirectionalMargin({
    double start = 0.0,
    double top = 0.0,
    double end = 0.0,
    double bottom = 0.0,
  }) {
    return EdgeInsetsDirectional.fromSTEB(start, top, end, bottom);
  }

  /// Get the appropriate alignment for RTL support
  static AlignmentDirectional getDirectionalAlignment({
    required double x,
    required double y,
  }) {
    return AlignmentDirectional(x, y);
  }

  /// Get start alignment (left in LTR, right in RTL)
  static AlignmentDirectional get alignmentStart => AlignmentDirectional.centerStart;

  /// Get end alignment (right in LTR, left in RTL)
  static AlignmentDirectional get alignmentEnd => AlignmentDirectional.centerEnd;

  /// Get the appropriate icon for back navigation based on text direction
  static IconData getBackIcon(BuildContext context) {
    return isRTL(context) ? Icons.arrow_forward : Icons.arrow_back;
  }

  /// Get the appropriate icon for forward navigation based on text direction
  static IconData getForwardIcon(BuildContext context) {
    return isRTL(context) ? Icons.arrow_back : Icons.arrow_forward;
  }

  /// Wrap a widget with Directionality for consistent RTL support
  static Widget withDirectionality({
    required BuildContext context,
    required Widget child,
    TextDirection? textDirection,
  }) {
    return Directionality(
      textDirection: textDirection ?? Directionality.of(context),
      child: child,
    );
  }

  /// Create a directional row that respects RTL layout
  static Widget directionalRow({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
  }) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      textDirection: TextDirection.ltr, // Let Directionality handle this
      children: children,
    );
  }

  /// Get appropriate text alignment for RTL support
  static TextAlign getTextAlign(BuildContext context, {TextAlign? fallback}) {
    if (fallback != null) return fallback;
    return isRTL(context) ? TextAlign.right : TextAlign.left;
  }

  /// Get appropriate text alignment for center text
  static TextAlign getCenterTextAlign() => TextAlign.center;

  /// Get appropriate text alignment for start text (left in LTR, right in RTL)
  static TextAlign getStartTextAlign(BuildContext context) {
    return isRTL(context) ? TextAlign.right : TextAlign.left;
  }

  /// Get appropriate text alignment for end text (right in LTR, left in RTL)
  static TextAlign getEndTextAlign(BuildContext context) {
    return isRTL(context) ? TextAlign.left : TextAlign.right;
  }

  /// Mirror a double value for RTL (multiply by -1 if RTL)
  static double mirrorForRTL(BuildContext context, double value) {
    return isRTL(context) ? -value : value;
  }

  /// Get appropriate border radius for RTL support
  static BorderRadiusDirectional getDirectionalBorderRadius({
    double topStart = 0.0,
    double topEnd = 0.0,
    double bottomStart = 0.0,
    double bottomEnd = 0.0,
  }) {
    return BorderRadiusDirectional.only(
      topStart: Radius.circular(topStart),
      topEnd: Radius.circular(topEnd),
      bottomStart: Radius.circular(bottomStart),
      bottomEnd: Radius.circular(bottomEnd),
    );
  }

  /// Get symmetric border radius
  static BorderRadius getSymmetricBorderRadius(double radius) {
    return BorderRadius.circular(radius);
  }

  /// Create a positioned widget that respects RTL layout
  static Widget directionalPositioned({
    required Widget child,
    double? start,
    double? end,
    double? top,
    double? bottom,
    double? width,
    double? height,
  }) {
    return PositionedDirectional(
      start: start,
      end: end,
      top: top,
      bottom: bottom,
      width: width,
      height: height,
      child: child,
    );
  }

  /// Get appropriate transform for RTL mirroring
  static Matrix4 getMirrorTransform(BuildContext context) {
    if (isRTL(context)) {
      return Matrix4.identity()..scale(-1.0, 1.0, 1.0);
    }
    return Matrix4.identity();
  }

  /// Wrap widget with RTL-aware transform
  static Widget withRTLTransform({
    required BuildContext context,
    required Widget child,
    bool shouldMirror = true,
  }) {
    if (!shouldMirror || !isRTL(context)) {
      return child;
    }
    
    return Transform(
      alignment: Alignment.center,
      transform: getMirrorTransform(context),
      child: child,
    );
  }
}