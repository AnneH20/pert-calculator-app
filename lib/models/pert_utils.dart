import 'pert_row.dart';

double calculateAverage(List<PertRow> rows, double Function(PertRow) getter) {
  final nonZero = rows.where((r) => getter(r) > 0).toList();
  if (nonZero.isEmpty) return 0.0;
  final total = nonZero.fold(0.0, (s, r) => s + getter(r));
  return total / nonZero.length;
}
