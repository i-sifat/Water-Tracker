import 'package:equatable/equatable.dart';
import 'package:watertracker/core/constants/premium_features.dart';

/// Model representing premium status and related data
class PremiumStatus extends Equatable {
  const PremiumStatus({
    required this.isPremium,
    required this.deviceCode,
    this.unlockCode,
    this.unlockedAt,
    this.expiresAt,
    this.unlockedFeatures = const [],
  });

  /// Create from JSON
  factory PremiumStatus.fromJson(Map<String, dynamic> json) {
    return PremiumStatus(
      isPremium: json['isPremium'] as bool,
      deviceCode: json['deviceCode'] as String,
      unlockCode: json['unlockCode'] as String?,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['unlockedAt'] as int)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['expiresAt'] as int)
          : null,
      unlockedFeatures: (json['unlockedFeatures'] as List<dynamic>?)
          ?.map((f) => PremiumFeature.values.firstWhere(
                (e) => e.name == f,
                orElse: () => PremiumFeature.advancedAnalytics,
              ))
          .toList() ?? [],
    );
  }

  /// Create a free status with device code
  factory PremiumStatus.free(String deviceCode) {
    return PremiumStatus(
      isPremium: false,
      deviceCode: deviceCode,
    );
  }

  /// Create a premium status
  factory PremiumStatus.premium({
    required String deviceCode,
    required String unlockCode,
    DateTime? expiresAt,
    List<PremiumFeature>? features,
  }) {
    return PremiumStatus(
      isPremium: true,
      deviceCode: deviceCode,
      unlockCode: unlockCode,
      unlockedAt: DateTime.now(),
      expiresAt: expiresAt,
      unlockedFeatures: features ?? PremiumFeature.values,
    );
  }

  /// Whether the user has premium access
  final bool isPremium;

  /// Unique device code for this installation
  final String deviceCode;

  /// The unlock code used to activate premium (if any)
  final String? unlockCode;

  /// When premium was unlocked
  final DateTime? unlockedAt;

  /// When premium expires (null for lifetime)
  final DateTime? expiresAt;

  /// List of specifically unlocked features
  final List<PremiumFeature> unlockedFeatures;

  /// Check if premium is currently active (not expired)
  bool get isActive {
    if (!isPremium) return false;
    if (expiresAt == null) return true; // Lifetime
    return DateTime.now().isBefore(expiresAt!);
  }

  /// Check if a specific feature is unlocked
  bool isFeatureUnlocked(PremiumFeature feature) {
    if (!isActive) return false;
    return unlockedFeatures.isEmpty || unlockedFeatures.contains(feature);
  }

  /// Get days remaining until expiration (null for lifetime)
  int? get daysRemaining {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expiresAt!)) return 0;
    return expiresAt!.difference(now).inDays;
  }

  /// Create a copy with updated fields
  PremiumStatus copyWith({
    bool? isPremium,
    String? deviceCode,
    String? unlockCode,
    DateTime? unlockedAt,
    DateTime? expiresAt,
    List<PremiumFeature>? unlockedFeatures,
  }) {
    return PremiumStatus(
      isPremium: isPremium ?? this.isPremium,
      deviceCode: deviceCode ?? this.deviceCode,
      unlockCode: unlockCode ?? this.unlockCode,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      unlockedFeatures: unlockedFeatures ?? this.unlockedFeatures,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'isPremium': isPremium,
      'deviceCode': deviceCode,
      'unlockCode': unlockCode,
      'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
      'expiresAt': expiresAt?.millisecondsSinceEpoch,
      'unlockedFeatures': unlockedFeatures.map((f) => f.name).toList(),
    };
  }

  @override
  List<Object?> get props => [
    isPremium, deviceCode, unlockCode, unlockedAt, expiresAt, unlockedFeatures,
  ];

  @override
  String toString() {
    return 'PremiumStatus(isPremium: $isPremium, deviceCode: $deviceCode, active: $isActive)';
  }
}

/// Model for donation proof submission
class DonationProof extends Equatable {
  const DonationProof({
    required this.id,
    required this.deviceCode,
    required this.imagePath,
    required this.submittedAt,
    this.amount,
    this.transactionId,
    this.notes,
    this.status = DonationProofStatus.pending,
  });

  /// Create from JSON
  factory DonationProof.fromJson(Map<String, dynamic> json) {
    return DonationProof(
      id: json['id'] as String,
      deviceCode: json['deviceCode'] as String,
      imagePath: json['imagePath'] as String,
      submittedAt: DateTime.fromMillisecondsSinceEpoch(json['submittedAt'] as int),
      amount: json['amount'] as double?,
      transactionId: json['transactionId'] as String?,
      notes: json['notes'] as String?,
      status: DonationProofStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DonationProofStatus.pending,
      ),
    );
  }

  /// Create a new donation proof
  factory DonationProof.create({
    required String deviceCode,
    required String imagePath,
    double? amount,
    String? transactionId,
    String? notes,
  }) {
    return DonationProof(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      deviceCode: deviceCode,
      imagePath: imagePath,
      submittedAt: DateTime.now(),
      amount: amount,
      transactionId: transactionId,
      notes: notes,
    );
  }

  /// Unique identifier for this submission
  final String id;

  /// Device code associated with this proof
  final String deviceCode;

  /// Path to the proof image
  final String imagePath;

  /// When the proof was submitted
  final DateTime submittedAt;

  /// Donation amount (optional)
  final double? amount;

  /// Transaction ID from bKash (optional)
  final String? transactionId;

  /// Additional notes from user
  final String? notes;

  /// Status of the proof submission
  final DonationProofStatus status;

  /// Create a copy with updated fields
  DonationProof copyWith({
    String? id,
    String? deviceCode,
    String? imagePath,
    DateTime? submittedAt,
    double? amount,
    String? transactionId,
    String? notes,
    DonationProofStatus? status,
  }) {
    return DonationProof(
      id: id ?? this.id,
      deviceCode: deviceCode ?? this.deviceCode,
      imagePath: imagePath ?? this.imagePath,
      submittedAt: submittedAt ?? this.submittedAt,
      amount: amount ?? this.amount,
      transactionId: transactionId ?? this.transactionId,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceCode': deviceCode,
      'imagePath': imagePath,
      'submittedAt': submittedAt.millisecondsSinceEpoch,
      'amount': amount,
      'transactionId': transactionId,
      'notes': notes,
      'status': status.name,
    };
  }

  @override
  List<Object?> get props => [
    id, deviceCode, imagePath, submittedAt, amount, transactionId, notes, status,
  ];

  @override
  String toString() {
    return 'DonationProof(id: $id, deviceCode: $deviceCode, status: $status)';
  }
}

/// Status of donation proof submission
enum DonationProofStatus {
  pending,
  approved,
  rejected,
  expired;

  String get displayName {
    switch (this) {
      case DonationProofStatus.pending:
        return 'Pending Review';
      case DonationProofStatus.approved:
        return 'Approved';
      case DonationProofStatus.rejected:
        return 'Rejected';
      case DonationProofStatus.expired:
        return 'Expired';
    }
  }

  String get description {
    switch (this) {
      case DonationProofStatus.pending:
        return 'Your donation proof is being reviewed';
      case DonationProofStatus.approved:
        return 'Your donation has been verified';
      case DonationProofStatus.rejected:
        return 'Your donation proof was not accepted';
      case DonationProofStatus.expired:
        return 'Your submission has expired';
    }
  }
}

/// Model for unlock code validation
class UnlockCodeValidation extends Equatable {
  const UnlockCodeValidation({
    required this.isValid,
    required this.deviceCode,
    this.unlockCode,
    this.features,
    this.expiresAt,
    this.errorMessage,
  });

  /// Create a successful validation
  factory UnlockCodeValidation.success({
    required String deviceCode,
    required String unlockCode,
    List<PremiumFeature>? features,
    DateTime? expiresAt,
  }) {
    return UnlockCodeValidation(
      isValid: true,
      deviceCode: deviceCode,
      unlockCode: unlockCode,
      features: features ?? PremiumFeature.values,
      expiresAt: expiresAt,
    );
  }

  /// Create a failed validation
  factory UnlockCodeValidation.failure({
    required String deviceCode,
    required String errorMessage,
  }) {
    return UnlockCodeValidation(
      isValid: false,
      deviceCode: deviceCode,
      errorMessage: errorMessage,
    );
  }

  /// Whether the unlock code is valid
  final bool isValid;

  /// Device code that was validated
  final String deviceCode;

  /// The unlock code that was validated
  final String? unlockCode;

  /// Features unlocked by this code
  final List<PremiumFeature>? features;

  /// When the unlock expires (null for lifetime)
  final DateTime? expiresAt;

  /// Error message if validation failed
  final String? errorMessage;

  @override
  List<Object?> get props => [
    isValid, deviceCode, unlockCode, features, expiresAt, errorMessage,
  ];

  @override
  String toString() {
    return 'UnlockCodeValidation(isValid: $isValid, deviceCode: $deviceCode, error: $errorMessage)';
  }
}
