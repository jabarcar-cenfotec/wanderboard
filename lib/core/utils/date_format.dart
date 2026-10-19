const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// "14 March 2025" — used for handwritten visit dates.
String formatVisitDate(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';

/// "Mar 2025" — compact variant for polaroid strips.
String formatShortDate(DateTime date) =>
    '${_months[date.month - 1].substring(0, 3)} ${date.year}';
