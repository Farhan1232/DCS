// lib/views/cash/cash_book_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory_management_app/Controller/cash_controller.dart';
import 'package:inventory_management_app/views/cashbook/cask_entry_screen.dart';


class CashBookScreen extends StatelessWidget {

   final CashController controller = Get.put(CashController());
   CashBookScreen({super.key});

  Color get _navy => const Color(0xFF0E2244);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CashController>();
    final df = DateFormat('dd-MM-yyyy  hh:mm a');

    return Scaffold(
      appBar: AppBar(title: const Text('Cash Book')),
      body: Obx(() {
        final totalIn = controller.totalIn;
        final totalOut = controller.totalOut;
        final balance = controller.balance;
        final data = controller.filtered;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Summary cards
              Row(
                children: [
                  _SummaryCard(
                    label: 'Total Cash In',
                    value: totalIn,
                    valueColor: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _SummaryCard(
                    label: 'Total Cash Out',
                    value: totalOut,
                    valueColor: Colors.red,
                  ),
                  const SizedBox(width: 12),
                  _SummaryCard(
                    label: 'Balance',
                    value: balance,
                    valueColor: Colors.black87,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Filters
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChipItem(period: FilterPeriod.all, label: 'All'),
                    _FilterChipItem(period: FilterPeriod.today, label: 'Today'),
                    _FilterChipItem(period: FilterPeriod.weekly, label: 'Weekly'),
                    _FilterChipItem(period: FilterPeriod.monthly, label: 'Monthly'),
                    _FilterChipItem(period: FilterPeriod.yearly, label: 'Yearly'),
                  ].expand((w) sync* {
                    yield w;
                    yield const SizedBox(width: 10);
                  }).toList()
                    ..removeLast(),
                ),
              ),
              const SizedBox(height: 8),

              // Header row like "Date  Cash In  Cash Out"
              Row(
                children: const [
                  Expanded(
                    child: Text('Date', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(width: 8),
                  SizedBox(width: 80, child: Text('Cash In', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w600))),
                  SizedBox(width: 16),
                  SizedBox(width: 80, child: Text('Cash Out', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w600))),
                ],
              ),
              const SizedBox(height: 8),

              // List
              Expanded(
                child: ListView.separated(
                  itemCount: data.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final e = data[i];
                    final isIn = e.type == 'in';
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ],
                        border: Border.all(color: Colors.black12),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left: note + date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (e.note.isEmpty ? '(no note)' : e.note),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  df.format(e.timestamp),
                                  style: TextStyle(color: Colors.black.withOpacity(0.6)),
                                ),
                              ],
                            ),
                          ),
                          // Right: amounts columns
                          SizedBox(
                            width: 80,
                            child: Text(
                              isIn ? e.amount.toStringAsFixed(0) : '',
                              textAlign: TextAlign.right,
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 80,
                            child: Text(
                              !isIn ? e.amount.toStringAsFixed(0) : '',
                              textAlign: TextAlign.right,
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
      // Bottom two big buttons
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 6, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => Get.to(() => const CashEntryScreen(initialIsCashIn: true)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Cash In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Get.to(() => const CashEntryScreen(initialIsCashIn: false)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Cash Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF7F7FB),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double value;
  final Color valueColor;
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value.toStringAsFixed(0),
                style: TextStyle(
                  color: valueColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                )),
            const Spacer(),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final FilterPeriod period;
  final String label;
  const _FilterChipItem({required this.period, required this.label});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CashController>();
    return Obx(() {
      final selected = c.filter.value == period;
      return ChoiceChip(
        selected: selected,
        label: Text(label),
        onSelected: (_) => c.filter.value = period,
        labelStyle: TextStyle(
          color: selected ? Colors.white : const Color(0xFF0E2244),
          fontWeight: FontWeight.w600,
        ),
        selectedColor: const Color(0xFF0E2244),
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF0E2244)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );
    });
  }
}
