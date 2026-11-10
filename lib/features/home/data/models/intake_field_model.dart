class IntakeFieldModel {
  const IntakeFieldModel({
    required this.key,
    this.labelAr,
    this.labelEn,
    this.type,
    this.options = const [],
  });

  factory IntakeFieldModel.fromJson(Map<String, dynamic> json) =>
      IntakeFieldModel(
        key: json['key'] as String,
        labelAr: json['label_ar'] as String?,
        labelEn: json['label_en'] as String?,
        type: json['type'] as String?,
        options: List<String>.from(json['options'] as List? ?? const []),
      );

  final String key;
  final String? labelAr;
  final String? labelEn;
  final String? type;
  final List<String> options;

  Map<String, dynamic> toJson() => {
    'key': key,
    'label_ar': labelAr,
    'label_en': labelEn,
    'type': type,
    'options': options,
  };
}
