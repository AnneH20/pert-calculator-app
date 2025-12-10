import 'package:flutter/material.dart';
import '../models/pert_row.dart';
import '../widgets/pert_section.dart';
import '../widgets/totals_section.dart';

class PertEstimatorPage extends StatefulWidget {
  const PertEstimatorPage({super.key});

  @override
  State<PertEstimatorPage> createState() => _PertEstimatorPageState();
}

class _PertEstimatorPageState extends State<PertEstimatorPage> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _mostLikelyKey = GlobalKey();
  final GlobalKey _pessimisticKey = GlobalKey();
  final GlobalKey _totalsKey = GlobalKey();

  List<PertRow> rows = [];
  int get rowCount => rows.length;

  @override
  void initState() {
    super.initState();
    rows = List.generate(5, (_) => PertRow());
  }

  @override
  void dispose() {
    for (final r in rows) {
      r.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  FocusNode? _getNextFocusNode(String currentSection, int currentIndex) {
    if (currentIndex < rows.length - 1) {
      switch (currentSection) {
        case 'optimistic':
          return rows[currentIndex + 1].optimisticFocus;
        case 'mostLikely':
          return rows[currentIndex + 1].mostLikelyFocus;
        case 'pessimistic':
          return rows[currentIndex + 1].pessimisticFocus;
      }
    } else {
      switch (currentSection) {
        case 'optimistic':
          return rows[0].mostLikelyFocus;
        case 'mostLikely':
          return rows[0].pessimisticFocus;
        case 'pessimistic':
          return null;
      }
    }
    return null;
  }

  double _averageOf(double Function(PertRow) getter) {
    final nonZero = rows.where((r) => getter(r) > 0).toList();
    if (nonZero.isEmpty) return 0.0;
    return nonZero.fold(0.0, (s, r) => s + getter(r)) / nonZero.length;
  }

  bool _sectionComplete(double Function(PertRow) getter) {
    return rows.every((r) => getter(r) > 0);
  }

  void _scrollToKey(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = key.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _checkAndScrollToNext(double Function(PertRow) getter, GlobalKey key) {
    if (_sectionComplete(getter)) {
      _scrollToKey(key);
    }
  }

  void _addRow() {
    setState(() {
      rows.add(PertRow());
    });
  }

  void _removeRow() {
    if (rows.length <= 1) return;
    setState(() {
      final removed = rows.removeLast();
      removed.dispose();
    });
  }

  void _resetAll() {
    setState(() {
      for (final r in rows) {
        r.optimistic = 0.0;
        r.mostLikely = 0.0;
        r.pessimistic = 0.0;
        r.optimisticCtrl.clear();
        r.mostLikelyCtrl.clear();
        r.pessimisticCtrl.clear();
      }
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('PERT Calculator'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildRowButtons(),
              const SizedBox(height: 24),
              PertSection(
                title: 'Optimistic',
                rows: rows,
                rowCount: rowCount,
                backgroundColor: Colors.green.shade200,
                valueGetter: (r) => r.optimistic,
                valueSetter: (r, v) => r.optimistic = v,
                controllerGetter: (r) => r.optimisticCtrl,
                focusNodeGetter: (r) => r.optimisticFocus,
                getNextFocusNode: (index) => _getNextFocusNode('optimistic', index),
                onComplete: () => _checkAndScrollToNext((r) => r.optimistic, _mostLikelyKey),
              ),
              const SizedBox(height: 24),
              PertSection(
                key: _mostLikelyKey,
                title: 'Most Likely',
                rows: rows,
                rowCount: rowCount,
                backgroundColor: Colors.blue.shade200,
                valueGetter: (r) => r.mostLikely,
                valueSetter: (r, v) => r.mostLikely = v,
                controllerGetter: (r) => r.mostLikelyCtrl,
                focusNodeGetter: (r) => r.mostLikelyFocus,
                getNextFocusNode: (index) => _getNextFocusNode('mostLikely', index),
                onComplete: () => _checkAndScrollToNext((r) => r.mostLikely, _pessimisticKey),
              ),
              const SizedBox(height: 24),
              PertSection(
                key: _pessimisticKey,
                title: 'Pessimistic',
                rows: rows,
                rowCount: rowCount,
                backgroundColor: Colors.red.shade200,
                valueGetter: (r) => r.pessimistic,
                valueSetter: (r, v) => r.pessimistic = v,
                controllerGetter: (r) => r.pessimisticCtrl,
                focusNodeGetter: (r) => r.pessimisticFocus,
                getNextFocusNode: (index) => _getNextFocusNode('pessimistic', index),
                onComplete: () => _checkAndScrollToNext((r) => r.pessimistic, _totalsKey),
              ),
              const SizedBox(height: 24),
              TotalsSection(
                key: _totalsKey,
                rows: rows,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _resetAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Reset All Values'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowButtons() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          onPressed: _addRow,
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Add Number'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        ElevatedButton.icon(
          onPressed: rows.length > 1 ? _removeRow : null,
          icon: const Icon(Icons.remove, size: 20),
          label: const Text('Remove Number'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade400,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }
}
