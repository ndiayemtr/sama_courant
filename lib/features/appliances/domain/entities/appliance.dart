class Appliance {
  final int? id;
  final String name;
  final String category;
  final double powerWatts;
  final int quantity;
  final double hoursPerDay;
  final int daysPerMonth;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Appliance({
    this.id,
    required this.name,
    required this.category,
    required this.powerWatts,
    required this.quantity,
    required this.hoursPerDay,
    required this.daysPerMonth,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}
