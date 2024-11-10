// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sales_management/core/core.dart';
import 'package:sales_management/core/db/db.dart';
import 'package:uuid/uuid.dart';
import 'package:asuka/asuka.dart';

class HomeController with ChangeNotifier {
  // General variables -------------------------------------------

  bool isLoading = false;

  void changeIsLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  bool isLoadingModalAddSale = false;

  void changeIsLoadingModalAddSale() {
    isLoadingModalAddSale = !isLoadingModalAddSale;
    notifyListeners();
  }

  // Fill Screen Flow ---------------------------------------------

  List<SaleModel> sales = [];

  Future<void> handleHomePageData() async {
    try {
      sales = await IsarDB.instance.getAllSales();
    } catch (e) {
      AsukaSnackbar.alert("Erro ao carregar informações: $e").show();
    }
  }

  // Register Sale Flow -------------------------------------------

  TextEditingController saleTitle = TextEditingController();

  TextEditingController saleValue = TextEditingController();

  TextEditingController saleObservation = TextEditingController();

  TextEditingController saleClientName = TextEditingController();

  Future<void> onAddSale({required BuildContext context}) async {
    changeIsLoadingModalAddSale();

    try {
      SaleModel sale = SaleModel(
        id: const Uuid().v4(),
        productName: saleTitle.text,
        price: double.parse(saleValue.text),
        date: DateTime.now(),
        observation: saleObservation.text,
        clientName: saleClientName.text,
      );

      await IsarDB.instance.createSale(saleModel: sale);

      AsukaSnackbar.success("Venda registrada com sucesso").show();
    } catch (e) {
      AsukaSnackbar.alert("Erro ao registrar venda: $e").show();
    }

    disposeFields();

    changeIsLoadingModalAddSale();

    Navigator.of(context).pop();
  }

  void onCloseModalRegisterSale({required BuildContext context}) {
    changeIsLoadingModalAddSale();

    disposeFields();

    changeIsLoadingModalAddSale();

    Navigator.of(context).pop();
  }

  void disposeFields() {
    saleTitle.clear();
    saleValue.clear();
    saleObservation.clear();
    saleClientName.clear();
    isAllFieldsFilled = false;
  }

  bool isAllFieldsFilled = false;

  void handleIsAllFieldsFilled() {
    isAllFieldsFilled = saleTitle.text.isNotEmpty && saleValue.text.isNotEmpty && saleClientName.text.isNotEmpty;

    notifyListeners();
  }
}
