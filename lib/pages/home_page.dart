import 'package:flutter/material.dart';
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
              'Controle de Vendas',
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
    final homeController = Provider.of<HomeController>(context);

    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar Venda'),
          content: Container(
            constraints: const BoxConstraints(maxWidth: 100),
            height: 412,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Título'),
                  TextField(
                    controller: homeController.saleTitle,
                  ),
                  const SizedBox(height: 12),
                  const Text('Valor'),
                  TextField(
                    controller: homeController.saleValue,
                  ),
                  const SizedBox(height: 12),
                  const Text('Nome do Cliente'),
                  TextField(
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
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Registrar'),
            ),
          ],
        );
      },
    );
  }
}
