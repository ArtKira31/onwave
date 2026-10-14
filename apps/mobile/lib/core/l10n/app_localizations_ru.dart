// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'onwave';

  @override
  String get selectCity => 'Выбрать город';

  @override
  String get feedTitle => 'Лента';

  @override
  String daysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return '$_temp0';
  }

  @override
  String get retry => 'Повторить';

  @override
  String get errorNetworkTitle => 'Нет подключения к сети';

  @override
  String get errorNetworkSubtitle => 'Проверьте интернет и попробуйте ещё раз.';

  @override
  String get errorGenericTitle => 'Что-то пошло не так';

  @override
  String get errorGenericSubtitle =>
      'Не удалось загрузить данные. Попробуйте ещё раз.';
}
