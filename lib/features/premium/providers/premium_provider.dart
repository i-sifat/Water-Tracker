import 'dart:io';
import 'package:flutter/material.dart';
import 'package:watertracker/core/constants/premium_features.dart';
import 'package:watertracker/core/models/app_error.dart';
import 'package:watertracker/core/models/premium_models.dart';
import 'package:watertracker/core/services/device_service.dart';
import 'package:watertracker/core/services/premium_service.dart' as premium_service;
import 'package:watertracker/core/services/storage_service.dart';

/// Provider for managing premium features and donation-based unlock system
class PremiumProvider extends ChangeNotifier {
  PremiumProvider({
    dynamic premiumService,
    dynamic deviceService,
    dynamic storageService,
  })  : _premiumService = premiumService ?? premium_service.PremiumService(),
        _deviceService = deviceService ?? DeviceService(),
        _storageService = storageService ?? StorageService() {
    _initialize();
  }

  final dynamic _premiumService;
  final dynamic _deviceService;
  final dynamic _storageService;

  // State variables
  PremiumStatus _premiumStatus = PremiumStatus.free('');
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isSubmittingProof = false;
  bool _isValidatingCode = false;
  AppError? _lastError;
  
  // Donation proof submission state
  List<DonationProof> _submittedProofs = [];
  String? _pendingProofId;

  // Getters
  bool get isPremium => _premiumStatus.isActive;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isSubmittingProof => _isSubmittingProof;
  bool get isValidatingCode => _isValidatingCode;
  String get deviceCode => _premiumStatus.deviceCode;
  PremiumStatus get premiumStatus => _premiumStatus;
  List<DonationProof> get submittedProofs => List.unmodifiable(_submittedProofs);
  String? get pendingProofId => _pendingProofId;
  AppError? get lastError => _lastError;
  
  // Premium feature access
  List<PremiumFeature> get unlockedFeatures => _premiumStatus.unlockedFeatures;
  DateTime? get unlockedAt => _premiumStatus.unlockedAt;
  DateTime? get expiresAt => _premiumStatus.expiresAt;
  int? get daysRemaining => _premiumStatus.daysRemaining;

  /// Initialize the premium provider
  Future<void> _initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Generate or load device code
      await _loadOrGenerateDeviceCode();
      
      // Load premium status
      await _loadPremiumStatus();
      
      // Load submitted proofs
      await _loadSubmittedProofs();
      
      _isInitialized = true;
      _lastError = null;
    } catch (e, stackTrace) {
      _lastError = e is AppError ? e : PremiumError.donationProofFailed(e.toString());
      debugPrint('Failed to initialize PremiumProvider: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load or generate device code
  Future<void> _loadOrGenerateDeviceCode() async {
    try {
      String? deviceCode = await _storageService.getString('device_code', encrypted: false);
      
      if (deviceCode == null) {
        deviceCode = await _deviceService.generateUniqueCode();
        await _storageService.saveString('device_code', deviceCode, encrypted: false);
      }
      
      _premiumStatus = _premiumStatus.copyWith(deviceCode: deviceCode);
    } catch (e) {
      throw DeviceError.codeGenerationFailed();
    }
  }

  /// Load premium status from storage
  Future<void> _loadPremiumStatus() async {
    try {
      final statusJson = await _storageService.getJson('premium_status');
      if (statusJson != null) {
        _premiumStatus = PremiumStatus.fromJson(statusJson);
      } else {
        // Create free status with device code
        _premiumStatus = PremiumStatus.free(_premiumStatus.deviceCode);
      }
    } catch (e) {
      throw StorageError.readFailed('Failed to load premium status: $e');
    }
  }

  /// Save premium status to storage
  Future<void> _savePremiumStatus() async {
    try {
      await _storageService.saveJson('premium_status', _premiumStatus.toJson());
    } catch (e) {
      throw StorageError.writeFailed('Failed to save premium status: $e');
    }
  }

  /// Load submitted donation proofs
  Future<void> _loadSubmittedProofs() async {
    try {
      final proofsJson = await _storageService.getJson('donation_proofs_list');
      if (proofsJson != null && proofsJson is Map<String, dynamic> && proofsJson.containsKey('proofs')) {
        final proofsList = proofsJson['proofs'] as List<dynamic>;
        _submittedProofs = proofsList
            .map((json) => DonationProof.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Sort by submission date (newest first)
        _submittedProofs.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      }
    } catch (e) {
      debugPrint('Failed to load donation proofs: $e');
      // Don't throw error, just log it
    }
  }

  /// Save submitted donation proofs
  Future<void> _saveSubmittedProofs() async {
    try {
      final proofsJson = _submittedProofs.map((proof) => proof.toJson()).toList();
      await _storageService.saveJson('donation_proofs_list', {'proofs': proofsJson});
    } catch (e) {
      throw StorageError.writeFailed('Failed to save donation proofs: $e');
    }
  }

  /// Check if a specific feature is unlocked
  bool isFeatureUnlocked(PremiumFeature feature) {
    return _premiumStatus.isFeatureUnlocked(feature);
  }

  /// Get feature gate widget
  Widget buildFeatureGate({
    required PremiumFeature feature,
    required Widget child,
    required Widget lockedWidget,
  }) {
    if (isFeatureUnlocked(feature)) {
      return child;
    }
    return lockedWidget;
  }

  /// Submit donation proof with image
  Future<bool> submitDonationProof({
    required File imageFile,
    double? amount,
    String? transactionId,
    String? notes,
  }) async {
    if (_isSubmittingProof) return false;

    _isSubmittingProof = true;
    _lastError = null;
    notifyListeners();

    try {
      // Validate image file
      if (!await imageFile.exists()) {
        throw ValidationError.invalidInput('imageFile', 'Image file does not exist');
      }

      // Create donation proof record
      final proof = DonationProof.create(
        deviceCode: _premiumStatus.deviceCode,
        imagePath: imageFile.path,
        amount: amount,
        transactionId: transactionId,
        notes: notes,
      );

      // Add to submitted proofs
      _submittedProofs.insert(0, proof);
      _pendingProofId = proof.id;

      // Save to storage
      await _saveSubmittedProofs();

      // Submit via email using the premium service
      final success = await _premiumService.submitDonationProof(
        additionalMessage: notes,
      );

      if (!success) {
        // Remove from submitted proofs if submission failed
        _submittedProofs.removeWhere((p) => p.id == proof.id);
        _pendingProofId = null;
        await _saveSubmittedProofs();
        throw PremiumError.donationProofFailed('Failed to send email');
      }

      _lastError = null;
      return true;
    } catch (e, stackTrace) {
      _lastError = e is AppError ? e : PremiumError.donationProofFailed(e.toString());
      debugPrint('Failed to submit donation proof: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    } finally {
      _isSubmittingProof = false;
      notifyListeners();
    }
  }

  /// Validate and activate unlock code
  Future<bool> unlockWithCode(String unlockCode) async {
    if (_isValidatingCode) return false;

    _isValidatingCode = true;
    _lastError = null;
    notifyListeners();

    try {
      if (unlockCode.trim().isEmpty) {
        throw ValidationError.requiredField('unlockCode');
      }

      // Validate unlock code with premium service
      final isValid = await _premiumService.validateUnlockCode(unlockCode.trim().toUpperCase());

      if (!isValid) {
        throw PremiumError.invalidUnlockCode();
      }

      // Update premium status
      _premiumStatus = PremiumStatus.premium(
        deviceCode: _premiumStatus.deviceCode,
        unlockCode: unlockCode.trim().toUpperCase(),
        features: PremiumFeature.values, // All features unlocked
      );

      // Save updated status
      await _savePremiumStatus();

      // Clear pending proof if any
      _pendingProofId = null;

      _lastError = null;
      return true;
    } catch (e, stackTrace) {
      _lastError = e is AppError ? e : PremiumError.invalidUnlockCode();
      debugPrint('Failed to unlock with code: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    } finally {
      _isValidatingCode = false;
      notifyListeners();
    }
  }

  /// Generate new device code (for testing or reset)
  Future<void> regenerateDeviceCode() async {
    try {
      final newDeviceCode = await _deviceService.generateUniqueCode();
      
      // Update premium status with new device code
      _premiumStatus = PremiumStatus.free(newDeviceCode);
      
      // Save new device code and reset premium status
      await _storageService.saveString('device_code', newDeviceCode, encrypted: false);
      await _savePremiumStatus();
      
      // Clear submitted proofs as they're tied to the old device code
      _submittedProofs.clear();
      _pendingProofId = null;
      await _saveSubmittedProofs();
      
      _lastError = null;
      notifyListeners();
    } catch (e, stackTrace) {
      _lastError = DeviceError.codeGenerationFailed();
      debugPrint('Failed to regenerate device code: $e');
      debugPrint('Stack trace: $stackTrace');
      notifyListeners();
    }
  }

  /// Reset premium status (for testing)
  Future<void> resetPremiumStatus() async {
    try {
      _premiumStatus = PremiumStatus.free(_premiumStatus.deviceCode);
      _submittedProofs.clear();
      _pendingProofId = null;
      
      await _savePremiumStatus();
      await _saveSubmittedProofs();
      
      _lastError = null;
      notifyListeners();
    } catch (e, stackTrace) {
      _lastError = StorageError.writeFailed('Failed to reset premium status');
      debugPrint('Failed to reset premium status: $e');
      debugPrint('Stack trace: $stackTrace');
      notifyListeners();
    }
  }

  /// Open donation instructions (bKash details)
  Future<void> openDonationInstructions() async {
    try {
      // This would open a screen or dialog with bKash donation details
      // For now, we'll just clear any errors
      _lastError = null;
      notifyListeners();
    } catch (e) {
      _lastError = PremiumError.donationProofFailed('Failed to open donation instructions');
      notifyListeners();
    }
  }

  /// Get premium feature description
  String getFeatureDescription(PremiumFeature feature) {
    return PremiumFeatures.featureDescriptions[feature] ?? 'Premium feature';
  }

  /// Get premium feature name
  String getFeatureName(PremiumFeature feature) {
    return PremiumFeatures.featureNames[feature] ?? feature.name;
  }

  /// Check if premium is about to expire
  bool get isAboutToExpire {
    if (!isPremium || expiresAt == null) return false;
    final daysLeft = daysRemaining ?? 0;
    return daysLeft <= 7 && daysLeft > 0;
  }

  /// Check if premium has expired
  bool get hasExpired {
    if (!_premiumStatus.isPremium || expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Get premium status summary
  String get statusSummary {
    if (!isPremium) {
      return 'Free Version';
    }
    
    if (expiresAt == null) {
      return 'Premium (Lifetime)';
    }
    
    final days = daysRemaining ?? 0;
    if (days <= 0) {
      return 'Premium (Expired)';
    } else if (days == 1) {
      return 'Premium (1 day remaining)';
    } else {
      return 'Premium ($days days remaining)';
    }
  }

  /// Clear error
  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  /// Force refresh premium status
  Future<void> refresh() async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      await _loadPremiumStatus();
      await _loadSubmittedProofs();
      _lastError = null;
    } catch (e, stackTrace) {
      _lastError = StorageError.readFailed('Failed to refresh premium status');
      debugPrint('Failed to refresh premium status: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Show premium flow (navigate to donation info screen)
  void showPremiumFlow(BuildContext context) {
    Navigator.of(context).pushNamed('/donation-info');
  }

  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
}