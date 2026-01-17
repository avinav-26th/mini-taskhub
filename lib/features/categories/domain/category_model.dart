// [1] VERSION: 1.0.0 - Category Model
// UI segment: n/a
// BACKEND segment: Data Model

class Category {
  final int id;
  final String name;
  final String colorHex;
  final int position;

  Category({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.position,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      colorHex: map['color_hex'] as String,
      position: map['position_index'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'color_hex': colorHex,
      'position_index': position,
    };
  }
}