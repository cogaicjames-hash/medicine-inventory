import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/medicine.dart';
import '../services/inventory_service.dart';
import 'medicine_form_screen.dart';

class MedicineListScreen extends StatelessWidget {
  const MedicineListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicines'), backgroundColor: Color(0xFFB8E8FE),),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFB8E8FE),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MedicineFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder<Box<Medicine>>(
        valueListenable: InventoryService.medicines.listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No medicines yet. Tap + to add one.'));
          }
          final items = box.values.toList()
            ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final m = items[i];
              return ListTile(
                title: Text(m.name),
                subtitle: Text(
                  m.flags.isEmpty ? m.category : m.flags.join(' · '),
                  style: TextStyle(
                    color: m.isExpired
                        ? Colors.red.shade700
                        : (m.flags.isEmpty ? Colors.grey : Colors.orange.shade800),
                  ),
                ),
                trailing: Text('${m.quantity} ${m.unit}'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MedicineFormScreen(medicine: m)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}