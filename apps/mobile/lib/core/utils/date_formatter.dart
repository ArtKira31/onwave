import 'package:intl/intl.dart';

class AppDateFormatter {
  /// Форматирует дату события с учетом текущего языка (локали) приложения
  static String formatEventDate(DateTime dateTime, String locale) {
    // Шаблон: "25 октября, 15:30" для ru или "October 25, 3:30 PM" для en
    final DateFormat formatter = DateFormat.MMMMd(locale).add_Hm();
    return formatter.format(dateTime);
  }
}
