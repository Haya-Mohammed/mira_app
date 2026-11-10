class PlaceTypeModel {
  const PlaceTypeModel({required this.key, required this.name, this.icon});

  factory PlaceTypeModel.fromJson(Map<String, dynamic> json) => PlaceTypeModel(
    key: json['key'] as String,
    name: json['name'] as String,
    icon: json['icon'] as String?,
  );

  final String key;
  final String name;
  final String? icon;

  Map<String, dynamic> toJson() => {'key': key, 'name': name, 'icon': icon};
}
