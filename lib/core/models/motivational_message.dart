import 'package:equatable/equatable.dart';

/// Model representing a motivational message for hydration
class MotivationalMessage extends Equatable {
  const MotivationalMessage({
    required this.id,
    required this.message,
    required this.category,
    this.isPersonalized = false,
  });

  /// Unique identifier for the message
  final String id;

  /// The motivational message text
  final String message;

  /// Category of the message
  final MessageCategory category;

  /// Whether this message is personalized for the user
  final bool isPersonalized;

  @override
  List<Object?> get props => [id, message, category, isPersonalized];

  @override
  String toString() => 'MotivationalMessage(id: $id, message: $message)';
}

/// Categories of motivational messages
enum MessageCategory {
  general,
  progress,
  achievement,
  reminder,
  health,
  encouragement,
}
