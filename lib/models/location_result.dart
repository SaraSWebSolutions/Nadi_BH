class LocationResult {
  final double latitude;
  final double longitude;

  final String fullAddress;
  final String city;
  final String block;
  final String road;
  final String building;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.fullAddress,
    required this.city,
    required this.block,
    required this.road,
    required this.building,
  });
}
