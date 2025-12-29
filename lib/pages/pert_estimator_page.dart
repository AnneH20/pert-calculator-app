import 'package:flutter/material.dart';
import '../models/estimate_type.dart';
import '../models/pert_row.dart';
import '../widgets/pert_section.dart';
import '../widgets/totals_section.dart';

class PertEstimatorPage extends StatefulWidget {
  const PertEstimatorPage({super.key});

  @override
  State<PertEstimatorPage> createState() => PertEstimatorPageState();
}

class PertEstimatorPageState extends State<PertEstimatorPage> {
  static const int defaultRowCount = 5;

  final ScrollController scrollController = ScrollController();

  final GlobalKey mostLikelyKey = GlobalKey(debugLabel: 'mostLikelySection');
  final GlobalKey pessimisticKey = GlobalKey(debugLabel: 'pessimisticSection');
  final GlobalKey<TotalsSectionState> totalsKey = GlobalKey<TotalsSectionState>();

  List<PertRow> rows = [];

  @override
  void initState() {
    super.initState();
    rows = List.generate(defaultRowCount, (_) => PertRow());
  }

  @override
  void dispose() {
    for (final r in rows) {
      r.dispose();
    }
    scrollController.dispose();
    super.dispose();
  }

  FocusNode? getNextFocusNode(EstimateType currentSection, int currentIndex) {
    if (rows.isEmpty) return null;

    if (currentIndex < rows.length - 1) {
      switch (currentSection) {
        case EstimateType.optimistic:
          return rows[currentIndex + 1].optimisticFocus;
        case EstimateType.mostLikely:
          return rows[currentIndex + 1].mostLikelyFocus;
        case EstimateType.pessimistic:
          return rows[currentIndex + 1].pessimisticFocus;
      }
    } else {
      switch (currentSection) {
        case EstimateType.optimistic:
          return rows[0].mostLikelyFocus;
        case EstimateType.mostLikely:
          return rows[0].pessimisticFocus;
        case EstimateType.pessimistic:
          return null;
      }
    }
  }

  void scrollToKey(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = key.currentContext;
      if (context != null && mounted) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.0,
        );
      }
    });
  }

  void addRow() {
    setState(() {
      rows.add(PertRow());
    });
  }

  void removeRow() {
    if (rows.length <= 1) return;
    setState(() {
      final removed = rows.removeLast();
      removed.dispose();
    });
  }

  void resetAll() {
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
    totalsKey.currentState?.clearResults();

    FocusScope.of(context).unfocus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
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
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildRowButtons(),
              const SizedBox(height: 24),
              PertSection(
                title: 'Optimistic',
                rows: rows,
                backgroundColor: Colors.green.shade200,
                valueGetter: (r) => r.optimistic,
                valueSetter: (r, v) {
                  setState(() {
                    r.optimistic = v;
                  });
                },
                controllerGetter: (r) => r.optimisticCtrl,
                focusNodeGetter: (r) => r.optimisticFocus,
                getNextFocusNode: (index) => getNextFocusNode(EstimateType.optimistic, index),
                onSectionComplete: () => scrollToKey(mostLikelyKey),
              ),
              const SizedBox(height: 24),
              PertSection(
                key: mostLikelyKey,
                title: 'Most Likely',
                rows: rows,
                backgroundColor: Colors.blue.shade200,
                valueGetter: (r) => r.mostLikely,
                valueSetter: (r, v) {
                  setState(() {
                    r.mostLikely = v;
                  });
                },
                controllerGetter: (r) => r.mostLikelyCtrl,
                focusNodeGetter: (r) => r.mostLikelyFocus,
                getNextFocusNode: (index) => getNextFocusNode(EstimateType.mostLikely, index),
                onSectionComplete: () => scrollToKey(pessimisticKey),
              ),
              const SizedBox(height: 24),
              PertSection(
                key: pessimisticKey,
                title: 'Pessimistic',
                rows: rows,
                backgroundColor: Colors.red.shade200,
                valueGetter: (r) => r.pessimistic,
                valueSetter: (r, v) {
                  setState(() {
                    r.pessimistic = v;
                  });
                },
                controllerGetter: (r) => r.pessimisticCtrl,
                focusNodeGetter: (r) => r.pessimisticFocus,
                getNextFocusNode: (index) => getNextFocusNode(EstimateType.pessimistic, index),
                onSectionComplete: () => scrollToKey(totalsKey),
              ),
              const SizedBox(height: 24),
              TotalsSection(
                key: totalsKey,
                rows: rows,
                onCalculate: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    scrollController.animateTo(
                      scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  });
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: resetAll,
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

  Widget buildRowButtons() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          onPressed: addRow,
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Add Number'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        ElevatedButton.icon(
          onPressed: rows.length > 1 ? removeRow : null,
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
