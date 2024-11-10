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

  // Filter Flow --------------------------------------------------

  DateTimeRange selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 1)),
    end: DateTime.now(),
  );

  DateTimeRange? baseSalesRange;

  bool isFilterActive = false;

  Future<void> handleHomePageDataFiltered() async {
    try {
      sales = await IsarDB.instance.getSalesByDateRange(dateRange: selectedDateRange);
    } catch (e) {
      AsukaSnackbar.alert("Erro ao carregar informações: $e").show();
    }
  }

  void onCloseModalFilter({required BuildContext context}) {
    selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );

    isFilterActive = false;

    notifyListeners();

    Navigator.of(context).pop();
  }

  Future<void> onFilterSaltes({required BuildContext context}) async {
    DateTimeRange oldSelectedDateRange = selectedDateRange;

    selectedDateRange = await showDateRangePicker(
          context: context,
          firstDate: baseSalesRange?.start ?? DateTime(2021),
          lastDate: baseSalesRange?.end ?? DateTime.now(),
          initialDateRange: isFilterActive ? selectedDateRange : null,
        ) ??
        oldSelectedDateRange;

    if (oldSelectedDateRange.start.day == selectedDateRange.start.day &&
        oldSelectedDateRange.start.month == selectedDateRange.start.month &&
        oldSelectedDateRange.start.year == selectedDateRange.start.year &&
        oldSelectedDateRange.end.day == selectedDateRange.end.day &&
        oldSelectedDateRange.end.month == selectedDateRange.end.month &&
        oldSelectedDateRange.end.year == selectedDateRange.end.year) {
      return;
    }

    if (selectedDateRange.start.day == selectedDateRange.end.day) {
      selectedDateRange = DateTimeRange(
        start: selectedDateRange.start,
        end: selectedDateRange.end.add(const Duration(hours: 23, minutes: 59)),
      );
    }

    isFilterActive = true;

    notifyListeners();

    Navigator.of(context).pop();
  }

  // Fill Screen Flow ---------------------------------------------

  List<SaleModel> sales = [];

  Future<void> handleHomePageData() async {
    try {
      sales = await IsarDB.instance.getAllSales();

      if (sales.isNotEmpty) {
        baseSalesRange = DateTimeRange(
          start: sales.last.date,
          end: sales.first.date,
        );
      }
    } catch (e) {
      AsukaSnackbar.alert("Erro ao carregar informações: $e").show();
    }
  }

  // Register Sale Flow -------------------------------------------

  TextEditingController saleTitle = TextEditingController();

  TextEditingController saleValue = TextEditingController();

  TextEditingController saleClientName = TextEditingController();

  DateTime selectedDate = DateTime.now();

  Future<void> onChangeSelecteDate({required BuildContext context}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      selectedDate = picked;
    }

    notifyListeners();
  }

  Future<void> onAddSale({required BuildContext context}) async {
    changeIsLoadingModalAddSale();

    try {
      SaleModel sale = SaleModel(
        id: const Uuid().v4(),
        productName: saleTitle.text,
        price: double.parse(saleValue.text),
        date: selectedDate,
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
    saleClientName.clear();
    selectedDate = DateTime.now();
    isAllFieldsFilled = false;
  }

  bool isAllFieldsFilled = false;

  void handleIsAllFieldsFilled() {
    isAllFieldsFilled = saleTitle.text.isNotEmpty && saleValue.text.isNotEmpty && saleClientName.text.isNotEmpty;

    notifyListeners();
  }
}
