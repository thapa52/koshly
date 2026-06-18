import 'package:hive_flutter/hive_flutter.dart';
import 'package:koshly/core/constants/app_constants.dart';
import 'package:koshly/features/transactions/domain/entities/category.dart';
import 'package:koshly/features/transactions/domain/entities/transaction.dart';
import 'package:koshly/features/transactions/domain/entities/transaction_type.dart';

part 'transaction_model.g.dart';

/// Hive model for [Transaction] entity.
///
/// This class is used exclusively by the data layer.
/// It is never exposed to the domain or presentation layers.
///
/// Note: We store [categoryId] instead of the full category object.
/// The full category is looked up from the category box when
/// converting to entity via [toEntity].
@HiveType(typeId: AppConstants.transactionTypeId)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  /// Stored as int: 0 = income, 1 = expense
  @HiveField(3)
  final int typeIndex;

  /// Reference to the category by ID (like a foreign key)
  @HiveField(4)
  final String categoryId;

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final String? note;

  @HiveField(7)
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.typeIndex,
    required this.categoryId,
    required this.date,
    this.note,
    required this.createdAt,
  });

  /// Converts this Hive model to a domain entity.
  ///
  /// Requires the [category] object because we only store
  /// the category ID in the database.
  ///
  /// This is called when reading data FROM the database.
  Transaction toEntity(Category category) {
    return Transaction(
      id: id,
      title: title,
      amount: amount,
      type: TransactionType.values[typeIndex],
      category: category,
      date: date,
      note: note,
      createdAt: createdAt,
    );
  }

  /// Creates a Hive model from a domain entity.
  ///
  /// Only stores the category ID, not the full category object.
  ///
  /// This is called when writing data TO the database.
  factory TransactionModel.fromEntity(Transaction entity) {
    return TransactionModel(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      typeIndex: entity.type.index,
      categoryId: entity.category.id,
      date: entity.date,
      note: entity.note,
      createdAt: entity.createdAt,
    );
  }
}
