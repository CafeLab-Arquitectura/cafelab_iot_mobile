class Ingredient {
  const Ingredient({
    required this.id,
    required this.recipeId,
    required this.name,
    required this.amount,
    required this.unit,
  });

  final int id;
  final int recipeId;
  final String name;
  final double amount;
  final String unit;

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val) {
      if (val is num) return val.toInt();
      return int.tryParse('$val') ?? 0;
    }

    double toDouble(dynamic val) {
      if (val is num) return val.toDouble();
      return double.tryParse('$val') ?? 0.0;
    }

    return Ingredient(
      id: toInt(json['id']),
      recipeId: toInt(json['recipeId']),
      name: (json['name'] as String?) ?? '',
      amount: toDouble(json['amount']),
      unit: (json['unit'] as String?) ?? '',
    );
  }
}
