import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/medicine.dart';
import '../services/inventory_service.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity'), backgroundColor: Color(0xFFB8E8FE),),
      body: ValueListenableBuilder<Box<StockLog>>(
        valueListenable: InventoryService.logs.listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No activity yet.'));
          }
          // Newest first
          final logs = box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
          return ListView.separated(
            itemCount: logs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final l = logs[i];
              final d = l.date;
              return ListTile(
                title: Text(l.medicineName),
                subtitle: Text(
                  '${d.day}/${d.month}/${d.year}${l.note.isEmpty ? '' : ' · ${l.note}'}',
                ),
                trailing: Text(
                  '${l.isIn ? '+' : '-'}${l.quantity}',
                  style: const TextStyle(fontSize: 18),
                ),
              );
            },
          );
        },
      ),
    );
  }
}