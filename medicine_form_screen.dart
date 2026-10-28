import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/medicine.dart';
import '../services/inventory_service.dart';

class MedicineFormScreen extends StatefulWidget {
  const MedicineFormScreen({super.key, this.medicine});
  final Medicine? medicine;

  @override
  State<MedicineFormScreen> createState() => _MedicineFormScreenState();
}

class _MedicineFormScreenState extends State<MedicineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.medicine?.name ?? '');
  late final _quantity = TextEditingController(text: '${widget.medicine?.quantity ?? ''}');
  late final _minStock = TextEditingController(text: '${widget.medicine?.minStock ?? 10}');
  late final _category = TextEditingController(text: widget.medicine?.category ?? '');
  DateTime? _expiry;
  bool get _isEditing => widget.medicine != null;

  @override
  void initState() {
    super.initState();
    _expiry = widget.medicine?.expiry;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiry ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 15),
    );
    if (picked != null) setState(() => _expiry = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return; // blocks empty or invalid input
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final medicine = Medicine(
      id: widget.medicine?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: _name.text.trim(),
      category: _category.text.trim(),
      quantity: int.parse(_quantity.text),
      unit: 'pcs',
      minStock: int.parse(_minStock.text),
      expiry: _expiry!,
    );
    await InventoryService.save(medicine, isNew: !_isEditing);

    navigator.pop();
    messenger.showSnackBar(
      SnackBar(content: Text(_isEditing ? 'Changes saved' : '${medicine.name} added')),
    );
  }

  Future<void> _confirmDelete() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final name = widget.medicine!.name;

    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text('Delete $name?'),
        content: const Text('This removes the medicine from your inventory.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(d, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;

    await InventoryService.delete(widget.medicine!.id);
    navigator.pop();
    messenger.showSnackBar(SnackBar(content: Text('$name deleted')));
  }

  String? _number(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (int.tryParse(v) == null) return 'Enter a whole number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit medicine' : 'Add medicine'), backgroundColor: Color(0xFFB8E8FE),),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Medicine name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Category is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantity,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Quantity'),
              validator: _number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _minStock,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Low-stock level'),
              validator: _number,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_expiry == null
                  ? 'Pick expiry date'
                  : 'Expires ${_expiry!.day}/${_expiry!.month}/${_expiry!.year}'),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _pickDate,
            ),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Color(0xFFB8E8FE),
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(52),
                
              ),
              
              onPressed: () {
                if (_expiry == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please pick an expiry date')),
                  );
                  return;
                }
                _save();
              },
              child: Text(_isEditing ? 'Save changes' : 'Add medicine' ),
            ),
            if (_isEditing)
              TextButton(
                onPressed: _confirmDelete,
                child: const Text('Delete', style: TextStyle(color: Color.fromARGB(217, 236, 95, 95))),
              ),
          ],
        ),
      ),
    );
  }
}