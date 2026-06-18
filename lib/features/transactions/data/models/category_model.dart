import 'package:hive_flutter/hive_flutter.dart';
import 'package:koshly/core/constants/app_constants.dart';
import 'package:koshly/features/transactions/domain/entities/category.dart';
import 'package:koshly/features/transactions/domain/entities/transaction_type.dart';

part 'category_model.g.dart';

/// Hive model for [Category] entity.
///
/// This class is used exclusively by the data layer.
/// It is never exposed to the domain or presentation layers.
///
/// The [part] directive above tells Hive's code generator
/// to create a TypeAdapter in 'category_model.g.dart'.
@HiveType(typeId: AppConstants.categoryTypeId)
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int iconCode;

  @HiveField(3)
  final int colorValue;

  /// Stored as int: 0 = income, 1 = expense
  @HiveField(4)
  final int typeIndex;

  @HiveField(5)
  final bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    required this.typeIndex,
    this.isDefault = false,
  });

  /// Converts this Hive model to a domain entity.
  ///
  /// This is called when reading data FROM the database
  /// to pass it up to the domain/presentation layers.
  Category toEntity() {
    return Category(
      id: id,
      name: name,
      iconCode: iconCode,
      colorValue: colorValue,
      type: TransactionType.values[typeIndex],
      isDefault: isDefault,
    );
  }

  /// Creates a Hive model from a domain entity.
  ///
  /// This is called when writing data TO the database
  /// from the domain layer.
  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      iconCode: entity.iconCode,
      colorValue: entity.colorValue,
      typeIndex: entity.type.index,
      isDefault: entity.isDefault,
    );
  }
}
