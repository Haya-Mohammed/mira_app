class ServiceImageModel {
  const ServiceImageModel({this.path, this.url, this.thumb});

  factory ServiceImageModel.fromJson(Map<String, dynamic> json) =>
      ServiceImageModel(
        path: json['path'] as String?,
        url: json['url'] as String?,
        thumb: json['thumb'] as String?,
      );

  final String? path;
  final String? url;
  final String? thumb;

  Map<String, dynamic> toJson() => {'path': path, 'url': url, 'thumb': thumb};
}
