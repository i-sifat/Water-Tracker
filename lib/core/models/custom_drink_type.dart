import 'package:equatable/equatable.dart';

/// Model representing a custom drink type created by premium users
class CustomDrinkType extends Equatable {
  const CustomDrinkType({
    required this.id,
    required this.name,
    required this.waterPercentage,
    this.icon,
    this.color,
    this.description,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory CustomDrinkType.fromJson(Map<String, dynamic> json) {
    return CustomDrinkType(
      id: json['id'] as String,
      name: json['name'] as String,
      waterPercentage: (json['waterPercentage'] as num).toDouble(),
      icon: json['icon'] as String?,
      color: json['color'] as int?,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
          : null,
    );
  }

  /// Create a new custom drink type
  factory CustomDrinkType.create({
    required String name,
    required double waterPercentage,
    String? icon,
    int? color,
    String? description,
  }) {
    final now = DateTime.now();
    return CustomDrinkType(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      waterPercentage: waterPercentage,
      icon: icon,
      color: color,
      description: description,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Unique identifier for this custom drink type
  final String id;

  /// Display name of the drink type
  final String name;

  /// Water content percentage (0.0 to 1.0)
  final double waterPercentage;

  /// Icon identifier or emoji for the drink type
  final String? icon;

  /// Color value for the drink type (ARGB format)
  final int? color;

  /// Optional description of the drink type
  final String? description;

  /// Whether this drink type is active/available
  final bool isActive;

  /// When this custom drink type was created
  final DateTime? createdAt;

  /// When this custom drink type was last updated
  final DateTime? updatedAt;

  /// Get water content for a given amount
  int getWaterContent(int amount) => (amount * waterPercentage).round();

  /// Create a copy with updated fields
  CustomDrinkType copyWith({
    String? id,
    String? name,
    double? waterPercentage,
    String? icon,
    int? color,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomDrinkType(
      id: id ?? this.id,
      name: name ?? this.name,
      waterPercentage: waterPercentage ?? this.waterPercentage,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'waterPercentage': waterPercentage,
      'icon': icon,
      'color': color,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        waterPercentage,
        icon,
        color,
        description,
        isActive,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'CustomDrinkType(id: $id, name: $name, waterPercentage: ${(waterPercentage * 100).toInt()}%)';
  }
}

/// Extension for working with lists of CustomDrinkType
extension CustomDrinkTypeList on List<CustomDrinkType> {
  /// Get only active drink types
  List<CustomDrinkType> get active => where((type) => type.isActive).toList();

  /// Find by name
  CustomDrinkType? findByName(String name) {
    try {
      return firstWhere((type) => type.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  /// Find by ID
  CustomDrinkType? findById(String id) {
    try {
      return firstWhere((type) => type.id == id);
    } catch (e) {
      return null;
    }
  }
}
