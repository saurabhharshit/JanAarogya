import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/notifications/notification_service.dart';
import '../data/medicine_repository.dart';

class MedicineReminderScreen extends StatefulWidget {
  const MedicineReminderScreen({super.key});

  @override
  State<MedicineReminderScreen> createState() => _MedicineReminderScreenState();
}

class _MedicineReminderScreenState extends State<MedicineReminderScreen> {
  final MedicineRepository _repository = MedicineRepository();
  List<MedicineReminder> _reminders = [];

  final _medNameController = TextEditingController();
  final _dosageNoteController = TextEditingController();

  int _frequencyPerDay = 1;
  List<TimeOfDay> _selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];

  @override
  void initState() {
    super.initState();
    NotificationService.instance.init();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final list = await _repository.getActiveReminders();
    setState(() {
      _reminders = list;
    });
  }

  void _updateFrequency(int newFrequency) {
    setState(() {
      _frequencyPerDay = newFrequency;
      if (_selectedTimes.length < newFrequency) {
        // Add default times for extra doses (e.g. 8:00 AM, 2:00 PM, 8:00 PM)
        final defaultHours = [8, 14, 20];
        while (_selectedTimes.length < newFrequency) {
          final nextHour =
              defaultHours[_selectedTimes.length % defaultHours.length];
          _selectedTimes.add(TimeOfDay(hour: nextHour, minute: 0));
        }
      } else if (_selectedTimes.length > newFrequency) {
        _selectedTimes = _selectedTimes.sublist(0, newFrequency);
      }
    });
  }

  Future<void> _deleteMedicine(MedicineReminder reminder) async {
    await _repository.deleteMedicineReminder(reminder.id);
    for (int i = 0; i < reminder.reminderTimes.length; i++) {
      final alarmId = reminder.id.hashCode + i;
      await NotificationService.instance.cancelAlarm(alarmId);
    }
    _loadReminders();
  }

  Future<void> _showAddReminderDialog() async {
    _medNameController.clear();
    _dosageNoteController.clear();
    _frequencyPerDay = 1;
    _selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('नई दवा जोड़ें / Add Medicine'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _medNameController,
                  decoration: const InputDecoration(
                    labelText: 'दवा का नाम / Medicine Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _dosageNoteController,
                  decoration: const InputDecoration(
                    labelText:
                        'निर्देश / Instruction (e.g. 1 गोली खाने के बाद)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'दिन में कितनी बार? / Times Per Day:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<int>(
                  value: _frequencyPerDay,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [1, 2, 3, 4]
                      .map(
                        (freq) => DropdownMenuItem(
                          value: freq,
                          child: Text('$freq बार / $freq time(s) a day'),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        _frequencyPerDay = val;
                        if (_selectedTimes.length < val) {
                          final defaultHours = [8, 14, 20, 22];
                          while (_selectedTimes.length < val) {
                            final nextHour = defaultHours[
                                _selectedTimes.length % defaultHours.length];
                            _selectedTimes
                                .add(TimeOfDay(hour: nextHour, minute: 0));
                          }
                        } else if (_selectedTimes.length > val) {
                          _selectedTimes = _selectedTimes.sublist(0, val);
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'अलार्म समय चुनें / Select Alarm Timings:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Dynamic Time Pickers based on selected frequency
                ...List.generate(_frequencyPerDay, (index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      tileColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        radius: 14,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                      title: Text('खुराक ${index + 1} / Dose ${index + 1}'),
                      subtitle: Text(
                        _selectedTimes[index].format(context),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      trailing: const Icon(Icons.access_time,
                          color: AppColors.primary),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedTimes[index],
                        );
                        if (picked != null) {
                          setDialogState(() {
                            _selectedTimes[index] = picked;
                          });
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('रद्द करें / Cancel'),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                if (_medNameController.text.isNotEmpty) {
                  final formattedTimes = _selectedTimes
                      .map((t) =>
                          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
                      .toList();

                  final newReminder = MedicineReminder(
                    id: 'med_${DateTime.now().millisecondsSinceEpoch}',
                    medicineName: _medNameController.text.trim(),
                    dosageInstruction:
                        _dosageNoteController.text.trim().isNotEmpty
                            ? _dosageNoteController.text.trim()
                            : '1 खुराक',
                    frequencyPerDay: _frequencyPerDay,
                    reminderTimes: formattedTimes,
                    startDate: DateTime.now().toIso8601String().split('T')[0],
                  );

                  await _repository.addMedicineReminder(newReminder);

                  // Schedule Alarms for each time slot
                  for (int i = 0; i < _selectedTimes.length; i++) {
                    final time = _selectedTimes[i];
                    final alarmId = newReminder.id.hashCode + i;
                    await NotificationService.instance.scheduleMedicineAlarm(
                      id: alarmId,
                      title: 'दवा का समय! / Medicine Time!',
                      body:
                          '${newReminder.medicineName} लेने का समय हो गया है (${newReminder.dosageInstruction})',
                      hour: time.hour,
                      minute: time.minute,
                    );
                  }

                  if (!mounted) return;
                  Navigator.pop(context);
                  _loadReminders();
                }
              },
              child: const Text('सहेजें और अलार्म लगाएं / Save & Set Alarms',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('दवा रिमाइंडर / Medicine Reminders'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _reminders.isEmpty
          ? const Center(
              child: Text(
                'कोई दवा निर्धारित नहीं है\nNo active medicine reminders',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final item = _reminders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.accent,
                      child: Icon(Icons.medication, color: AppColors.primary),
                    ),
                    title: Text(
                      item.medicineName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                      '${item.dosageInstruction}\nदिन में ${item.frequencyPerDay} बार: ${item.reminderTimes.join(', ')}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.emergencyRed),
                      onPressed: () => _deleteMedicine(item),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showAddReminderDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
