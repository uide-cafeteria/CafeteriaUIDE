// Modelo para las promociones de la cafetería
class Promotion {
  final String id;
  final String title;
  final String description;
  final String image;
  final double discountPercentage;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.discountPercentage,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  // Verifica si la promoción está vigente
  bool get isValid {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }

  // Días restantes de la promoción
  int get daysRemaining {
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }

  // Copia con modificaciones
  Promotion copyWith({
    String? id,
    String? title,
    String? description,
    String? image,
    double? discountPercentage,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return Promotion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
