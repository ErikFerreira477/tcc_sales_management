// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
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

  Future<void> showFilterModal({required BuildContext context}) async {
    if (sales.isEmpty && !isFilterActive) {
      AsukaSnackbar.message("Não há vendas registradas").show();

      return;
    }

    await showModalBottomSheet(
      enableDrag: false,
      isDismissible: false,
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Filtrar por data',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.close,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    isFilterActive
                        ? 'De: ${selectedDateRange.start.day}/${selectedDateRange.start.month}/${selectedDateRange.start.year}'
                        : 'De: ${baseSalesRange?.start.day}/${baseSalesRange?.start.month}/${baseSalesRange?.start.year}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isFilterActive
                        ? 'Até: ${selectedDateRange.end.day}/${selectedDateRange.end.month}/${selectedDateRange.end.year}'
                        : 'Até: ${baseSalesRange?.end.day}/${baseSalesRange?.end.month}/${baseSalesRange?.end.year}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () async {
                      selectedDateRange = DateTimeRange(
                        start: DateTime.now().subtract(const Duration(days: 30)),
                        end: DateTime.now(),
                      );

                      isFilterActive = false;

                      notifyListeners();

                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).colorScheme.primary),
                      ),
                      child: Text(
                        'Limpar Filtro',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
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
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Selecionar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  bool isFilterActive = false;

  Future<void> handleHomePageDataFiltered() async {
    try {
      sales = await IsarDB.instance.getSalesByDateRange(dateRange: selectedDateRange);
    } catch (e) {
      AsukaSnackbar.alert("Erro ao carregar informações: $e").show();
    }
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
