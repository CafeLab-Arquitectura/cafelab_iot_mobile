class Portfolio {
  const Portfolio({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
  });

  final int id;
  final int userId;
  final String name;
  final String createdAt;

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val) {
      if (val is num) return val.toInt();
      return int.tryParse('$val') ?? 0;
    }

    return Portfolio(
      id: toInt(json['id']),
      userId: toInt(json['userId']),
      name: (json['name'] as String?) ?? '',
      createdAt: (json['createdAt'] as String?) ?? '',
    );
  }
}
