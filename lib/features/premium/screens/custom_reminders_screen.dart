import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:watertracker/core/constants/premium_features.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/services/notification_service.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/buttons/primary_button.dart';
import 'package:watertracker/core/widgets/cards/app_card.dart';
import 'package:watertracker/core/widgets/common/loading_widget.dart';
import 'package:watertracker/core/widgets/common/premium_gate.dart';
import 'package:watertracker/features/premium/providers/premium_provider.dart';

/// Screen for managing custom reminder schedules (Premium feature)
class CustomRemindersScreen extends StatefulWidget {
  const CustomRemindersScreen({super.key});

  @override
  State<CustomRemindersScreen> createState() => _CustomRemindersScreenState();
}

class _CustomRemindersScreenState extends State<CustomRemindersScreen> {
  final NotificationService _notificationService = NotificationService();
  List<Map<String, dynamic>> _customReminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomReminders();
  }

  Future<void> _loadCustomReminders() async {
    setState(() => _isLoading = true);
    
    try {
      final reminders = await _notificationService.getCustomReminders();
      setState(() {
        _customReminders = reminders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reminders: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Reminders'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: PremiumGate(
        feature: PremiumFeature.customReminders,
        child: _buildContent(),
        lockedChild: _buildLockedContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }

    return Column(
      children: [
        Expanded(
          child: _customReminders.isEmpty
              ? _buildEmptyState()
              : _buildRemindersList(),
        ),
        _buildAddButton(),
      ],
    );
  }

  Widget _buildLockedContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule,
            size: 80,
            color: AppColors.waterFull.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Custom Reminders',
            style: AppTypography.headline,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Create personalized reminder schedules that fit your lifestyle. Set specific times, custom messages, and choose which days to receive reminders.',
            style: AppTypography.subtitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Unlock Premium',
            onPressed: () => context.read<PremiumProvider>().showPremiumFlow(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 80,
            color: AppColors.waterFull.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No Custom Reminders',
            style: AppTypography.headline,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Create your first custom reminder to get personalized hydration notifications.',
            style: AppTypography.subtitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _customReminders.length,
      itemBuilder: (context, index) {
        final reminder = _customReminders[index];
        return _buildReminderCard(reminder);
      },
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> reminder) {
    final hour = (reminder['hour'] is int) ? reminder['hour'] as int : 0;
    final minute = (reminder['minute'] is int) ? reminder['minute'] as int : 0;
    final title = reminder['title'] as String;
    final enabled = reminder['enabled'] as bool;
    final days = (reminder['days'] as List<dynamic>).cast<int>();

    final timeString = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    final dayNames = _getDayNames(days);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: enabled ? AppColors.waterFull : Colors.grey,
          child: const Icon(
            Icons.schedule,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: AppTypography.subtitle,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              timeString,
              style: AppTypography.subtitle.copyWith(
                color: AppColors.waterFull,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayNames,
              style: AppTypography.subtitle,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: enabled,
              onChanged: (value) => _toggleReminder(reminder['id'] as int, value),
              activeColor: AppColors.waterFull,
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value, reminder),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: PrimaryButton(
        text: 'Add Custom Reminder',
        onPressed: _showAddReminderDialog,
        icon: Icons.add,
      ),
    );
  }

  String _getDayNames(List<int> days) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    if (days.length == 7) return 'Every day';
    if (days.length == 5 && !days.contains(6) && !days.contains(7)) {
      return 'Weekdays';
    }
    if (days.length == 2 && days.contains(6) && days.contains(7)) {
      return 'Weekends';
    }
    
    return days.map((day) => dayNames[day - 1]).join(', ');
  }

  Future<void> _toggleReminder(int id, bool enabled) async {
    try {
      final success = await _notificationService.updateCustomReminder(
        id: id,
        enabled: enabled,
      );
      
      if (success) {
        await _loadCustomReminders();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(enabled ? 'Reminder enabled' : 'Reminder disabled'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating reminder: $e')),
        );
      }
    }
  }

  void _handleMenuAction(String action, Map<String, dynamic> reminder) {
    switch (action) {
      case 'edit':
        _showEditReminderDialog(reminder);
      case 'delete':
        _showDeleteConfirmation(reminder);
    }
  }

  Future<void> _showAddReminderDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => _ReminderDialog(
        onSave: _addReminder,
      ),
    );
  }

  Future<void> _showEditReminderDialog(Map<String, dynamic> reminder) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _ReminderDialog(
        reminder: reminder,
        onSave: (hour, minute, title, body, days) => _updateReminder(
          reminder['id'] as int,
          hour,
          minute,
          title,
          body,
          days,
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(Map<String, dynamic> reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete "${reminder['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteReminder(reminder['id'] as int);
    }
  }

  Future<void> _addReminder(
    int hour,
    int minute,
    String title,
    String body,
    List<int> days,
  ) async {
    try {
      final success = await _notificationService.addCustomReminder(
        hour: hour,
        minute: minute,
        title: title,
        body: body,
        days: days,
      );

      if (success) {
        await _loadCustomReminders();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Custom reminder added')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding reminder: $e')),
        );
      }
    }
  }

  Future<void> _updateReminder(
    int id,
    int hour,
    int minute,
    String title,
    String body,
    List<int> days,
  ) async {
    try {
      final success = await _notificationService.updateCustomReminder(
        id: id,
        hour: hour,
        minute: minute,
        title: title,
        body: body,
        days: days,
      );

      if (success) {
        await _loadCustomReminders();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reminder updated')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating reminder: $e')),
        );
      }
    }
  }

  Future<void> _deleteReminder(int id) async {
    try {
      final success = await _notificationService.deleteCustomReminder(id);

      if (success) {
        await _loadCustomReminders();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reminder deleted')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting reminder: $e')),
        );
      }
    }
  }
}

/// Dialog for adding/editing custom reminders
class _ReminderDialog extends StatefulWidget {
  const _ReminderDialog({
    required this.onSave, this.reminder,
  });

  final Map<String, dynamic>? reminder;
  final Function(int hour, int minute, String title, String body, List<int> days) onSave;

  @override
  State<_ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<_ReminderDialog> {
  late TimeOfDay _selectedTime;
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late Set<int> _selectedDays;

  final List<String> _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    
    if (widget.reminder != null) {
      final reminder = widget.reminder!;
      _selectedTime = TimeOfDay(
        hour: (reminder['hour'] is int) ? reminder['hour'] as int : 9,
        minute: (reminder['minute'] is int) ? reminder['minute'] as int : 0,
      );
      _titleController = TextEditingController(text: reminder['title'] as String);
      _bodyController = TextEditingController(text: reminder['body'] as String? ?? '');
      _selectedDays = Set<int>.from(reminder['days'] as List<dynamic>);
    } else {
      _selectedTime = const TimeOfDay(hour: 9, minute: 0);
      _titleController = TextEditingController(text: 'Time to Hydrate!');
      _bodyController = TextEditingController(text: 'Remember to drink water and stay healthy.');
      _selectedDays = {1, 2, 3, 4, 5, 6, 7}; // All days
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.reminder != null ? 'Edit Reminder' : 'Add Reminder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimeSelector(),
            const SizedBox(height: 16),
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildBodyField(),
            const SizedBox(height: 16),
            _buildDaySelector(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        PrimaryButton(
          text: 'Save',
          onPressed: _saveReminder,
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Time', style: AppTypography.subtitle),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 12),
                Text(
                  _selectedTime.format(context),
                  style: AppTypography.subtitle,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Title', style: AppTypography.subtitle),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'Enter reminder title',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildBodyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Message', style: AppTypography.subtitle),
        const SizedBox(height: 8),
        TextField(
          controller: _bodyController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter reminder message',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Days', style: AppTypography.subtitle),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(7, (index) {
            final dayNumber = index + 1;
            final isSelected = _selectedDays.contains(dayNumber);
            
            return FilterChip(
              label: Text(_dayNames[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDays.add(dayNumber);
                  } else {
                    _selectedDays.remove(dayNumber);
                  }
                });
              },
              selectedColor: AppColors.waterFull.withOpacity(0.2),
              checkmarkColor: AppColors.waterFull,
            );
          }),
        ),
      ],
    );
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _saveReminder() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day')),
      );
      return;
    }

    widget.onSave(
      _selectedTime.hour,
      _selectedTime.minute,
      _titleController.text.trim(),
      _bodyController.text.trim(),
      _selectedDays.toList()..sort(),
    );

    Navigator.of(context).pop();
  }
}