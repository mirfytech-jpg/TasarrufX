import 'package:intl/intl.dart';

class TLFormatter {
  static final _fmt = NumberFormat('#,##0.##', 'tr_TR');

  static String format(double value) {
    return '₺${_fmt.format(value)}';
  }

  static String compact(double value) {
    final abs = value.abs();
    if (abs >= 1e9) return '₺${(value / 1e9).toStringAsFixed(2)} Milyar';
    if (abs >= 1e6) return '₺${(value / 1e6).toStringAsFixed(2)} Milyon';
    if (abs >= 1000) return '₺${(value / 1000).toStringAsFixed(1)}K';
    return format(value);
  }
}
