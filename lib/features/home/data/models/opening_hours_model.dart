class OpeningHoursModel {
  const OpeningHoursModel({
    required this.day,
    this.label,
    this.open = false,
    this.ranges = const [],
  });

  factory OpeningHoursModel.fromJson(Map<String, dynamic> json) =>
      OpeningHoursModel(
        day: json['day'] as String,
        label: json['label'] as String?,
        open: json['open'] as bool? ?? false,
        ranges: List<String>.from(json['ranges'] as List? ?? const []),
      );

  final String day;
  final String? label;
  final bool open;
  final List<String> ranges;

  Map<String, dynamic> toJson() => {
    'day': day,
    'label': label,
    'open': open,
    'ranges': ranges,
  };
}
