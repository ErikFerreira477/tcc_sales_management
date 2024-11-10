import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sales_management/controllers/controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Central de Vendas',
            ),
          ],
        ),
      ),
      body: const Column(
        children: [],
      ),
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
              onPressed:
                  !homeController.isLoading ? () => homeController.onCloseModalRegisterSale(context: context) : null,
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
              onPressed: !homeController.isLoading && homeController.isAllFieldsFilled
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
