// lib/views/cash/cash_entry_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory_management_app/Controller/cash_controller.dart';


class CashEntryScreen extends StatefulWidget {
  final bool initialIsCashIn; // true = Cash In, false = Cash Out
  const CashEntryScreen({super.key, required this.initialIsCashIn});

  @override
  State<CashEntryScreen> createState() => _CashEntryScreenState();
}

class _CashEntryScreenState extends State<CashEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  late bool _isCashIn;
  DateTime _when = DateTime.now();

  final CashController controller = Get.find<CashController>();

  @override
  void initState() {
    super.initState();
    _isCashIn = widget.initialIsCashIn;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  String get _title => _isCashIn ? 'Cash In' : 'Cash Out';

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) {
      setState(() {
        _when = DateTime(d.year, d.month, d.day, _when.hour, _when.minute);
      });
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_when));
    if (t != null) {
      setState(() {
        _when = DateTime(_when.year, _when.month, _when.day, t.hour, t.minute);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountCtrl.text.trim());
    final note = _noteCtrl.text.trim();
    await controller.addEntry(amount: amount, isCashIn: _isCashIn, note: note, when: _when);
    Get.back();
    Get.snackbar('Saved', 'Entry added successfully',
        snackPosition: SnackPosition.BOTTOM);
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd-MM-yyyy');
    final tf = DateFormat('hh:mm a');
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Toggle (Cash In / Cash Out)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _isCashIn = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isCashIn ? const Color(0xFF0E2244) : Colors.white,
                        foregroundColor: _isCashIn ? Colors.white : const Color(0xFF0E2244),
                        side: const BorderSide(color: Color(0xFF0E2244)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cash In', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _isCashIn = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !_isCashIn ? const Color(0xFF0E2244) : Colors.white,
                        foregroundColor: !_isCashIn ? Colors.white : const Color(0xFF0E2244),
                        side: const BorderSide(color: Color(0xFF0E2244)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cash Out', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: _title,
                  hintText: 'Enter amount',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Amount is required';
                  final n = double.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Notes
              TextFormField(
                controller: _noteCtrl,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Add a note (optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Date & Time
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: InkWell(
                        onTap: _pickDate,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(df.format(_when)),
                              const Icon(Icons.calendar_today_outlined, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: InkWell(
                        onTap: _pickTime,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(tf.format(_when)),
                              const Icon(Icons.access_time_outlined, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Save
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E2244),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
