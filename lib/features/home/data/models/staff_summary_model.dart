/// Short staff shape, as nested inside a service.
class StaffSummaryModel {
  const StaffSummaryModel({
    required this.id,
    required this.name,
    this.title,
    this.avatar,
    this.initials,
    this.color,
  });

  factory StaffSummaryModel.fromJson(Map<String, dynamic> json) =>
      StaffSummaryModel(
        id: json['id'] as int,
        name: json['name'] as String,
        title: json['title'] as String?,
        avatar: json['avatar'] as String?,
        initials: json['initials'] as String?,
        color: json['color'] as String?,
      );

  final int id;
  final String name;
  final String? title;
  final String? avatar;
  final String? initials;
  final String? color;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'title': title,
    'avatar': avatar,
    'initials': initials,
    'color': color,
  };
}
