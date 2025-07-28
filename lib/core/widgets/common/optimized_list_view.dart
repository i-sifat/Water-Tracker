import 'dart:async';

import 'package:flutter/material.dart';
import 'package:watertracker/core/services/performance_service.dart';

/// Optimized list view with lazy loading, caching, and performance monitoring
class OptimizedListView<T> extends StatefulWidget {
  const OptimizedListView({
    required this.items, required this.itemBuilder, super.key,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.onLoadMore,
    this.hasMore = false,
    this.loadMoreThreshold = 5,
    this.cacheExtent = 250.0,
    this.physics,
    this.padding,
    this.shrinkWrap = false,
    this.reverse = false,
    this.separatorBuilder,
    this.enablePerformanceMonitoring = true,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final Future<void> Function()? onLoadMore;
  final bool hasMore;
  final int loadMoreThreshold;
  final double cacheExtent;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final bool reverse;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final bool enablePerformanceMonitoring;

  @override
  State<OptimizedListView<T>> createState() => _OptimizedListViewState<T>();
}

class _OptimizedListViewState<T> extends State<OptimizedListView<T>>
    with PerformanceMonitorMixin, AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final Map<int, Widget> _widgetCache = {};
  bool _isLoadingMore = false;
  Object? _error;
  Timer? _scrollEndTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    if (widget.enablePerformanceMonitoring) {
      startPerformanceTimer('list_view_init');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        endPerformanceTimer('list_view_init');
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollEndTimer?.cancel();
    _widgetCache.clear();
    super.dispose();
  }

  void _onScroll() {
    // Cancel previous timer
    _scrollEndTimer?.cancel();

    // Set new timer for scroll end detection
    _scrollEndTimer = Timer(const Duration(milliseconds: 150), _checkLoadMore);
  }

  void _checkLoadMore() {
    if (!widget.hasMore || _isLoadingMore || widget.onLoadMore == null) return;

    final position = _scrollController.position;
    final threshold =
        position.maxScrollExtent - (widget.loadMoreThreshold * 100);

    if (position.pixels >= threshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _error = null;
    });

    try {
      if (widget.enablePerformanceMonitoring) {
        startPerformanceTimer('load_more');
      }

      await widget.onLoadMore!();

      if (widget.enablePerformanceMonitoring) {
        endPerformanceTimer('load_more');
      }
    } catch (error) {
      setState(() {
        _error = error;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Widget _buildCachedItem(BuildContext context, int index) {
    // Check cache first
    if (_widgetCache.containsKey(index)) {
      return _widgetCache[index]!;
    }

    // Build new widget
    final item = widget.items[index];
    final widget_ = widget.itemBuilder(context, item, index);

    // Cache the widget (limit cache size)
    if (_widgetCache.length < 50) {
      _widgetCache[index] = widget_;
    }

    return widget_;
  }

  void _clearCache() {
    _widgetCache.clear();
  }

  @override
  void didUpdateWidget(OptimizedListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Clear cache if items changed significantly
    if (widget.items.length != oldWidget.items.length ||
        widget.items.hashCode != oldWidget.items.hashCode) {
      _clearCache();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.items.isEmpty) {
      return widget.emptyBuilder?.call(context) ??
          const Center(child: Text('No items'));
    }

    if (_error != null && widget.errorBuilder != null) {
      return widget.errorBuilder!(context, _error!);
    }

    return RefreshIndicator(
      onRefresh: () async {
        _clearCache();
        if (widget.onLoadMore != null) {
          await widget.onLoadMore!();
        }
      },
      child: ListView.separated(
        controller: _scrollController,
        physics: widget.physics,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        reverse: widget.reverse,
        cacheExtent: widget.cacheExtent,
        itemCount: widget.items.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder:
            widget.separatorBuilder ?? (_, __) => const SizedBox.shrink(),
        itemBuilder: (context, index) {
          if (index >= widget.items.length) {
            // Loading indicator
            return widget.loadingBuilder?.call(context) ??
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
          }

          return _buildCachedItem(context, index);
        },
      ),
    );
  }
}

/// Optimized grid view with similar performance features
class OptimizedGridView<T> extends StatefulWidget {
  const OptimizedGridView({
    required this.items, required this.itemBuilder, required this.crossAxisCount, super.key,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.onLoadMore,
    this.hasMore = false,
    this.loadMoreThreshold = 5,
    this.cacheExtent = 250.0,
    this.physics,
    this.padding,
    this.shrinkWrap = false,
    this.reverse = false,
    this.crossAxisSpacing = 0.0,
    this.mainAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
    this.enablePerformanceMonitoring = true,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int crossAxisCount;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final Future<void> Function()? onLoadMore;
  final bool hasMore;
  final int loadMoreThreshold;
  final double cacheExtent;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final bool reverse;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final bool enablePerformanceMonitoring;

  @override
  State<OptimizedGridView<T>> createState() => _OptimizedGridViewState<T>();
}

class _OptimizedGridViewState<T> extends State<OptimizedGridView<T>>
    with PerformanceMonitorMixin, AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final Map<int, Widget> _widgetCache = {};
  bool _isLoadingMore = false;
  Object? _error;
  Timer? _scrollEndTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    if (widget.enablePerformanceMonitoring) {
      startPerformanceTimer('grid_view_init');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        endPerformanceTimer('grid_view_init');
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollEndTimer?.cancel();
    _widgetCache.clear();
    super.dispose();
  }

  void _onScroll() {
    _scrollEndTimer?.cancel();
    _scrollEndTimer = Timer(const Duration(milliseconds: 150), _checkLoadMore);
  }

  void _checkLoadMore() {
    if (!widget.hasMore || _isLoadingMore || widget.onLoadMore == null) return;

    final position = _scrollController.position;
    final threshold =
        position.maxScrollExtent - (widget.loadMoreThreshold * 100);

    if (position.pixels >= threshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _error = null;
    });

    try {
      if (widget.enablePerformanceMonitoring) {
        startPerformanceTimer('grid_load_more');
      }

      await widget.onLoadMore!();

      if (widget.enablePerformanceMonitoring) {
        endPerformanceTimer('grid_load_more');
      }
    } catch (error) {
      setState(() {
        _error = error;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Widget _buildCachedItem(BuildContext context, int index) {
    if (_widgetCache.containsKey(index)) {
      return _widgetCache[index]!;
    }

    final item = widget.items[index];
    final widget_ = widget.itemBuilder(context, item, index);

    if (_widgetCache.length < 50) {
      _widgetCache[index] = widget_;
    }

    return widget_;
  }

  void _clearCache() {
    _widgetCache.clear();
  }

  @override
  void didUpdateWidget(OptimizedGridView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.items.length != oldWidget.items.length ||
        widget.items.hashCode != oldWidget.items.hashCode) {
      _clearCache();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.items.isEmpty) {
      return widget.emptyBuilder?.call(context) ??
          const Center(child: Text('No items'));
    }

    if (_error != null && widget.errorBuilder != null) {
      return widget.errorBuilder!(context, _error!);
    }

    return RefreshIndicator(
      onRefresh: () async {
        _clearCache();
        if (widget.onLoadMore != null) {
          await widget.onLoadMore!();
        }
      },
      child: GridView.builder(
        controller: _scrollController,
        physics: widget.physics,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        reverse: widget.reverse,
        cacheExtent: widget.cacheExtent,
        itemCount: widget.items.length + (_isLoadingMore ? 1 : 0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossAxisCount,
          crossAxisSpacing: widget.crossAxisSpacing,
          mainAxisSpacing: widget.mainAxisSpacing,
          childAspectRatio: widget.childAspectRatio,
        ),
        itemBuilder: (context, index) {
          if (index >= widget.items.length) {
            return widget.loadingBuilder?.call(context) ??
                const Center(child: CircularProgressIndicator());
          }

          return _buildCachedItem(context, index);
        },
      ),
    );
  }
}

/// Lazy loading data source for paginated data
abstract class LazyDataSource<T> {
  Future<List<T>> loadPage(int page, int pageSize);
  bool get hasMore;
  int get totalCount;
  void reset();
}

/// Implementation of lazy data source with caching
class CachedLazyDataSource<T> extends LazyDataSource<T> {
  CachedLazyDataSource({
    required this.loadPageCallback,
    this.pageSize = 20,
    this.maxCacheSize = 100,
  });

  final Future<List<T>> Function(int page, int pageSize) loadPageCallback;
  final int pageSize;
  final int maxCacheSize;

  final Map<int, List<T>> _pageCache = {};
  final List<T> _allItems = [];
  bool _hasMore = true;
  int _totalCount = 0;
  int _currentPage = 0;

  @override
  bool get hasMore => _hasMore;

  @override
  int get totalCount => _totalCount;

  List<T> get items => List.unmodifiable(_allItems);

  @override
  Future<List<T>> loadPage(int page, int pageSize) async {
    // Check cache first
    if (_pageCache.containsKey(page)) {
      return _pageCache[page]!;
    }

    // Load from source
    final items = await loadPageCallback(page, pageSize);

    // Update state
    _pageCache[page] = items;
    _hasMore = items.length == pageSize;
    _currentPage = page;

    // Add to all items if loading sequentially
    if (page == (_allItems.length / pageSize).floor()) {
      _allItems.addAll(items);
    }

    // Limit cache size
    if (_pageCache.length > maxCacheSize) {
      final oldestPage = _pageCache.keys.reduce((a, b) => a < b ? a : b);
      _pageCache.remove(oldestPage);
    }

    return items;
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;

    final nextPage = _currentPage + 1;
    await loadPage(nextPage, pageSize);
  }

  @override
  void reset() {
    _pageCache.clear();
    _allItems.clear();
    _hasMore = true;
    _totalCount = 0;
    _currentPage = 0;
  }

  void invalidateCache() {
    _pageCache.clear();
  }
}
