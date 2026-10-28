import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/medicine.dart';
import '../services/inventory_service.dart';

Future<void> showStockDialog(BuildContext context, Medicine m, {required bool isIn}) async {
  final controller = TextEditingController();
  String? error;

  final qty = await showDialog<int>(
    context: context,
    builder: (d) => StatefulBuilder(
      builder: (d, setState) => AlertDialog(
        title: Text(isIn ? 'Stock in' : 'Stock out'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(labelText: 'Quantity', errorText: error),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final q = int.tryParse(controller.text);
              if (q == null || q <= 0) {
                setState(() => error = 'Enter a quantity above 0');
              } else if (!isIn && q > m.quantity) {
                setState(() => error = 'Only ${m.quantity} available');
              } else {
                Navigator.pop(d, q);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    ),
  );
  controller.dispose();
  if (qty == null || !context.mounted) return;

  await InventoryService.adjustStock(m, qty, isIn: isIn);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isIn ? 'Added $qty to ${m.name}' : 'Removed $qty from ${m.name}')),
    );
  }
}