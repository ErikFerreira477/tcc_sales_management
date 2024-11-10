import 'package:asuka/asuka.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sales_management/controllers/controller.dart';
import 'package:sales_management/core/core.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomeController>(context);
    TextStyle boldTitle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 45,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Stack(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Central de Vendas'),
              ],
            ),
            Positioned(
              right: 0,
              child: GestureDetector(
                onTap: () async => showFilterModal(context: context),
                child: const Icon(
                  Icons.filter_alt_outlined,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder(
          future: !homeController.isFilterActive
              ? homeController.handleHomePageData()
              : homeController.handleHomePageDataFiltered(),
          builder: (context, s) {
            if (homeController.isLoading || s.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Produto',
                          style: boldTitle,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Data',
                          style: boldTitle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Valor',
                          style: boldTitle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: homeController.sales.length,
                      itemBuilder: (context, index) {
                        final sale = homeController.sales[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Expanded(flex: 3, child: Text(sale.productName)),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  sale.date.formatNumericDayMonthYear(),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'R\$ ${sale.price.toStringAsFixed(2)}',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 82),
                ],
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => await showModalRegisterSale(context),
        tooltip: 'Registrar Venda',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> showModalRegisterSale(BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final homeController = Provider.of<HomeController>(context);

        return AlertDialog(
          title: const Text('Registrar Venda'),
          content: Container(
            constraints: const BoxConstraints(maxWidth: 100),
            height: 412,
            child: !homeController.isLoading
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Título'),
                        TextField(
                          onChanged: (value) => homeController.handleIsAllFieldsFilled(),
                          controller: homeController.saleTitle,
                        ),
                        const SizedBox(height: 12),
                        const Text('Valor'),
                        Stack(
                          children: [
                            const Positioned(
                              top: 13,
                              child: Text('R\$'),
                            ),
                            TextField(
                              onChanged: (value) => homeController.handleIsAllFieldsFilled(),
                              controller: homeController.saleValue,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                LengthLimitingTextInputFormatter(8),
                              ],
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(left: 24),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('Nome do Cliente'),
                        TextField(
                          onChanged: (value) => homeController.handleIsAllFieldsFilled(),
                          controller: homeController.saleClientName,
                        ),
                        const SizedBox(height: 12),
                        const Text('Data'),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () async => await homeController.onChangeSelecteDate(context: context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Theme.of(context).colorScheme.primary),
                            ),
                            child: Text(
                              homeController.selectedDate.formatNumericDayMonthYear(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: !homeController.isLoadingModalAddSale
                  ? () => homeController.onCloseModalRegisterSale(context: context)
                  : null,
              style: ButtonStyle(
                textStyle: WidgetStateProperty.all(
                  const TextStyle(
                    color: null,
                  ),
                ),
              ),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: ButtonStyle(
                textStyle: WidgetStateProperty.all(
                  TextStyle(
                    color: !homeController.isAllFieldsFilled ? Colors.grey : null,
                  ),
                ),
              ),
              onPressed: !homeController.isLoadingModalAddSale && homeController.isAllFieldsFilled
                  ? () async => await homeController.onAddSale(context: context)
                  : null,
              child: const Text('Registrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showFilterModal({required BuildContext context}) async {
    final homeController = Provider.of<HomeController>(context, listen: false);

    if (homeController.sales.isEmpty && !homeController.isFilterActive) {
      AsukaSnackbar.message("Não há vendas registradas").show();

      return;
    }

    await showModalBottomSheet(
      enableDrag: false,
      isDismissible: false,
      context: context,
      builder: (context) {
        final homeController = Provider.of<HomeController>(context);

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
                    homeController.isFilterActive
                        ? 'De: ${homeController.selectedDateRange.start.day}/${homeController.selectedDateRange.start.month}/${homeController.selectedDateRange.start.year}'
                        : 'De: ${homeController.baseSalesRange?.start.day}/${homeController.baseSalesRange?.start.month}/${homeController.baseSalesRange?.start.year}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    homeController.isFilterActive
                        ? 'Até: ${homeController.selectedDateRange.end.day}/${homeController.selectedDateRange.end.month}/${homeController.selectedDateRange.end.year}'
                        : 'Até: ${homeController.baseSalesRange?.end.day}/${homeController.baseSalesRange?.end.month}/${homeController.baseSalesRange?.end.year}',
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
                    onTap: () => homeController.onCloseModalFilter(context: context),
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
                    onTap: () async => await homeController.onFilterSaltes(context: context),
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
}
