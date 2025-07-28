import 'dart:io';

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Utility class for optimizing image loading and caching
class ImageOptimization {
  static const int _maxCacheSize = 50 << 20; // 50MB
  static const int _maxImageDimension = 1024;
  static final Map<String, Uint8List> _memoryCache = {};
  static int _currentCacheSize = 0;

  /// Initialize image optimization settings
  static void initialize() {
    // Configure Flutter's image cache
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = _maxCacheSize;
    
    if (kDebugMode) {
      debugPrint('ImageOptimization initialized with ${_maxCacheSize ~/ (1024 * 1024)}MB cache');
    }
  }

  /// Optimized image widget with lazy loading and caching
  static Widget optimizedImage({
    required String imagePath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    bool enableMemoryCache = true,
    bool enableDiskCache = true,
  }) {
    return OptimizedImageWidget(
      imagePath: imagePath,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
      enableMemoryCache: enableMemoryCache,
      enableDiskCache: enableDiskCache,
    );
  }

  /// Preload and optimize an image
  static Future<void> preloadImage(String imagePath, BuildContext context) async {
    try {
      final imageProvider = _getOptimizedImageProvider(imagePath);
      await precacheImage(imageProvider, context);
    } catch (e) {
      debugPrint('Error preloading image $imagePath: $e');
    }
  }

  /// Get optimized image provider
  static ImageProvider _getOptimizedImageProvider(String imagePath) {
    if (imagePath.startsWith('http')) {
      return NetworkImage(imagePath);
    } else if (imagePath.startsWith('assets/')) {
      return AssetImage(imagePath);
    } else {
      return FileImage(File(imagePath));
    }
  }

  /// Resize image to reduce memory usage
  static Future<Uint8List> resizeImage(
    Uint8List imageData, {
    int? maxWidth,
    int? maxHeight,
    int quality = 85,
  }) async {
    try {
      final codec = await ui.instantiateImageCodec(
        imageData,
        targetWidth: maxWidth ?? _maxImageDimension,
        targetHeight: maxHeight ?? _maxImageDimension,
      );
      
      final frame = await codec.getNextFrame();
      final resizedImage = frame.image;
      
      final byteData = await resizedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      
      return byteData!.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error resizing image: $e');
      return imageData;
    }
  }

  /// Cache image in memory
  static void _cacheInMemory(String key, Uint8List data) {
    if (!kIsWeb && data.length < 5 << 20) { // Don't cache images > 5MB
      // Remove old entries if cache is full
      while (_currentCacheSize + data.length > _maxCacheSize && _memoryCache.isNotEmpty) {
        final oldestKey = _memoryCache.keys.first;
        final oldData = _memoryCache.remove(oldestKey);
        if (oldData != null) {
          _currentCacheSize -= oldData.length;
        }
      }
      
      _memoryCache[key] = data;
      _currentCacheSize += data.length;
    }
  }

  /// Get image from memory cache
  static Uint8List? _getFromMemoryCache(String key) {
    return _memoryCache[key];
  }

  /// Clear memory cache
  static void clearMemoryCache() {
    _memoryCache.clear();
    _currentCacheSize = 0;
    
    // Also clear Flutter's image cache
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    
    if (kDebugMode) {
      debugPrint('Image caches cleared');
    }
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {
      'memory_cache_size': _currentCacheSize,
      'memory_cache_count': _memoryCache.length,
      'flutter_cache_size': PaintingBinding.instance.imageCache.currentSizeBytes,
      'flutter_cache_count': PaintingBinding.instance.imageCache.currentSize,
      'flutter_cache_live_count': PaintingBinding.instance.imageCache.liveImageCount,
    };
  }

  /// Optimize image file size
  static Future<File> optimizeImageFile(
    File imageFile, {
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 85,
  }) async {
    try {
      final imageData = await imageFile.readAsBytes();
      final optimizedData = await resizeImage(
        imageData,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        quality: quality,
      );
      
      final tempDir = await getTemporaryDirectory();
      final optimizedFile = File('${tempDir.path}/optimized_${DateTime.now().millisecondsSinceEpoch}.png');
      await optimizedFile.writeAsBytes(optimizedData);
      
      return optimizedFile;
    } catch (e) {
      debugPrint('Error optimizing image file: $e');
      return imageFile;
    }
  }
}

/// Optimized image widget with advanced caching and loading
class OptimizedImageWidget extends StatefulWidget {
  const OptimizedImageWidget({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.enableMemoryCache = true,
    this.enableDiskCache = true,
  });

  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableMemoryCache;
  final bool enableDiskCache;

  @override
  State<OptimizedImageWidget> createState() => _OptimizedImageWidgetState();
}

class _OptimizedImageWidgetState extends State<OptimizedImageWidget>
    with AutomaticKeepAliveClientMixin {
  late ImageProvider? _imageProvider;
  bool _isLoading = true;
  bool _hasError = false;


  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(OptimizedImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imagePath != oldWidget.imagePath) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Check memory cache first
      if (widget.enableMemoryCache) {
        final cachedData = ImageOptimization._getFromMemoryCache(widget.imagePath);
        if (cachedData != null) {
          _imageProvider = MemoryImage(cachedData);
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
          return;
        }
      }

      // Load image
      _imageProvider = ImageOptimization._getOptimizedImageProvider(widget.imagePath);
      
      // Preload to check for errors
      if (mounted) {
        await precacheImage(_imageProvider!, context);
        
        // Cache in memory if enabled
        if (widget.enableMemoryCache && !widget.imagePath.startsWith('http')) {
          try {
            Uint8List? imageData;
            
            if (widget.imagePath.startsWith('assets/')) {
              final byteData = await rootBundle.load(widget.imagePath);
              imageData = byteData.buffer.asUint8List();
            } else {
              final file = File(widget.imagePath);
              if (await file.exists()) {
                imageData = await file.readAsBytes();
              }
            }
            
            if (imageData != null) {
              ImageOptimization._cacheInMemory(widget.imagePath, imageData);
            }
          } catch (e) {
            debugPrint('Error caching image: $e');
          }
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return widget.placeholder ?? 
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
    }

    if (_hasError) {
      return widget.errorWidget ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[200],
            child: const Icon(
              Icons.error_outline,
              color: Colors.grey,
            ),
          );
    }

    return Image(
      image: _imageProvider!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return widget.errorWidget ??
            Container(
              width: widget.width,
              height: widget.height,
              color: Colors.grey[200],
              child: const Icon(
                Icons.error_outline,
                color: Colors.grey,
              ),
            );
      },
    );
  }
}

/// Image preloader for batch loading
class ImagePreloader {
  static final Map<String, Future<void>> _preloadingTasks = {};

  /// Preload multiple images
  static Future<void> preloadImages(
    List<String> imagePaths,
    BuildContext context, {
    int maxConcurrent = 3,
  }) async {
    final futures = <Future<void>>[];
    
    for (int i = 0; i < imagePaths.length; i += maxConcurrent) {
      final batch = imagePaths.skip(i).take(maxConcurrent);
      final batchFutures = batch.map((path) => _preloadSingle(path, context));
      
      futures.addAll(batchFutures);
      
      // Wait for current batch before starting next
      await Future.wait(batchFutures);
    }
  }

  static Future<void> _preloadSingle(String imagePath, BuildContext context) async {
    // Avoid duplicate preloading
    if (_preloadingTasks.containsKey(imagePath)) {
      return _preloadingTasks[imagePath]!;
    }

    final task = ImageOptimization.preloadImage(imagePath, context);
    _preloadingTasks[imagePath] = task;

    try {
      await task;
    } finally {
      _preloadingTasks.remove(imagePath);
    }
  }

  /// Clear preloading tasks
  static void clearTasks() {
    _preloadingTasks.clear();
  }
}
