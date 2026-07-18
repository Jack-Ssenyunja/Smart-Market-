import 'package:intl/intl.dart';

String formatUGX(double amount) {
  final formatter = NumberFormat('#,###', 'en_US');
  return 'UGX ${formatter.format(amount.toInt())}';
}

String relativeTime(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return DateFormat('d MMM').format(date);
}

String formatDate(DateTime date) => DateFormat('d MMM yyyy').format(date);

String formatPhoneUG(String phone) {
  String p = phone.replaceAll(RegExp(r'\s'), '');
  if (!p.startsWith('+')) {
    p = p.startsWith('0') ? '+256${p.substring(1)}' : '+256$p';
  }
  return p;
}
