class PlaceLabelsModel {
  const PlaceLabelsModel({
    this.staff,
    this.staffPlural,
    this.service,
    this.servicePlural,
    this.customer,
    this.booking,
  });

  factory PlaceLabelsModel.fromJson(Map<String, dynamic> json) =>
      PlaceLabelsModel(
        staff: json['staff'] as String?,
        staffPlural: json['staff_plural'] as String?,
        service: json['service'] as String?,
        servicePlural: json['service_plural'] as String?,
        customer: json['customer'] as String?,
        booking: json['booking'] as String?,
      );

  final String? staff;
  final String? staffPlural;
  final String? service;
  final String? servicePlural;
  final String? customer;
  final String? booking;

  Map<String, dynamic> toJson() => {
    'staff': staff,
    'staff_plural': staffPlural,
    'service': service,
    'service_plural': servicePlural,
    'customer': customer,
    'booking': booking,
  };
}
