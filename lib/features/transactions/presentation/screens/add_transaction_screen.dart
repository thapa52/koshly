import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_type.dart';
import '../providers/category_providers.dart';
import '../providers/transaction_providers.dart';
import '../widgets/category_chip.dart';

/// Screen for adding a new transaction.
///
/// Contains a form with:
/// - Type selector (Income/Expense)
/// - Title input
/// - Amount input
/// - Category selection
/// - Date picker
/// - Optional note
class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  // ─── Form Key ─────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  // ─── Controllers ──────────────────────────────────────────
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  // ─── Local State ──────────────────────────────────────────
  TransactionType _selectedType = TransactionType.expense;
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // ─── Type Selector ────────────────────────────────
            _buildTypeSelector(),
            const SizedBox(height: 24.0),

            // ─── Title Field ──────────────────────────────────
            _buildTitleField(),
            const SizedBox(height: 16.0),

            // ─── Amount Field ─────────────────────────────────
            _buildAmountField(),
            const SizedBox(height: 24.0),

            // ─── Category Selection ───────────────────────────
            _buildCategorySection(),
            const SizedBox(height: 24.0),

            // ─── Date Picker ──────────────────────────────────
            _buildDatePicker(context),
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

  /// Builds the Income/Expense type selector.
  Widget _buildTypeSelector() {
    return Row(
      children:
          TransactionType.values.map((type) {
            final isSelected = _selectedType == type;
            final color = type.isIncome ? AppColors.income : AppColors.expense;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedType = type;
                    _selectedCategory = null;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(
                    right: type.isIncome ? 6.0 : 0.0,
                    left: type.isExpense ? 6.0 : 0.0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? color.withValues(alpha: 0.15)
                            : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color:
                          isSelected ? color : Theme.of(context).dividerColor,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        type.isIncome
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color:
                            isSelected
                                ? color
                                : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.5),
                        size: 18.0,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        type.label,
                        style: AppTextStyles.labelLarge.copyWith(
                          color:
                              isSelected
                                  ? color
                                  : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  /// Builds the title input field.
  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Title',
        hintText: 'e.g., Grocery Shopping',
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
    );
  }

  /// Builds the amount input field.
  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: const InputDecoration(
        labelText: 'Amount',
        hintText: '0.00',
        prefixIcon: Icon(Icons.attach_money),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter an amount';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount greater than zero';
        }
        return null;
      },
    );
  }

  /// Builds the category selection section.
  Widget _buildCategorySection() {
    final categoriesProvider =
        _selectedType.isIncome
            ? incomeCategoriesProvider
            : expenseCategoriesProvider;

    final categoriesAsync = ref.watch(categoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: AppTextStyles.headlineSmall.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12.0),
        categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (e, st) => Text(
                'Failed to load categories',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.expense,
                ),
              ),
          data: (categories) {
            if (categories.isEmpty) {
              return Text(
                'No categories available',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              );
            }

            return Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children:
                  categories.map((category) {
                    return CategoryChip(
                      category: category,
                      isSelected: _selectedCategory == category,
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    );
                  }).toList(),
            );
          },
        ),
        if (_selectedCategory == null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Please select a category',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.expense.withValues(alpha: 0.8),
              ),
            ),
          ),
      ],
    );
  }

  /// Builds the date picker row.
  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
      borderRadius: BorderRadius.circular(12.0),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
          style: AppTextStyles.bodyLarge,
        ),
      ),
    );
  }

  /// Builds the optional note field.
  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Note (optional)',
        hintText: 'Add any additional details...',
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
        onPressed: _isSaving ? null : _saveTransaction,
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
                : const Text('Save Transaction'),
      ),
    );
  }

  /// Validates and saves the transaction.
  Future<void> _saveTransaction() async {
    // Validate form fields
    if (!_formKey.currentState!.validate()) return;

    // Validate category selection
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final transaction = Transaction(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        type: _selectedType,
        category: _selectedCategory!,
        date: _selectedDate,
        note:
            _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
        createdAt: DateTime.now(),
      );

      await ref
          .read(transactionNotifierProvider.notifier)
          .addTransaction(transaction);

      if (mounted) {
        Navigator.of(context).pop();
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
