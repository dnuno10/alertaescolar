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
      return '$hour12:${minute.toString().padLeft(2, '0')} $suffix';
    } catch (e) {
      return time24;
    }
  }

  /// Parsea una fecha de Supabase (que puede incluir timezone) a DateTime local
  static DateTime parseSupabaseDateTime(String dateTimeString) {
    try {
      // Si ya es un DateTime válido con zona horaria, parsearlo directamente
      final parsed = DateTime.parse(dateTimeString);

      // Si es UTC, convertir a hora local
      if (parsed.isUtc) {
        return parsed.toLocal();
      }

      // Si no tiene información de timezone, asumir que es local
      return parsed;
    } catch (e) {
      // Fallback: retornar fecha actual si hay error
      return DateTime.now();
    }
  }

  /// Convierte un DateTime a formato de hora AM/PM usando la zona horaria local
  static String formatDateTimeToAmPm(DateTime dateTime) {
    final localDateTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    final timeString =
        '${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}';
    return format24to12(timeString);
  }

  /// Obtiene el rango UTC para un día específico desde la perspectiva local
  static ({DateTime startUtc, DateTime endUtc}) getDayUtcRangeFromLocal(
      [DateTime? date]) {
    final targetDate = date ?? DateTime.now();
    final startOfDayLocal =
        DateTime(targetDate.year, targetDate.month, targetDate.day);
    final endOfDayLocal = startOfDayLocal.add(const Duration(days: 1));
    return (startUtc: startOfDayLocal.toUtc(), endUtc: endOfDayLocal.toUtc());
  }
}
