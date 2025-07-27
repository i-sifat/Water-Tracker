import 'package:watertracker/features/hydration/providers/hydration_provider.dart';

/// Extension methods for AvatarOption enum
extension AvatarOptionExtension on AvatarOption {
  String get displayName {
    switch (this) {
      case AvatarOption.male:
        return 'Male';
      case AvatarOption.female:
        return 'Female';
    }
  }

  String get assetPath {
    switch (this) {
      case AvatarOption.male:
        return 'assets/images/avatars/male.svg';
      case AvatarOption.female:
        return 'assets/images/avatars/female.svg';
    }
  }
}