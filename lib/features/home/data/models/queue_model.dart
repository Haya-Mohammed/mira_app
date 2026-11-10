class QueueModel {
  const QueueModel({this.enabled = false});

  factory QueueModel.fromJson(Map<String, dynamic> json) =>
      QueueModel(enabled: json['enabled'] as bool? ?? false);

  final bool enabled;

  Map<String, dynamic> toJson() => {'enabled': enabled};
}
