import 'package:isar/isar.dart';

part 'sale_model.g.dart';

@collection
class SaleModel {
  Id isarId = Isar.autoIncrement;
  String id;
  String productName;
  double price;
  DateTime date;
  String? observation;
  String? clientName;

  SaleModel({
    required this.id,
    required this.productName,
    required this.price,
    required this.date,
    this.observation,
    this.clientName,
  });
}
