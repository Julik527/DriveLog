String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}

String formatDateShort(DateTime? date) {
  if (date == null) return 'nicht eingetragen';
  return formatDate(date);
}

bool isDueSoon(DateTime? date, {int days = 60}) {
  if (date == null) return false;
  final now = DateTime.now();
  return date.isAfter(now) && date.difference(now).inDays <= days;
}

bool isOverdue(DateTime? date) {
  if (date == null) return false;
  return date.isBefore(DateTime.now());
}
