import 'package:flutter/widgets.dart';

class PertRow {
  double optimistic;
  double mostLikely;
  double pessimistic;

  final TextEditingController optimisticCtrl;
  final TextEditingController mostLikelyCtrl;
  final TextEditingController pessimisticCtrl;

  final FocusNode optimisticFocus;
  final FocusNode mostLikelyFocus;
  final FocusNode pessimisticFocus;

  PertRow({
    this.optimistic = 0.0,
    this.mostLikely = 0.0,
    this.pessimistic = 0.0,
    TextEditingController? optimisticCtrl,
    TextEditingController? mostLikelyCtrl,
    TextEditingController? pessimisticCtrl,
    FocusNode? optimisticFocus,
    FocusNode? mostLikelyFocus,
    FocusNode? pessimisticFocus,
  })  : optimisticCtrl = optimisticCtrl ?? TextEditingController(),
        mostLikelyCtrl = mostLikelyCtrl ?? TextEditingController(),
        pessimisticCtrl = pessimisticCtrl ?? TextEditingController(),
        optimisticFocus = optimisticFocus ?? FocusNode(),
        mostLikelyFocus = mostLikelyFocus ?? FocusNode(),
        pessimisticFocus = pessimisticFocus ?? FocusNode();

  void dispose() {
    optimisticCtrl.dispose();
    mostLikelyCtrl.dispose();
    pessimisticCtrl.dispose();
    optimisticFocus.dispose();
    mostLikelyFocus.dispose();
    pessimisticFocus.dispose();
  }
}
