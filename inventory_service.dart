import 'package:hive_flutter/hive_flutter.dart';
import '../models/medicine.dart';

class InventoryService {
  static late Box<Medicine> medicines;
  static late Box<StockLog> logs;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(MedicineAdapter());
    Hive.registerAdapter(StockLogAdapter());
    medicines = await Hive.openBox<Medicine>('medicines');
    logs = await Hive.openBox<StockLog>('stock_logs');
  }

  static String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  // CREATE and UPDATE: putting the same key again overwrites the record.
  static Future<void> save(Medicine m, {required bool isNew}) async {
    await medicines.put(m.id, m);
    if (isNew && m.quantity > 0) {
      await _log(m, isIn: true, qty: m.quantity, note: 'Initial stock');
    }
  }

  // DELETE
  static Future<void> delete(String id) => medicines.delete(id);

  // STOCK-IN / STOCK-OUT: change the quantity and record a log entry.
  static Future<void> adjustStock(Medicine m, int qty, {required bool isIn}) async {
    m.quantity = isIn ? m.quantity + qty : m.quantity - qty;
    await medicines.put(m.id, m);
    await _log(m, isIn: isIn, qty: qty);
  }

  static Future<void> _log(Medicine m,
      {required bool isIn, required int qty, String note = ''}) {
    final log = StockLog(
      id: _newId(),
      medicineId: m.id,
      medicineName: m.name,
      isIn: isIn,
      quantity: qty,
      date: DateTime.now(),
      note: note,
    );
    return logs.put(log.id, log);
  }
}