import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sales_management/core/core.dart';

class IsarDB {
  IsarDB._privateConstructor();
  static final IsarDB _instance = IsarDB._privateConstructor();
  static IsarDB get instance => _instance;

  late Isar isarInstance;

  Future<void> init() async {
    final dir = await getApplicationSupportDirectory();

    isarInstance = await Isar.open(
      [
        SaleModelSchema,
      ],
      directory: dir.path,
      inspector: true,
    );
  }

  Future<void> truncateDatabase() async {
    return await isarInstance.writeTxn(() async {
      await isarInstance.clear();
    });
  }

  // Sales CRUD

  Future<int?> createSale({required SaleModel saleModel}) async {
    int? id;

    await isarInstance.writeTxn(() async {
      id = await isarInstance.saleModels.put(saleModel);
    });

    return id;
  }

  Future<void> deleteSale({required SaleModel saleModel}) async {
    await isarInstance.writeTxn(() async {
      await isarInstance.saleModels.delete(saleModel.isarId);
    });
  }
}
