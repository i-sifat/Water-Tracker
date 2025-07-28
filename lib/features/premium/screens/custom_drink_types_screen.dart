import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:watertracker/core/constants/premium_features.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/models/custom_drink_type.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/buttons/primary_button.dart';
import 'package:watertracker/core/widgets/cards/app_card.dart';
import 'package:watertracker/core/widgets/common/loading_widget.dart';
import 'package:watertracker/core/widgets/common/premium_gate.dart';
import 'package:watertracker/features/premium/providers/premium_provider.dart';

/// Screen for managing custom drink types (Premium feature)
class CustomDrinkTypesScreen extends StatefulWidget {
  const CustomDrinkTypesScreen({super.key});

  @override
  State<CustomDrinkTypesScreen> createState() => _CustomDrinkTypesScreenState();
}

class _CustomDrinkTypesScreenState extends State<CustomDrinkTypesScreen> {
  List<CustomDrinkType> _customDrinkTypes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomDrinkTypes();
  }

  Future<void> _loadCustomDrinkTypes() async {
    setState(() => _isLoading = true);
    
    try {
      // In a real implementation, this would load from storage service
      // For now, we'll use sample data
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _customDrinkTypes = [
          CustomDrinkType.create(
            name: 'Green Tea',
            waterPercentage: 0.98,
            icon: '🍵',
            description: 'Antioxidant-rich green tea',
          ),
          CustomDrinkType.create(
            name: 'Coconut Water',
            waterPercentage: 0.95,
            icon: '🥥',
            description: 'Natural electrolyte drink',
          ),
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading drink types: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Drink Types'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: PremiumGate(
        feature: PremiumFeature.customGoals,
        lockedChild: _buildLockedContent(),
        child: _buildContent(), // Using customGoals as proxy for custom drink types
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
          child: _customDrinkTypes.isEmpty
              ? _buildEmptyState()
              : _buildDrinkTypesList(),
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
            Icons.local_drink,
            size: 80,
            color: AppColors.waterFull.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'Custom Drink Types',
            style: AppTypography.headline,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Create your own drink types with custom water percentages. Track specialty beverages, herbal teas, or any liquid that contributes to your hydration.',
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
            Icons.local_drink_outlined,
            size: 80,
            color: AppColors.waterFull.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Custom Drink Types',
            style: AppTypography.headline,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Create your first custom drink type to track specialty beverages with accurate water content.',
            style: AppTypography.subtitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDrinkTypesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _customDrinkTypes.length,
      itemBuilder: (context, index) {
        final drinkType = _customDrinkTypes[index];
        return _buildDrinkTypeCard(drinkType);
      },
    );
  }

  Widget _buildDrinkTypeCard(CustomDrinkType drinkType) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: drinkType.isActive ? AppColors.waterFull : Colors.grey,
          child: Text(
            drinkType.icon ?? '🥤',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          drinkType.name,
          style: AppTypography.subtitle,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${(drinkType.waterPercentage * 100).toInt()}% water content',
              style: AppTypography.subtitle.copyWith(
                color: AppColors.waterFull,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (drinkType.description != null) ...[
              const SizedBox(height: 4),
              Text(
                drinkType.description!,
                style: AppTypography.subtitle,
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, drinkType),
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
            PopupMenuItem(
              value: drinkType.isActive ? 'deactivate' : 'activate',
              child: Row(
                children: [
                  Icon(drinkType.isActive ? Icons.visibility_off : Icons.visibility),
                  const SizedBox(width: 8),
                  Text(drinkType.isActive ? 'Deactivate' : 'Activate'),
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
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: PrimaryButton(
        text: 'Add Custom Drink Type',
        onPressed: _showAddDrinkTypeDialog,
        icon: Icons.add,
      ),
    );
  }

  void _handleMenuAction(String action, CustomDrinkType drinkType) {
    switch (action) {
      case 'edit':
        _showEditDrinkTypeDialog(drinkType);
      case 'activate':
      case 'deactivate':
        _toggleDrinkType(drinkType);
      case 'delete':
        _showDeleteConfirmation(drinkType);
    }
  }

  Future<void> _showAddDrinkTypeDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => _DrinkTypeDialog(
        onSave: _addDrinkType,
      ),
    );
  }

  Future<void> _showEditDrinkTypeDialog(CustomDrinkType drinkType) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _DrinkTypeDialog(
        drinkType: drinkType,
        onSave: (name, waterPercentage, icon, description) => _updateDrinkType(
          drinkType,
          name,
          waterPercentage,
          icon,
          description,
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(CustomDrinkType drinkType) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Drink Type'),
        content: Text('Are you sure you want to delete "${drinkType.name}"?'),
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
      await _deleteDrinkType(drinkType);
    }
  }

  Future<void> _addDrinkType(
    String name,
    double waterPercentage,
    String? icon,
    String? description,
  ) async {
    try {
      final newDrinkType = CustomDrinkType.create(
        name: name,
        waterPercentage: waterPercentage,
        icon: icon,
        description: description,
      );

      setState(() {
        _customDrinkTypes.add(newDrinkType);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Custom drink type added')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding drink type: $e')),
        );
      }
    }
  }

  Future<void> _updateDrinkType(
    CustomDrinkType drinkType,
    String name,
    double waterPercentage,
    String? icon,
    String? description,
  ) async {
    try {
      final updatedDrinkType = drinkType.copyWith(
        name: name,
        waterPercentage: waterPercentage,
        icon: icon,
        description: description,
      );

      setState(() {
        final index = _customDrinkTypes.indexWhere((dt) => dt.id == drinkType.id);
        if (index != -1) {
          _customDrinkTypes[index] = updatedDrinkType;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Drink type updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating drink type: $e')),
        );
      }
    }
  }

  Future<void> _toggleDrinkType(CustomDrinkType drinkType) async {
    try {
      final updatedDrinkType = drinkType.copyWith(isActive: !drinkType.isActive);

      setState(() {
        final index = _customDrinkTypes.indexWhere((dt) => dt.id == drinkType.id);
        if (index != -1) {
          _customDrinkTypes[index] = updatedDrinkType;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedDrinkType.isActive 
                  ? 'Drink type activated' 
                  : 'Drink type deactivated',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating drink type: $e')),
        );
      }
    }
  }

  Future<void> _deleteDrinkType(CustomDrinkType drinkType) async {
    try {
      setState(() {
        _customDrinkTypes.removeWhere((dt) => dt.id == drinkType.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Drink type deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting drink type: $e')),
        );
      }
    }
  }
}

/// Dialog for adding/editing custom drink types
class _DrinkTypeDialog extends StatefulWidget {
  const _DrinkTypeDialog({
    required this.onSave, this.drinkType,
  });

  final CustomDrinkType? drinkType;
  final Function(String name, double waterPercentage, String? icon, String? description) onSave;

  @override
  State<_DrinkTypeDialog> createState() => _DrinkTypeDialogState();
}

class _DrinkTypeDialogState extends State<_DrinkTypeDialog> {
  late TextEditingController _nameController;
  late TextEditingController _iconController;
  late TextEditingController _descriptionController;
  late TextEditingController _percentageController;

  @override
  void initState() {
    super.initState();
    
    if (widget.drinkType != null) {
      final drinkType = widget.drinkType!;
      _nameController = TextEditingController(text: drinkType.name);
      _iconController = TextEditingController(text: drinkType.icon ?? '');
      _descriptionController = TextEditingController(text: drinkType.description ?? '');
      _percentageController = TextEditingController(
        text: (drinkType.waterPercentage * 100).toInt().toString(),
      );
    } else {
      _nameController = TextEditingController();
      _iconController = TextEditingController();
      _descriptionController = TextEditingController();
      _percentageController = TextEditingController(text: '90');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _descriptionController.dispose();
    _percentageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.drinkType != null ? 'Edit Drink Type' : 'Add Drink Type'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameField(),
            const SizedBox(height: 16),
            _buildIconField(),
            const SizedBox(height: 16),
            _buildPercentageField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
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
          onPressed: _saveDrinkType,
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Name *', style: AppTypography.subtitle),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'e.g., Green Tea, Coconut Water',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildIconField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Icon (Emoji)', style: AppTypography.subtitle),
        const SizedBox(height: 8),
        TextField(
          controller: _iconController,
          decoration: const InputDecoration(
            hintText: '🍵 🥥 🧃',
            border: OutlineInputBorder(),
          ),
          maxLength: 2,
        ),
      ],
    );
  }

  Widget _buildPercentageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Water Content % *', style: AppTypography.subtitle),
        const SizedBox(height: 8),
        TextField(
          controller: _percentageController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            FilteringTextInputFormatter.allow(RegExp(r'^[1-9][0-9]?$|^100$')),
          ],
          decoration: const InputDecoration(
            hintText: '90',
            suffixText: '%',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter the percentage of water content (1-100%)',
          style: AppTypography.subtitle.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description', style: AppTypography.subtitle),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Optional description',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  void _saveDrinkType() {
    final name = _nameController.text.trim();
    final percentageText = _percentageController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    if (percentageText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter water content percentage')),
      );
      return;
    }

    final percentage = int.tryParse(percentageText);
    if (percentage == null || percentage < 1 || percentage > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid percentage (1-100)')),
      );
      return;
    }

    widget.onSave(
      name,
      percentage / 100.0,
      _iconController.text.trim().isEmpty ? null : _iconController.text.trim(),
      _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
    );

    Navigator.of(context).pop();
  }
}
