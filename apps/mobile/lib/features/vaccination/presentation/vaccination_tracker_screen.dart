import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../data/vaccination_repository.dart';

class VaccinationTrackerScreen extends StatefulWidget {
  const VaccinationTrackerScreen({super.key});

  @override
  State<VaccinationTrackerScreen> createState() =>
      _VaccinationTrackerScreenState();
}

class _VaccinationTrackerScreenState extends State<VaccinationTrackerScreen> {
  final VaccinationRepository _repository = VaccinationRepository();
  late List<VaccineItem> _vaccines;

  @override
  void initState() {
    super.initState();
    _vaccines = _repository.getDefaultNationalSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('टीकाकरण / Vaccination Schedule'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _vaccines.length,
        itemBuilder: (context, index) {
          final item = _vaccines[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    item.isAdministered ? Colors.green : AppColors.warningAmber,
                child: Icon(
                  item.isAdministered ? Icons.check : Icons.vaccines,
                  color: Colors.white,
                ),
              ),
              title: Text(item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  'उपयुक्त समय: ${item.targetAge}\nतारीख: ${item.dueDate}'),
              trailing: Checkbox(
                value: item.isAdministered,
                onChanged: (val) {
                  setState(() {
                    _vaccines[index] = VaccineItem(
                      id: item.id,
                      vaccineCode: item.vaccineCode,
                      name: item.name,
                      targetAge: item.targetAge,
                      dueDate: item.dueDate,
                      isAdministered: val ?? false,
                    );
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
