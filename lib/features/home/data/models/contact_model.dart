class ContactModel {
  const ContactModel({
    this.phone,
    this.whatsapp,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
    phone: json['phone'] as String?,
    whatsapp: json['whatsapp'] as String?,
    address: json['address'] as String?,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
  );

  final String? phone;
  final String? whatsapp;
  final String? address;
  final double? latitude;
  final double? longitude;

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'whatsapp': whatsapp,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
  };
}
