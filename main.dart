import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/inventory_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InventoryService.init(); // boxes must be open before any screen reads them
  runApp(const MedicineInventoryApp());
}

class MedicineInventoryApp extends StatelessWidget {
  const MedicineInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicine Inventory',
      debugShowCheckedModeBanner: false,
      color: Colors.red,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.black,
        scaffoldBackgroundColor: Colors.white,
      
      ),
    
      home: const HomeScreen(),
    );
  }
}