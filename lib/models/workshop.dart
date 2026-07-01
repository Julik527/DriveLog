class Workshop {
  final String name;
  final String address;
  final String phone;
  final double? latitude;
  final double? longitude;

  const Workshop({
    required this.name,
    required this.address,
    required this.phone,
    this.latitude,
    this.longitude,
  });
}
