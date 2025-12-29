import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/holidays_config.dart';
import '../models/pert_row.dart';
import '../models/pert_utils.dart';

class TotalsSection extends StatefulWidget {
  final List<PertRow> rows;
  final VoidCallback? onCalculate;

  const TotalsSection({super.key, required this.rows, this.onCalculate});

  @override
  State<TotalsSection> createState() => TotalsSectionState();
}

class TotalsSectionState extends State<TotalsSection> {
  static const int maxBusinessDays = 1000;
  static final DateFormat dateFormatter = DateFormat('EEEE, MMMM d, y');

  String? includingDayResult;
  String? nextDayResult;

  void clearResults() {
    setState(() {
      includingDayResult = null;
      nextDayResult = null;
    });
  }

  List<DateTime> get holidays => HolidaysConfig.holidays;

  double averageOf(double Function(PertRow) getter) =>
      calculateAverage(widget.rows, getter);

  DateTime addBusinessDays(DateTime startDate, int businessDays, bool includeToday) {
    DateTime current = startDate;
    int daysToAdd = businessDays;

    if (includeToday && isBusinessDay(current) && !isHoliday(current)) {
      daysToAdd--;
    }

    while (daysToAdd > 0) {
      current = current.add(const Duration(days: 1));
      if (isBusinessDay(current) && !isHoliday(current)) {
        daysToAdd--;
      }
    }

    return current;
  }

  bool isBusinessDay(DateTime date) {
    return date.weekday >= DateTime.monday && date.weekday <= DateTime.friday;
  }

  bool isHoliday(DateTime date) {
    return holidays.any((holiday) =>
        holiday.year == date.year &&
        holiday.month == date.month &&
        holiday.day == date.day);
  }

  void calculateCommitmentDates(int pertEstimate) {
    if (pertEstimate <= 0) {
      setState(() {
        includingDayResult = 'Invalid estimate';
        nextDayResult = 'Invalid estimate';
      });
      return;
    }

    if (pertEstimate > maxBusinessDays) {
      setState(() {
        includingDayResult = 'Estimate too large (max $maxBusinessDays days)';
        nextDayResult = 'Estimate too large (max $maxBusinessDays days)';
      });
      return;
    }

    final today = DateTime.now();
    final includingDate = addBusinessDays(today, pertEstimate, true);
    final nextDayDate = addBusinessDays(today, pertEstimate, false);

    setState(() {
      includingDayResult = dateFormatter.format(includingDate);
      nextDayResult = dateFormatter.format(nextDayDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final optimistic = averageOf((r) => r.optimistic);
    final mostLikely = averageOf((r) => r.mostLikely);
    final pessimistic = averageOf((r) => r.pessimistic);

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
          buildTotalRow('Optimistic Average:', optimistic),
          buildTotalRow('Most Likely Average:', mostLikely),
          buildTotalRow('Pessimistic Average:', pessimistic),
          const Divider(height: 24, thickness: 2, color: Colors.black),
          buildTotalRow('PERT Estimate:', pertRounded),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: pertInt > 0
                  ? () {
                      calculateCommitmentDates(pertInt);
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
          if (includingDayResult != null && nextDayResult != null) ...[
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildResultCard('Starting Today:', includingDayResult!, Colors.blue),
                const SizedBox(height: 12),
                buildResultCard('Starting Next Business Day:', nextDayResult!, Colors.green),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget buildTotalRow(String label, double value) {
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

  Widget buildResultCard(String title, String result, MaterialColor color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            result,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
