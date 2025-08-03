import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

/// A text widget that automatically scales based on screen size and accessibility settings
class AdaptiveText extends StatelessWidget {
  /// The text to display
  final String text;

  /// The base text style (will be made responsive)
  final TextStyle? style;

  /// Text alignment
  final TextAlign? textAlign;

  /// Text direction
  final TextDirection? textDirection;

  /// Locale for text
  final Locale? locale;

  /// Whether the text should break at soft line breaks
  final bool? softWrap;

  /// How visual overflow should be handled
  final TextOverflow? overflow;

  /// Maximum number of lines
  final int? maxLines;

  /// Custom scale factor (multiplied with responsive scaling)
  final double? scaleFactor;

  /// Whether to apply accessibility text scaling
  final bool applyAccessibilityScaling;

  /// Semantic label for accessibility
  final String? semanticsLabel;

  /// Text width basis
  final TextWidthBasis? textWidthBasis;

  /// Text height behavior
  final TextHeightBehavior? textHeightBehavior;

  const AdaptiveText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.maxLines,
    this.scaleFactor,
    this.applyAccessibilityScaling = true,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? DefaultTextStyle.of(context).style;
    final baseFontSize = baseStyle.fontSize ?? 14.0;

    // Calculate responsive font size
    double responsiveFontSize =
        applyAccessibilityScaling
            ? ResponsiveHelper.getResponsiveFontSize(context, baseFontSize)
            : ResponsiveHelper.getResponsiveWidth(context, baseFontSize);

    // Apply custom scale factor if provided
    if (scaleFactor != null) {
      responsiveFontSize *= scaleFactor!;
    }

    final responsiveStyle = baseStyle.copyWith(fontSize: responsiveFontSize);

    return Text(
      text,
      style: responsiveStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }
}

/// A container widget that automatically applies responsive padding and sizing
class ResponsiveContainer extends StatelessWidget {
  /// The child widget
  final Widget? child;

  /// Base padding (will be made responsive)
  final EdgeInsets? padding;

  /// Base margin (will be made responsive)
  final EdgeInsets? margin;

  /// Base width (will be made responsive)
  final double? width;

  /// Base height (will be made responsive)
  final double? height;

  /// Decoration
  final Decoration? decoration;

  /// Foreground decoration
  final Decoration? foregroundDecoration;

  /// Constraints
  final BoxConstraints? constraints;

  /// Transform
  final Matrix4? transform;

  /// Transform alignment
  final AlignmentGeometry? transformAlignment;

  /// Clip behavior
  final Clip clipBehavior;

  /// Alignment
  final AlignmentGeometry? alignment;

  /// Whether to apply responsive padding
  final bool applyResponsivePadding;

  /// Whether to apply responsive margin
  final bool applyResponsiveMargin;

  /// Whether to apply responsive sizing
  final bool applyResponsiveSizing;

  /// Maximum width constraint for tablets
  final bool limitMaxWidth;

  const ResponsiveContainer({
    Key? key,
    this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.decoration,
    this.foregroundDecoration,
    this.constraints,
    this.transform,
    this.transformAlignment,
    this.clipBehavior = Clip.none,
    this.alignment,
    this.applyResponsivePadding = true,
    this.applyResponsiveMargin = true,
    this.applyResponsiveSizing = true,
    this.limitMaxWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate responsive dimensions
    final responsiveWidth =
        width != null && applyResponsiveSizing
            ? ResponsiveHelper.getResponsiveWidth(context, width!)
            : width;

    final responsiveHeight =
        height != null && applyResponsiveSizing
            ? ResponsiveHelper.getResponsiveHeight(context, height!)
            : height;

    // Calculate responsive padding
    EdgeInsets? responsivePadding;
    if (padding != null && applyResponsivePadding) {
      responsivePadding = ResponsiveHelper.getResponsivePadding(
        context,
        horizontal: padding!.horizontal / 2,
        vertical: padding!.vertical / 2,
      );
    } else if (padding != null) {
      responsivePadding = padding;
    }

    // Calculate responsive margin
    EdgeInsets? responsiveMargin;
    if (margin != null && applyResponsiveMargin) {
      responsiveMargin = ResponsiveHelper.getResponsiveMargin(
        context,
        horizontal: margin!.horizontal / 2,
        vertical: margin!.vertical / 2,
      );
    } else if (margin != null) {
      responsiveMargin = margin;
    }

    // Apply max width constraint for tablets if requested
    BoxConstraints? finalConstraints = constraints;
    if (limitMaxWidth && ResponsiveHelper.isTablet(context)) {
      final maxWidth = ResponsiveHelper.getMaxContentWidth(context);
      finalConstraints =
          constraints?.copyWith(maxWidth: maxWidth) ??
          BoxConstraints(maxWidth: maxWidth);
    }

    return Container(
      width: responsiveWidth,
      height: responsiveHeight,
      padding: responsivePadding,
      margin: responsiveMargin,
      decoration: decoration,
      foregroundDecoration: foregroundDecoration,
      constraints: finalConstraints,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      alignment: alignment,
      child: child,
    );
  }
}

/// A responsive image widget that adapts its size to different screen sizes
class ResponsiveImage extends StatelessWidget {
  /// The image provider
  final ImageProvider image;

  /// Base width (will be made responsive)
  final double? width;

  /// Base height (will be made responsive)
  final double? height;

  /// How the image should be inscribed into the box
  final BoxFit? fit;

  /// Alignment
  final AlignmentGeometry alignment;

  /// Repeat
  final ImageRepeat repeat;

  /// Center slice
  final Rect? centerSlice;

  /// Match text direction
  final bool matchTextDirection;

  /// Gapless playback
  final bool gaplessPlayback;

  /// Semantic label
  final String? semanticLabel;

  /// Exclude from semantics
  final bool excludeFromSemantics;

  /// Filter quality
  final FilterQuality filterQuality;

  /// Whether to apply responsive sizing
  final bool applyResponsiveSizing;

  /// Custom scale factor
  final double? scaleFactor;

  const ResponsiveImage({
    Key? key,
    required this.image,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.filterQuality = FilterQuality.low,
    this.applyResponsiveSizing = true,
    this.scaleFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? responsiveWidth = width;
    double? responsiveHeight = height;

    if (applyResponsiveSizing) {
      if (width != null) {
        responsiveWidth = ResponsiveHelper.getResponsiveWidth(context, width!);
        if (scaleFactor != null) {
          responsiveWidth = responsiveWidth! * scaleFactor!;
        }
      }

      if (height != null) {
        responsiveHeight = ResponsiveHelper.getResponsiveHeight(
          context,
          height!,
        );
        if (scaleFactor != null) {
          responsiveHeight = responsiveHeight! * scaleFactor!;
        }
      }
    }

    return Image(
      image: image,
      width: responsiveWidth,
      height: responsiveHeight,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      filterQuality: filterQuality,
    );
  }
}

/// A responsive icon widget that adapts its size to different screen sizes
class ResponsiveIcon extends StatelessWidget {
  /// The icon data
  final IconData icon;

  /// Base size (will be made responsive)
  final double? size;

  /// Color
  final Color? color;

  /// Semantic label
  final String? semanticLabel;

  /// Text direction
  final TextDirection? textDirection;

  /// Whether to apply responsive sizing
  final bool applyResponsiveSizing;

  /// Custom scale factor
  final double? scaleFactor;

  const ResponsiveIcon(
    this.icon, {
    Key? key,
    this.size,
    this.color,
    this.semanticLabel,
    this.textDirection,
    this.applyResponsiveSizing = true,
    this.scaleFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? responsiveSize = size;

    if (applyResponsiveSizing) {
      final baseSize = size ?? IconTheme.of(context).size ?? 24.0;
      responsiveSize = ResponsiveHelper.getResponsiveIconSize(
        context,
        baseSize,
      );

      if (scaleFactor != null) {
        responsiveSize *= scaleFactor!;
      }
    }

    return Icon(
      icon,
      size: responsiveSize,
      color: color,
      semanticLabel: semanticLabel,
      textDirection: textDirection,
    );
  }
}

/// A responsive card widget with adaptive padding and border radius
class ResponsiveCard extends StatelessWidget {
  /// The child widget
  final Widget? child;

  /// Base border radius (will be made responsive)
  final double? borderRadius;

  /// Base padding (will be made responsive)
  final EdgeInsets? padding;

  /// Base margin (will be made responsive)
  final EdgeInsets? margin;

  /// Background color
  final Color? color;

  /// Shadow color
  final Color? shadowColor;

  /// Surface tint color
  final Color? surfaceTintColor;

  /// Elevation
  final double? elevation;

  /// Shape
  final ShapeBorder? shape;

  /// Whether the card is semantic container
  final bool semanticContainer;

  /// Clip behavior
  final Clip? clipBehavior;

  /// Whether to apply responsive padding
  final bool applyResponsivePadding;

  /// Whether to apply responsive margin
  final bool applyResponsiveMargin;

  /// Whether to apply responsive border radius
  final bool applyResponsiveBorderRadius;

  const ResponsiveCard({
    Key? key,
    this.child,
    this.borderRadius,
    this.padding,
    this.margin,
    this.color,
    this.shadowColor,
    this.surfaceTintColor,
    this.elevation,
    this.shape,
    this.semanticContainer = true,
    this.clipBehavior,
    this.applyResponsivePadding = true,
    this.applyResponsiveMargin = true,
    this.applyResponsiveBorderRadius = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate responsive border radius
    final responsiveBorderRadius =
        borderRadius != null && applyResponsiveBorderRadius
            ? ResponsiveHelper.getResponsiveBorderRadius(context, borderRadius!)
            : borderRadius ?? 12.0;

    // Calculate responsive padding
    EdgeInsets? responsivePadding;
    if (padding != null && applyResponsivePadding) {
      responsivePadding = ResponsiveHelper.getResponsivePadding(
        context,
        horizontal: padding!.horizontal / 2,
        vertical: padding!.vertical / 2,
      );
    } else if (padding != null) {
      responsivePadding = padding;
    }

    // Calculate responsive margin
    EdgeInsets? responsiveMargin;
    if (margin != null && applyResponsiveMargin) {
      responsiveMargin = ResponsiveHelper.getResponsiveMargin(
        context,
        horizontal: margin!.horizontal / 2,
        vertical: margin!.vertical / 2,
      );
    } else if (margin != null) {
      responsiveMargin = margin;
    }

    Widget cardChild = child ?? Container();

    // Apply padding if specified
    if (responsivePadding != null) {
      cardChild = Padding(padding: responsivePadding, child: cardChild);
    }

    return Container(
      margin: responsiveMargin,
      child: Card(
        color: color,
        shadowColor: shadowColor,
        surfaceTintColor: surfaceTintColor,
        elevation: elevation,
        shape:
            shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsiveBorderRadius),
            ),
        semanticContainer: semanticContainer,
        clipBehavior: clipBehavior,
        child: cardChild,
      ),
    );
  }
}

/// A responsive button widget with adaptive padding and text size
class ResponsiveButton extends StatelessWidget {
  /// The button text
  final String text;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Base text style (will be made responsive)
  final TextStyle? textStyle;

  /// Base padding (will be made responsive)
  final EdgeInsets? padding;

  /// Background color
  final Color? backgroundColor;

  /// Foreground color
  final Color? foregroundColor;

  /// Button shape
  final OutlinedBorder? shape;

  /// Elevation
  final double? elevation;

  /// Whether to apply responsive text sizing
  final bool applyResponsiveTextSizing;

  /// Whether to apply responsive padding
  final bool applyResponsivePadding;

  /// Button type
  final ResponsiveButtonType type;

  const ResponsiveButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.textStyle,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.shape,
    this.elevation,
    this.applyResponsiveTextSizing = true,
    this.applyResponsivePadding = true,
    this.type = ResponsiveButtonType.elevated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate responsive text style
    TextStyle? responsiveTextStyle = textStyle;
    if (applyResponsiveTextSizing) {
      final baseStyle = textStyle ?? Theme.of(context).textTheme.labelLarge!;
      final baseFontSize = baseStyle.fontSize ?? 14.0;
      final responsiveFontSize = ResponsiveHelper.getResponsiveFontSize(
        context,
        baseFontSize,
      );

      responsiveTextStyle = baseStyle.copyWith(fontSize: responsiveFontSize);
    }

    // Calculate responsive padding
    EdgeInsets? responsivePadding = padding;
    if (applyResponsivePadding && padding != null) {
      responsivePadding = ResponsiveHelper.getResponsivePadding(
        context,
        horizontal: padding!.horizontal / 2,
        vertical: padding!.vertical / 2,
      );
    }

    final buttonStyle = ButtonStyle(
      backgroundColor:
          backgroundColor != null
              ? MaterialStateProperty.all(backgroundColor)
              : null,
      foregroundColor:
          foregroundColor != null
              ? MaterialStateProperty.all(foregroundColor)
              : null,
      padding:
          responsivePadding != null
              ? MaterialStateProperty.all(responsivePadding)
              : null,
      shape: shape != null ? MaterialStateProperty.all(shape) : null,
      elevation:
          elevation != null ? MaterialStateProperty.all(elevation) : null,
      textStyle:
          responsiveTextStyle != null
              ? MaterialStateProperty.all(responsiveTextStyle)
              : null,
    );

    switch (type) {
      case ResponsiveButtonType.elevated:
        return ElevatedButton(
          onPressed: onPressed,
          style: buttonStyle,
          child: Text(text),
        );
      case ResponsiveButtonType.outlined:
        return OutlinedButton(
          onPressed: onPressed,
          style: buttonStyle,
          child: Text(text),
        );
      case ResponsiveButtonType.text:
        return TextButton(
          onPressed: onPressed,
          style: buttonStyle,
          child: Text(text),
        );
    }
  }
}

/// Button types for ResponsiveButton
enum ResponsiveButtonType { elevated, outlined, text }
