import 'package:flutter/material.dart';
import '../models/pert_row.dart';

class TotalsSection extends StatelessWidget {
  final List<PertRow> rows;

  const TotalsSection({super.key, required this.rows});

  double _averageOf(double Function(PertRow) getter) {
    final nonZero = rows.where((r) => getter(r) > 0).toList();
    if (nonZero.isEmpty) return 0.0;
    final total = nonZero.fold(0.0, (s, r) => s + getter(r));
    return total / nonZero.length;
  }

  @override
  Widget build(BuildContext context) {
    final optimistic = _averageOf((r) => r.optimistic);
    final mostLikely = _averageOf((r) => r.mostLikely);
    final pessimistic = _averageOf((r) => r.pessimistic);

    final pert = (optimistic + 4 * mostLikely + pessimistic) / 6;
    final pertRounded = pert.ceilToDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Totals',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTotalRow('Optimistic Average:', optimistic),
          _buildTotalRow('Most Likely Average:', mostLikely),
          _buildTotalRow('Pessimistic Average:', pessimistic),
          const Divider(height: 24, thickness: 2),
          _buildTotalRow('PERT Estimate:', pertRounded),
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
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value.toStringAsFixed(2), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
