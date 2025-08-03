import 'dart:math';
import 'package:watertracker/core/models/motivational_message.dart';
import 'package:watertracker/core/models/hydration_progress.dart';

/// Service for managing motivational content and messages
class MotivationalContentService {
  MotivationalContentService._();

  static final MotivationalContentService _instance =
      MotivationalContentService._();
  static MotivationalContentService get instance => _instance;

  final Random _random = Random();
  int _lastMessageIndex = -1;

  /// Database of motivational messages
  static const List<MotivationalMessage> _messages = [
    // General motivation
    MotivationalMessage(
      id: 'general_1',
      message: 'Every sip counts! 💧',
      category: MessageCategory.general,
    ),
    MotivationalMessage(
      id: 'general_2',
      message: 'Stay hydrated, stay healthy! 🌟',
      category: MessageCategory.general,
    ),
    MotivationalMessage(
      id: 'general_3',
      message: 'Water is life! Keep going! 💪',
      category: MessageCategory.general,
    ),
    MotivationalMessage(
      id: 'general_4',
      message: 'Your body will thank you! 🙏',
      category: MessageCategory.general,
    ),
    MotivationalMessage(
      id: 'general_5',
      message: 'Hydration is self-care! ✨',
      category: MessageCategory.general,
    ),

    // Progress-based motivation
    MotivationalMessage(
      id: 'progress_1',
      message: 'Great progress! Keep it up! 🚀',
      category: MessageCategory.progress,
    ),
    MotivationalMessage(
      id: 'progress_2',
      message: 'You\'re doing amazing! 🌈',
      category: MessageCategory.progress,
    ),
    MotivationalMessage(
      id: 'progress_3',
      message: 'Halfway there! Don\'t stop now! 🎯',
      category: MessageCategory.progress,
    ),
    MotivationalMessage(
      id: 'progress_4',
      message: 'Almost at your goal! 🏆',
      category: MessageCategory.progress,
    ),

    // Achievement messages
    MotivationalMessage(
      id: 'achievement_1',
      message: 'Goal achieved! You\'re a hydration hero! 🏅',
      category: MessageCategory.achievement,
    ),
    MotivationalMessage(
      id: 'achievement_2',
      message: 'Fantastic! You did it! 🎉',
      category: MessageCategory.achievement,
    ),
    MotivationalMessage(
      id: 'achievement_3',
      message: 'Mission accomplished! 🌟',
      category: MessageCategory.achievement,
    ),

    // Health-focused messages
    MotivationalMessage(
      id: 'health_1',
      message: 'Boost your energy with water! ⚡',
      category: MessageCategory.health,
    ),
    MotivationalMessage(
      id: 'health_2',
      message: 'Clear skin starts with hydration! ✨',
      category: MessageCategory.health,
    ),
    MotivationalMessage(
      id: 'health_3',
      message: 'Better focus through hydration! 🧠',
      category: MessageCategory.health,
    ),
    MotivationalMessage(
      id: 'health_4',
      message: 'Flush out toxins naturally! 🌿',
      category: MessageCategory.health,
    ),

    // Encouragement messages
    MotivationalMessage(
      id: 'encouragement_1',
      message: 'Small steps, big results! 👣',
      category: MessageCategory.encouragement,
    ),
    MotivationalMessage(
      id: 'encouragement_2',
      message: 'You\'ve got this! 💪',
      category: MessageCategory.encouragement,
    ),
    MotivationalMessage(
      id: 'encouragement_3',
      message: 'One glass at a time! 🥤',
      category: MessageCategory.encouragement,
    ),
    MotivationalMessage(
      id: 'encouragement_4',
      message: 'Building healthy habits! 🌱',
      category: MessageCategory.encouragement,
    ),

    // Reminder messages
    MotivationalMessage(
      id: 'reminder_1',
      message: 'Time for a water break! ⏰',
      category: MessageCategory.reminder,
    ),
    MotivationalMessage(
      id: 'reminder_2',
      message: 'Don\'t forget to hydrate! 💧',
      category: MessageCategory.reminder,
    ),
    MotivationalMessage(
      id: 'reminder_3',
      message: 'Your body needs water now! 🚰',
      category: MessageCategory.reminder,
    ),
  ];

  /// Get a random motivational message based on progress
  MotivationalMessage getMotivationalMessage(HydrationProgress progress) {
    final category = _getCategoryForProgress(progress);
    final categoryMessages =
        _messages.where((m) => m.category == category).toList();

    if (categoryMessages.isEmpty) {
      return _getRandomMessage();
    }

    // Avoid repeating the same message
    int newIndex;
    do {
      newIndex = _random.nextInt(categoryMessages.length);
    } while (newIndex == _lastMessageIndex && categoryMessages.length > 1);

    _lastMessageIndex = newIndex;
    return categoryMessages[newIndex];
  }

  /// Get a personalized message based on user progress
  MotivationalMessage getPersonalizedMessage(HydrationProgress progress) {
    final percentage = progress.percentage;
    final remainingMl = progress.remainingIntake;

    if (progress.isGoalReached) {
      return MotivationalMessage(
        id: 'personalized_achievement',
        message:
            'Amazing! You\'ve reached your ${(progress.dailyGoal / 1000).toStringAsFixed(1)}L goal! 🎉',
        category: MessageCategory.achievement,
        isPersonalized: true,
      );
    } else if (percentage >= 0.8) {
      return MotivationalMessage(
        id: 'personalized_almost_there',
        message: 'So close! Just ${remainingMl}ml to go! 🎯',
        category: MessageCategory.progress,
        isPersonalized: true,
      );
    } else if (percentage >= 0.5) {
      return MotivationalMessage(
        id: 'personalized_halfway',
        message:
            'Halfway there! ${(progress.currentIntake / 1000).toStringAsFixed(1)}L down! 💪',
        category: MessageCategory.progress,
        isPersonalized: true,
      );
    } else if (percentage >= 0.25) {
      return MotivationalMessage(
        id: 'personalized_good_start',
        message: 'Great start! Keep the momentum going! 🚀',
        category: MessageCategory.encouragement,
        isPersonalized: true,
      );
    } else {
      return MotivationalMessage(
        id: 'personalized_beginning',
        message: 'Every journey starts with a single sip! 🌟',
        category: MessageCategory.encouragement,
        isPersonalized: true,
      );
    }
  }

  /// Get messages by category
  List<MotivationalMessage> getMessagesByCategory(MessageCategory category) {
    return _messages.where((m) => m.category == category).toList();
  }

  /// Get all available messages
  List<MotivationalMessage> getAllMessages() {
    return List.unmodifiable(_messages);
  }

  /// Get a completely random message
  MotivationalMessage _getRandomMessage() {
    final index = _random.nextInt(_messages.length);
    return _messages[index];
  }

  /// Determine the appropriate message category based on progress
  MessageCategory _getCategoryForProgress(HydrationProgress progress) {
    final percentage = progress.percentage;

    if (progress.isGoalReached) {
      return MessageCategory.achievement;
    } else if (percentage >= 0.7) {
      return MessageCategory.progress;
    } else if (percentage >= 0.3) {
      return MessageCategory.encouragement;
    } else if (progress.nextReminderTime != null) {
      final now = DateTime.now();
      final timeDiff = progress.nextReminderTime!.difference(now).inMinutes;
      if (timeDiff <= 30) {
        return MessageCategory.reminder;
      }
    }

    return MessageCategory.general;
  }
}
