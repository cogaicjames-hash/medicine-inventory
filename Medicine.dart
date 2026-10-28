import 'package:hive/hive.dart';

class Medicine {
  Medicine({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.minStock,
    required this.expiry,
    this.notes = '',
  });

  final String id;
  String name;
  String category;
  int quantity;
  String unit;
  int minStock;
  DateTime expiry;
  String notes;

  // Business rules live in the model, not in the screens.
  int get daysToExpiry {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTime(expiry.year, expiry.month, expiry.day).difference(today).inDays;
  }

  bool get isExpired => daysToExpiry < 0;
  bool get isNearExpiry => daysToExpiry >= 0 && daysToExpiry <= 30;
  bool get isLowStock => quantity <= minStock;
  bool get needsAttention => isExpired || isNearExpiry || isLowStock;

  List<String> get flags => [
        if (isExpired) 'Expired',
        if (isNearExpiry) 'Expires in $daysToExpiry days',
        if (isLowStock) 'Low stock',
      ];
}

class StockLog {
  StockLog({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.isIn,
    required this.quantity,
    required this.date,
    this.note = '',
  });

  final String id;
  final String medicineId;
  final String medicineName;
  final bool isIn; // true = stock-in, false = stock-out
  final int quantity;
  final DateTime date;
  final String note;
}

class MedicineAdapter extends TypeAdapter<Medicine> {
  @override
  final int typeId = 0; // must be unique per class

  @override
  Medicine read(BinaryReader r) => Medicine(
        id: r.readString(),
        name: r.readString(),
        category: r.readString(),
        quantity: r.readInt(),
        unit: r.readString(),
        minStock: r.readInt(),
        expiry: DateTime.fromMillisecondsSinceEpoch(r.readInt()),
        notes: r.readString(),
      );

  @override
  void write(BinaryWriter w, Medicine m) {
    w
      ..writeString(m.id)
      ..writeString(m.name)
      ..writeString(m.category)
      ..writeInt(m.quantity)
      ..writeString(m.unit)
      ..writeInt(m.minStock)
      ..writeInt(m.expiry.millisecondsSinceEpoch)
      ..writeString(m.notes);
  }
}

class StockLogAdapter extends TypeAdapter<StockLog> {
  @override
  final int typeId = 1;

  @override
  StockLog read(BinaryReader r) => StockLog(
        id: r.readString(),
        medicineId: r.readString(),
        medicineName: r.readString(),
        isIn: r.readBool(),
        quantity: r.readInt(),
        date: DateTime.fromMillisecondsSinceEpoch(r.readInt()),
        note: r.readString(),
      );

  @override
  void write(BinaryWriter w, StockLog l) {
    w
      ..writeString(l.id)
      ..writeString(l.medicineId)
      ..writeString(l.medicineName)
      ..writeBool(l.isIn)
      ..writeInt(l.quantity)
      ..writeInt(l.date.millisecondsSinceEpoch)
      ..writeString(l.note);
  }
}