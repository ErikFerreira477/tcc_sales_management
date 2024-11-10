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
                onTap: () async => homeController.showFilterModal(context: context),
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
                        const Text('Observação'),
                        TextField(
                          controller: homeController.saleObservation,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
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
}
