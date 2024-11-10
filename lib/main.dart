import 'package:asuka/asuka.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_management/controllers/controller.dart';
import 'package:sales_management/core/db/db.dart';
import 'package:sales_management/pages/home_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await IsarDB.instance.init();

  runApp(const SalesManagementApp());
}

class SalesManagementApp extends StatelessWidget {
  const SalesManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => HomeController(),
        ),
      ],
      child: MaterialApp(
        builder: Asuka.builder,
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
        navigatorObservers: [Asuka.asukaHeroController],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [
          Locale('pt', 'BR'),
        ],
      ),
    );
  }
}
