import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/medicine.dart';
import '../services/inventory_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Overview'), backgroundColor: Color(0xFFB8E8FE),),
    
      body: ValueListenableBuilder<Box<Medicine>>(
        valueListenable: InventoryService.medicines.listenable(),
        builder: (context, box, _) {
          final items = box.values.toList();
          final low = items.where((m) => m.isLowStock).length;
          final near = items.where((m) => m.isNearExpiry).length;
          final expired = items.where((m) => m.isExpired).length;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _stat('Total medicines', items.length),
              _stat('Low stock', low),
              _stat('Near expiry', near),
              _stat('Expired', expired),
            ],
          );
        },
      ),
    );
  }

  Widget _stat(String label, int value) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text('$value', style: const TextStyle(fontSize: 24))],
        ),
      );
}