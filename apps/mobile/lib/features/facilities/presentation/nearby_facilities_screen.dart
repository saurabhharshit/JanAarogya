import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../data/facility_repository.dart';

class NearbyFacilitiesScreen extends StatelessWidget {
  NearbyFacilitiesScreen({super.key});

  final FacilityRepository _repository = FacilityRepository();

  @override
  Widget build(BuildContext context) {
    final list = _repository.getCachedFacilities();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('पास के अस्पताल / Nearby Facilities'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.accent,
                child: Icon(
                  item.type == 'Pharmacy'
                      ? Icons.local_pharmacy
                      : Icons.local_hospital,
                  color: AppColors.primary,
                ),
              ),
              title: Text(item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  '${item.type} • दूरी: ${item.distanceKm}\nफोन: ${item.phone}'),
              trailing: item.is24x7
                  ? const Chip(
                      label: Text('24/7',
                          style: TextStyle(color: Colors.white, fontSize: 10)),
                      backgroundColor: Colors.green,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
