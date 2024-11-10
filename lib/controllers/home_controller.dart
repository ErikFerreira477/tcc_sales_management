import 'package:flutter/material.dart';

class HomeController with ChangeNotifier {
  // int _salesCount = 0;

  // int get salesCount => _salesCount;

  // void addSale() {
  //   _salesCount++;
  //   notifyListeners(); // Notifica os ouvintes para reconstruir os widgets interessados
  // }

  //  String id;
  // String productName;
  // double price;
  // DateTime date;
  // String? observation;
  // String? clientName;

  bool isLoading = false;

  void changeIsLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  TextEditingController saleTitle = TextEditingController();

  TextEditingController saleValue = TextEditingController();

  TextEditingController saleObservation = TextEditingController();

  TextEditingController saleClientName = TextEditingController();

  Future<void> onAddSale() async {}

  Future<void> onCloseModal() async {}
}
