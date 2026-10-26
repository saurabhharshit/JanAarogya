class VaccineItem {
  final String id;
  final String vaccineCode;
  final String name;
  final String targetAge;
  final String dueDate;
  final bool isAdministered;

  VaccineItem({
    required this.id,
    required this.vaccineCode,
    required this.name,
    required this.targetAge,
    required this.dueDate,
    this.isAdministered = false,
  });
}

class VaccinationRepository {
  /// Returns standard national immunization schedule
  List<VaccineItem> getDefaultNationalSchedule() {
    final now = DateTime.now();
    return [
      VaccineItem(
        id: 'vac_1',
        vaccineCode: 'BCG',
        name: 'BCG (बीसीजी)',
        targetAge: 'At Birth (जन्म पर)',
        dueDate: now.toIso8601String().split('T')[0],
      ),
      VaccineItem(
        id: 'vac_2',
        vaccineCode: 'OPV_1',
        name: 'OPV 1 (पोलियो 1)',
        targetAge: '6 Weeks (6 सप्ताह)',
        dueDate:
            now.add(const Duration(days: 42)).toIso8601String().split('T')[0],
      ),
      VaccineItem(
        id: 'vac_3',
        vaccineCode: 'PENTA_1',
        name: 'Pentavalent 1 (पेंटावेलेंट 1)',
        targetAge: '6 Weeks (6 सप्ताह)',
        dueDate:
            now.add(const Duration(days: 42)).toIso8601String().split('T')[0],
      ),
      VaccineItem(
        id: 'vac_4',
        vaccineCode: 'TT_1',
        name: 'Tetanus Toxoid (टिटनेस)',
        targetAge: 'Early Pregnancy (गर्भावस्था में)',
        dueDate: now.toIso8601String().split('T')[0],
      ),
    ];
  }
}
