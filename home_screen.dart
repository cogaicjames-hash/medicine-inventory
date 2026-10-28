import 'package:flutter/material.dart';
import 'activity_screen.dart';
import 'dashboard_screen.dart';
import 'medicine_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  static const _pages = [DashboardScreen(), MedicineListScreen(), ActivityScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        height: 50,
       backgroundColor: const Color(0xFFB8E8FE),
        indicatorColor: const Color(0xFF7CCBF0),
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.medication_outlined), label: 'Medicines'),
          NavigationDestination(icon: Icon(Icons.swap_vert), label: 'Activity'),
        ],
      ),
    );
  }
}