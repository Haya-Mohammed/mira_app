import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    this.icon,
    this.image,
    this.sortOrder = 0,
    this.isActive = false,
    this.servicesCount = 0,
  });

  final int id;
  final String name;
  final String? icon;
  final String? image;
  final int sortOrder;
  final bool isActive;
  final int servicesCount;

  @override
  List<Object?> get props => [
    id,
    name,
    icon,
    image,
    sortOrder,
    isActive,
    servicesCount,
  ];
}
