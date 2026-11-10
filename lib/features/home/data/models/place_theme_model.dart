class PlaceThemeModel {
  const PlaceThemeModel({this.name, this.primaryColor});

  factory PlaceThemeModel.fromJson(Map<String, dynamic> json) =>
      PlaceThemeModel(
        name: json['name'] as String?,
        primaryColor: json['primary_color'] as String?,
      );

  final String? name;

  /// Hex string from the API, e.g. `#6C5CE7`.
  final String? primaryColor;

  Map<String, dynamic> toJson() => {
    'name': name,
    'primary_color': primaryColor,
  };
}
