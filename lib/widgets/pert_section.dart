import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/pert_row.dart';

class PertSection extends StatelessWidget {
  final String title;
  final List<PertRow> rows;
  final int rowCount;
  final Color backgroundColor;
  final void Function()? onComplete;
  final void Function()? onSectionComplete;

  final double Function(PertRow) valueGetter;

  final void Function(PertRow, double) valueSetter;

  final TextEditingController Function(PertRow) controllerGetter;

  final FocusNode Function(PertRow) focusNodeGetter;

  final FocusNode? Function(int)? getNextFocusNode;

  const PertSection({
    super.key,
    required this.title,
    required this.rows,
    required this.rowCount,
    required this.backgroundColor,
    required this.valueGetter,
    required this.valueSetter,
    required this.controllerGetter,
    required this.focusNodeGetter,
    this.getNextFocusNode,
    this.onComplete,
    this.onSectionComplete,
  });

  double _total() => rows.fold(0.0, (s, r) => s + valueGetter(r));

  double _average() {
    final nonZero = rows.where((r) => valueGetter(r) > 0).toList();
    if (nonZero.isEmpty) return 0.0;
    final total = nonZero.fold(0.0, (s, r) => s + valueGetter(r));
    return total / nonZero.length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(rowCount, (i) => _buildTextField(context, i)),
          const Divider(height: 24, thickness: 2, color: Colors.black),
          _buildRow('Total:', _total()),
          _buildRow('Average:', _average()),
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context, int index) {
    final row = rows[index];
    final controller = controllerGetter(row);
    final focusNode = focusNodeGetter(row);

    if (controller.text.isEmpty && valueGetter(row) > 0) {
      controller.text = valueGetter(row).toString();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Center(
        child: SizedBox(
          width: 150,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: const InputDecoration(
              hintText: '0',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              final parsed = double.tryParse(value) ?? 0.0;
              valueSetter(row, parsed);
            },
            onSubmitted: (_) {
              final nextFocus = getNextFocusNode?.call(index);
              if (nextFocus != null) {
                nextFocus.requestFocus();
                if (index == rows.length - 1) {
                  onSectionComplete?.call();
                }
              } else {
                FocusScope.of(context).unfocus();
              }
              onComplete?.call();
            },
            onTapOutside: (_) {
              FocusScope.of(context).unfocus();
              onComplete?.call();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Text(
              value.toStringAsFixed(2),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
