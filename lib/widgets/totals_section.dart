import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pert_row.dart';

class TotalsSection extends StatefulWidget {
  final List<PertRow> rows;
  final VoidCallback? onCalculate;

  const TotalsSection({super.key, required this.rows, this.onCalculate});

  @override
  State<TotalsSection> createState() => _TotalsSectionState();
}

class _TotalsSectionState extends State<TotalsSection> {
  String? _includingDayResult;
  String? _nextDayResult;

  void clearResults() {
    setState(() {
      _includingDayResult = null;
      _nextDayResult = null;
    });
  }

  // List of Ramsey Solutions holidays to exclude from PERT date calculations
  final List<DateTime> _holidays = [
    DateTime(2025, 12, 24), // Christmas Eve 2025
    DateTime(2025, 12, 25), // Christmas Day 2025
    DateTime(2025, 12, 26), // Christmas Celebration 2025
    DateTime(2026, 1, 1),   // New Year's Day 2026
    DateTime(2026, 1, 2),   // New Year's Day Celebration 2026
    DateTime(2026, 4, 3), // Good Friday 2026
    DateTime(2026, 5, 25), // Memorial Day 2026
    DateTime(2026, 7, 3), // Independence Day Celebration 2026
    DateTime(2026, 9, 7), // Labor Day 2026
    DateTime(2026, 11, 26), // Thanksgiving Day 2026
    DateTime(2026, 11, 27), // Day After Thanksgiving 2026
    DateTime(2026, 12, 24), // Christmas Eve 2026
    DateTime(2026, 12, 25), // Christmas Day 2026
    DateTime(2026, 12, 31), // New Year's Eve 2026
    DateTime(2027, 1, 1), // New Year's Day 2027
  ];

  double _averageOf(double Function(PertRow) getter) {
    final nonZero = widget.rows.where((r) => getter(r) > 0).toList();
    if (nonZero.isEmpty) return 0.0;
    final total = nonZero.fold(0.0, (s, r) => s + getter(r));
    return total / nonZero.length;
  }

  DateTime _addBusinessDays(DateTime startDate, int businessDays, bool includeToday) {
    DateTime current = startDate;
    int daysToAdd = businessDays;

    if (includeToday && _isBusinessDay(current) && !_isHoliday(current)) {
      daysToAdd--;
    }

    while (daysToAdd > 0) {
      current = current.add(const Duration(days: 1));
      if (_isBusinessDay(current) && !_isHoliday(current)) {
        daysToAdd--;
      }
    }

    return current;
  }

  bool _isBusinessDay(DateTime date) {
    return date.weekday >= DateTime.monday && date.weekday <= DateTime.friday;
  }

  bool _isHoliday(DateTime date) {
    return _holidays.any((holiday) =>
        holiday.year == date.year &&
        holiday.month == date.month &&
        holiday.day == date.day);
  }

  void _calculateIncludingDay(int pertEstimate) {
    if (pertEstimate <= 0) {
      setState(() {
        _includingDayResult = 'Invalid estimate';
      });
      return;
    }

    final today = DateTime.now();
    final resultDate = _addBusinessDays(today, pertEstimate, true);
    final formatter = DateFormat('EEEE, MMMM d, y');

    setState(() {
      _includingDayResult = formatter.format(resultDate);
    });
  }

  void _calculateNextDay(int pertEstimate) {
    if (pertEstimate <= 0) {
      setState(() {
        _nextDayResult = 'Invalid estimate';
      });
      return;
    }

    final today = DateTime.now();
    final resultDate = _addBusinessDays(today, pertEstimate, false);
    final formatter = DateFormat('EEEE, MMMM d, y');

    setState(() {
      _nextDayResult = formatter.format(resultDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final optimistic = _averageOf((r) => r.optimistic);
    final mostLikely = _averageOf((r) => r.mostLikely);
    final pessimistic = _averageOf((r) => r.pessimistic);

    final pert = (optimistic + 4 * mostLikely + pessimistic) / 6;
    final pertRounded = pert.ceilToDouble();
    final pertInt = pertRounded.toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Total',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTotalRow('Optimistic Average:', optimistic),
          _buildTotalRow('Most Likely Average:', mostLikely),
          _buildTotalRow('Pessimistic Average:', pessimistic),
          const Divider(height: 24, thickness: 2, color: Colors.black),
          _buildTotalRow('PERT Estimate:', pertRounded),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: pertInt > 0
                  ? () {
                      _calculateIncludingDay(pertInt);
                      _calculateNextDay(pertInt);
                      widget.onCalculate?.call();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Calculate Commitment Date',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          if (_includingDayResult != null && _nextDayResult != null) ...[
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Including Today:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _includingDayResult!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Starting Next Day:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _nextDayResult!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value.toStringAsFixed(2),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
