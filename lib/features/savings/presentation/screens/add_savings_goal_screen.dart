import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/savings_goal.dart';
import '../providers/savings_providers.dart';

/// Screen for creating a new savings goal.
///
/// Contains a form with:
/// - Title input
/// - Target amount
/// - Initial savings (optional)
/// - Icon selection
/// - Color selection
/// - Deadline picker (optional)
/// - Note (optional)
class AddSavingsGoalScreen extends ConsumerStatefulWidget {
  const AddSavingsGoalScreen({super.key});

  @override
  ConsumerState<AddSavingsGoalScreen> createState() =>
      _AddSavingsGoalScreenState();
}

class _AddSavingsGoalScreenState extends ConsumerState<AddSavingsGoalScreen> {
  // ─── Form Key ─────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  // ─── Controllers ──────────────────────────────────────────
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController();
  final _noteController = TextEditingController();

  // ─── Local State ──────────────────────────────────────────
  int _selectedIconIndex = 0;
  int _selectedColorIndex = 0;
  DateTime? _selectedDeadline;
  bool _isSaving = false;

  // ─── Available Icons ──────────────────────────────────────
  static const List<IconData> _goalIcons = [
    Icons.savings,
    Icons.home,
    Icons.flight,
    Icons.directions_car,
    Icons.school,
    Icons.laptop_mac,
    Icons.phone_iphone,
    Icons.checkroom,
    Icons.celebration,
    Icons.medical_services,
    Icons.shield,
    Icons.spa,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Savings Goal')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // ─── Title Field ──────────────────────────────────
            _buildTitleField(),
            const SizedBox(height: 16.0),

            // ─── Target Amount Field ──────────────────────────
            _buildTargetAmountField(),
            const SizedBox(height: 16.0),

            // ─── Initial Amount Field ─────────────────────────
            _buildInitialAmountField(),
            const SizedBox(height: 24.0),

            // ─── Icon Selection ───────────────────────────────
            _buildIconSelection(),
            const SizedBox(height: 24.0),

            // ─── Color Selection ──────────────────────────────
            _buildColorSelection(),
            const SizedBox(height: 24.0),

            // ─── Deadline Picker ──────────────────────────────
            _buildDeadlinePicker(context),
            const SizedBox(height: 16.0),

            // ─── Note Field ───────────────────────────────────
            _buildNoteField(),
            const SizedBox(height: 32.0),

            // ─── Save Button ──────────────────────────────────
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  /// Builds the title input field.
  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Goal Title',
        hintText: 'e.g., Emergency Fund',
        prefixIcon: Icon(Icons.flag),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a goal title';
        }
        return null;
      },
    );
  }

  /// Builds the target amount field.
  Widget _buildTargetAmountField() {
    return TextFormField(
      controller: _targetController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: const InputDecoration(
        labelText: 'Target Amount',
        hintText: '10000.00',
        prefixIcon: Icon(Icons.track_changes),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a target amount';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount greater than zero';
        }
        return null;
      },
    );
  }

  /// Builds the initial savings amount field.
  Widget _buildInitialAmountField() {
    return TextFormField(
      controller: _currentController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: const InputDecoration(
        labelText: 'Already Saved (optional)',
        hintText: '0.00',
        prefixIcon: Icon(Icons.account_balance_wallet),
      ),
    );
  }

  /// Builds the icon selection grid.
  Widget _buildIconSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Icon',
          style: AppTextStyles.headlineSmall.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12.0),
        Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          children:
              _goalIcons.asMap().entries.map((entry) {
                final index = entry.key;
                final icon = entry.value;
                final isSelected = _selectedIconIndex == index;
                final selectedColor =
                    AppColors.categoryColors[_selectedColorIndex];

                return GestureDetector(
                  onTap: () => setState(() => _selectedIconIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48.0,
                    height: 48.0,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? selectedColor.withValues(alpha: 0.15)
                              : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color:
                            isSelected
                                ? selectedColor
                                : Theme.of(context).dividerColor,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color:
                          isSelected
                              ? selectedColor
                              : Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.5),
                      size: 22.0,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  /// Builds the color selection row.
  Widget _buildColorSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Color',
          style: AppTextStyles.headlineSmall.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12.0),
        Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          children:
              AppColors.categoryColors.asMap().entries.map((entry) {
                final index = entry.key;
                final color = entry.value;
                final isSelected = _selectedColorIndex == index;

                return GestureDetector(
                  onTap: () => setState(() => _selectedColorIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.onSurface
                                : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child:
                        isSelected
                            ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18.0,
                            )
                            : null,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  /// Builds the deadline picker.
  Widget _buildDeadlinePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 30)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 3650)),
        );
        if (picked != null) {
          setState(() => _selectedDeadline = picked);
        }
      },
      borderRadius: BorderRadius.circular(12.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Deadline (optional)',
          prefixIcon: const Icon(Icons.calendar_today),
          suffixIcon:
              _selectedDeadline != null
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _selectedDeadline = null),
                  )
                  : null,
        ),
        child: Text(
          _selectedDeadline != null
              ? DateFormatter.formatDate(_selectedDeadline!)
              : 'No deadline set',
          style: AppTextStyles.bodyLarge.copyWith(
            color:
                _selectedDeadline != null
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  /// Builds the note field.
  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Note (optional)',
        hintText: 'Why is this goal important to you?',
        prefixIcon: Icon(Icons.notes),
        alignLabelWithHint: true,
      ),
    );
  }

  /// Builds the save button.
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52.0,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveGoal,
        child:
            _isSaving
                ? const SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                : const Text('Create Goal'),
      ),
    );
  }

  /// Validates and saves the goal.
  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final currentAmount =
          _currentController.text.trim().isEmpty
              ? 0.0
              : double.parse(_currentController.text.trim());

      final selectedColor = AppColors.categoryColors[_selectedColorIndex];

      final goal = SavingsGoal(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        targetAmount: double.parse(_targetController.text.trim()),
        currentAmount: currentAmount,
        iconCode: _goalIcons[_selectedIconIndex].codePoint,
        colorValue: selectedColor.toARGB32(),
        deadline: _selectedDeadline,
        note:
            _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
        createdAt: DateTime.now(),
      );

      await ref.read(savingsNotifierProvider.notifier).addGoal(goal);

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
