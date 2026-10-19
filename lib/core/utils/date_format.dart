const _months = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// "14 de marzo de 2025" — used for handwritten visit dates.
String formatVisitDate(DateTime date) =>
    '${date.day} de ${_months[date.month - 1]} de ${date.year}';

/// "mar 2025" — compact variant for polaroid strips.
String formatShortDate(DateTime date) =>
    '${_months[date.month - 1].substring(0, 3)} ${date.year}';
