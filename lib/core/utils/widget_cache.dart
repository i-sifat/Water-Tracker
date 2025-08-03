import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Cache for frequently used widgets to improve performance
class WidgetCache {
  static final Map<String, Widget> _widgetCache = {};
  static final Map<String, Uint8List> _imageCache = {};
  static final Map<String, SvgPicture> _svgCache = {};
  static int _maxCacheSize = 50;
  static final List<String> _accessOrder = [];

  /// Set maximum cache size (default: 50)
  static void setMaxCacheSize(int size) {
    _maxCacheSize = size;
    _evictOldestIfNeeded();
  }

  /// Cache a widget with a unique key
  static void cacheWidget(String key, Widget widget) {
    if (_widgetCache.length >= _maxCacheSize) {
      _evictOldest();
    }

    _widgetCache[key] = widget;
    _updateAccessOrder(key);
  }

  /// Get a cached widget
  static Widget? getCachedWidget(String key) {
    if (_widgetCache.containsKey(key)) {
      _updateAccessOrder(key);
      return _widgetCache[key];
    }
    return null;
  }

  /// Cache an SVG widget
  static void cacheSvg(String key, SvgPicture svg) {
    if (_svgCache.length >= _maxCacheSize) {
      _evictOldestSvg();
    }

    _svgCache[key] = svg;
    _updateAccessOrder(key);
  }

  /// Get a cached SVG widget
  static SvgPicture? getCachedSvg(String key) {
    if (_svgCache.containsKey(key)) {
      _updateAccessOrder(key);
      return _svgCache[key];
    }
    return null;
  }

  /// Cache image data
  static void cacheImageData(String key, Uint8List data) {
    if (_imageCache.length >= _maxCacheSize) {
      _evictOldestImage();
    }

    _imageCache[key] = data;
    _updateAccessOrder(key);
  }

  /// Get cached image data
  static Uint8List? getCachedImageData(String key) {
    if (_imageCache.containsKey(key)) {
      _updateAccessOrder(key);
      return _imageCache[key];
    }
    return null;
  }

  /// Update access order for LRU eviction
  static void _updateAccessOrder(String key) {
    _accessOrder
      ..remove(key)
      ..add(key);
  }

  /// Evict oldest widget
  static void _evictOldest() {
    if (_accessOrder.isNotEmpty) {
      final oldestKey = _accessOrder.removeAt(0);
      _widgetCache.remove(oldestKey);
    }
  }

  /// Evict oldest SVG
  static void _evictOldestSvg() {
    if (_accessOrder.isNotEmpty) {
      final oldestKey = _accessOrder.removeAt(0);
      _svgCache.remove(oldestKey);
    }
  }

  /// Evict oldest image
  static void _evictOldestImage() {
    if (_accessOrder.isNotEmpty) {
      final oldestKey = _accessOrder.removeAt(0);
      _imageCache.remove(oldestKey);
    }
  }

  /// Evict oldest items if cache is over limit
  static void _evictOldestIfNeeded() {
    while (_widgetCache.length > _maxCacheSize) {
      _evictOldest();
    }
    while (_svgCache.length > _maxCacheSize) {
      _evictOldestSvg();
    }
    while (_imageCache.length > _maxCacheSize) {
      _evictOldestImage();
    }
  }

  /// Clear specific cache
  static void clearCache({String? key}) {
    if (key != null) {
      _widgetCache.remove(key);
      _svgCache.remove(key);
      _imageCache.remove(key);
      _accessOrder.remove(key);
    } else {
      _widgetCache.clear();
      _svgCache.clear();
      _imageCache.clear();
      _accessOrder.clear();
    }
  }

  /// Get cache statistics
  static Map<String, int> getCacheStats() {
    return {
      'widgets': _widgetCache.length,
      'svgs': _svgCache.length,
      'images': _imageCache.length,
      'maxSize': _maxCacheSize,
    };
  }

  /// Preload commonly used widgets
  static void preloadCommonWidgets() {
    // Preload common icons
    _preloadIcon('settings', Icons.settings);
    _preloadIcon('water_drop', Icons.water_drop);
    _preloadIcon('add', Icons.add);
    _preloadIcon('remove', Icons.remove);
    _preloadIcon('check', Icons.check);
    _preloadIcon('close', Icons.close);
  }

  static void _preloadIcon(String key, IconData icon) {
    final iconWidget = Icon(icon);
    cacheWidget('icon_$key', iconWidget);
  }
}

/// Cached avatar widget that reuses avatar instances
class CachedAvatarWidget extends StatelessWidget {
  const CachedAvatarWidget({
    required this.avatarPath,
    required this.width,
    required this.height,
    super.key,
    this.colorFilter,
  });

  final String avatarPath;
  final double width;
  final double height;
  final ColorFilter? colorFilter;

  @override
  Widget build(BuildContext context) {
    final cacheKey = '${avatarPath}_${width}_${height}_${colorFilter.hashCode}';

    // Try to get from cache first
    final cachedWidget = WidgetCache.getCachedWidget(cacheKey);
    if (cachedWidget != null) {
      return cachedWidget;
    }

    // Create new widget and cache it
    final widget = SvgPicture.asset(
      avatarPath,
      width: width,
      height: height,
      colorFilter: colorFilter,
    );

    WidgetCache.cacheWidget(cacheKey, widget);
    return widget;
  }
}

/// Cached icon widget
class CachedIconWidget extends StatelessWidget {
  const CachedIconWidget({
    required this.icon,
    super.key,
    this.size,
    this.color,
  });

  final IconData icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cacheKey =
        'icon_${icon.codePoint}_${size}_${color?.value.toRadixString(16)}';

    // Try to get from cache first
    final cachedWidget = WidgetCache.getCachedWidget(cacheKey);
    if (cachedWidget != null) {
      return cachedWidget;
    }

    // Create new widget and cache it
    final widget = Icon(icon, size: size, color: color);

    WidgetCache.cacheWidget(cacheKey, widget);
    return widget;
  }
}

/// Lazy loading widget for heavy content
class LazyLoadingWidget extends StatefulWidget {
  const LazyLoadingWidget({
    required this.builder,
    super.key,
    this.placeholder,
    this.threshold = 200.0,
  });

  final Widget Function(BuildContext context) builder;
  final Widget? placeholder;
  final double threshold;

  @override
  State<LazyLoadingWidget> createState() => _LazyLoadingWidgetState();
}

class _LazyLoadingWidgetState extends State<LazyLoadingWidget> {
  bool _isVisible = false;
  Widget? _cachedWidget;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (!_isVisible) {
              final renderBox = context.findRenderObject() as RenderBox?;
              if (renderBox != null) {
                final position = renderBox.localToGlobal(Offset.zero);
                final screenHeight = MediaQuery.of(context).size.height;

                if (position.dy < screenHeight + widget.threshold) {
                  setState(() {
                    _isVisible = true;
                  });
                }
              }
            }
            return false;
          },
          child:
              _isVisible
                  ? (_cachedWidget ??= widget.builder(context))
                  : (widget.placeholder ?? const SizedBox.shrink()),
        );
      },
    );
  }
}

/// Lazy loading list view for better performance
class LazyLoadingListView extends StatefulWidget {
  const LazyLoadingListView({
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.cacheExtent = 250.0,
    this.physics,
    this.shrinkWrap = false,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final double cacheExtent;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  @override
  State<LazyLoadingListView> createState() => _LazyLoadingListViewState();
}

class _LazyLoadingListViewState extends State<LazyLoadingListView> {
  final Map<int, Widget> _cachedItems = {};
  final Set<int> _visibleItems = {};

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.itemCount,
      cacheExtent: widget.cacheExtent,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      itemBuilder: (context, index) {
        _visibleItems.add(index);

        // Return cached item if available
        if (_cachedItems.containsKey(index)) {
          return _cachedItems[index]!;
        }

        // Build and cache new item
        final item = widget.itemBuilder(context, index);
        _cachedItems[index] = item;

        // Clean up cache if it gets too large
        if (_cachedItems.length > 100) {
          _cleanupCache();
        }

        return item;
      },
    );
  }

  void _cleanupCache() {
    // Remove items that are far from visible area
    final visibleIndices = _visibleItems.toList()..sort();
    if (visibleIndices.isNotEmpty) {
      final minVisible = visibleIndices.first;
      final maxVisible = visibleIndices.last;

      _cachedItems.removeWhere((index, widget) {
        return index < minVisible - 10 || index > maxVisible + 10;
      });
    }
  }

  @override
  void dispose() {
    _cachedItems.clear();
    _visibleItems.clear();
    super.dispose();
  }
}

/// Memory-managed widget cache that automatically cleans up
class ManagedWidgetCache {
  static final Map<String, _CacheEntry> _cache = {};
  static const int _maxMemoryUsage = 50 * 1024 * 1024; // 50MB
  static int _currentMemoryUsage = 0;

  static void cacheWidget(
    String key,
    Widget widget, {
    int estimatedSize = 1024,
  }) {
    // Remove old entry if exists
    if (_cache.containsKey(key)) {
      _currentMemoryUsage -= _cache[key]!.estimatedSize;
    }

    // Add new entry
    _cache[key] = _CacheEntry(
      widget: widget,
      estimatedSize: estimatedSize,
      lastAccessed: DateTime.now(),
    );
    _currentMemoryUsage += estimatedSize;

    // Clean up if memory usage is too high
    if (_currentMemoryUsage > _maxMemoryUsage) {
      _cleanupMemory();
    }
  }

  static Widget? getCachedWidget(String key) {
    final entry = _cache[key];
    if (entry != null) {
      entry.lastAccessed = DateTime.now();
      return entry.widget;
    }
    return null;
  }

  static void _cleanupMemory() {
    // Sort by last accessed time and remove oldest entries
    final entries =
        _cache.entries.toList()..sort(
          (a, b) => a.value.lastAccessed.compareTo(b.value.lastAccessed),
        );

    while (_currentMemoryUsage > _maxMemoryUsage * 0.8 && entries.isNotEmpty) {
      final entry = entries.removeAt(0);
      _currentMemoryUsage -= entry.value.estimatedSize;
      _cache.remove(entry.key);
    }
  }

  static void clearCache() {
    _cache.clear();
    _currentMemoryUsage = 0;
  }

  static Map<String, dynamic> getMemoryStats() {
    return {
      'cacheSize': _cache.length,
      'memoryUsage': _currentMemoryUsage,
      'maxMemoryUsage': _maxMemoryUsage,
    };
  }
}

class _CacheEntry {
  _CacheEntry({
    required this.widget,
    required this.estimatedSize,
    required this.lastAccessed,
  });

  final Widget widget;
  final int estimatedSize;
  DateTime lastAccessed;
}
