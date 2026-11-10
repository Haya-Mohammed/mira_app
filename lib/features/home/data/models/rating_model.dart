class RatingModel {
  const RatingModel({this.average = 0, this.count = 0});

  factory RatingModel.fromJson(Map<String, dynamic> json) => RatingModel(
    average: (json['average'] as num?)?.toDouble() ?? 0,
    count: json['count'] as int? ?? 0,
  );

  final double average;
  final int count;

  Map<String, dynamic> toJson() => {'average': average, 'count': count};
}
