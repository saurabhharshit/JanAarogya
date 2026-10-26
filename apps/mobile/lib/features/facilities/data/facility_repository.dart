class FacilityItem {
  final String name;
  final String type;
  final String phone;
  final String distanceKm;
  final bool is24x7;

  FacilityItem({
    required this.name,
    required this.type,
    required this.phone,
    required this.distanceKm,
    required this.is24x7,
  });
}

class FacilityRepository {
  List<FacilityItem> getCachedFacilities() {
    return [
      FacilityItem(
        name: 'District Government Hospital',
        type: 'Hospital',
        phone: '+91 9876543210',
        distanceKm: '3.2 km',
        is24x7: true,
      ),
      FacilityItem(
        name: 'Primary Health Center (PHC)',
        type: 'Clinic',
        phone: '+91 9876543211',
        distanceKm: '1.1 km',
        is24x7: false,
      ),
      FacilityItem(
        name: 'Jan Aushadhi Pharmacy',
        type: 'Pharmacy',
        phone: '+91 9876543212',
        distanceKm: '0.8 km',
        is24x7: false,
      ),
    ];
  }
}
