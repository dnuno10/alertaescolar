class TimeFormat {
  /// Convierte una hora en formato 'HH:mm' (24 horas) a 'h:mm a' (AM/PM)
  static String format24to12(String time24) {
    if (time24.isEmpty) return '';
    // Si ya contiene AM o PM, retorna tal cual
    if (time24.toUpperCase().contains('AM') ||
        time24.toUpperCase().contains('PM')) {
      return time24;
    }
    try {
      final parts = time24.split(':');
      if (parts.length < 2) return time24;
      final hourStr = parts[0].replaceAll(RegExp(r'[^0-9]'), '');
      final minuteStr = parts[1].replaceAll(RegExp(r'[^0-9]'), '');
      if (hourStr.isEmpty || minuteStr.isEmpty) return time24;
      int hour = int.parse(hourStr);
      int minute = int.parse(minuteStr);
      final suffix = hour < 12 ? 'AM' : 'PM';
      int hour12 = hour % 12;
      if (hour12 == 0) hour12 = 12;
      return '${hour12}:${minute.toString().padLeft(2, '0')} $suffix';
    } catch (e) {
      return time24;
    }
  }
}
