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

  @override
  String get feedEmptyTitle => 'Событий пока нет';

  @override
  String get feedEmptySubtitle =>
      'В этом городе нет событий для выбранного фильтра. Загляните позже или измените фильтр.';

  @override
  String get feedErrorTitle => 'Не удалось загрузить ленту';

  @override
  String get feedErrorSubtitle =>
      'Проверьте подключение к интернету и попробуйте ещё раз.';

  @override
  String get refresh => 'Обновить';

  @override
  String get offlineBanner => 'Нет подключения к сети';

  @override
  String staleBanner(String time) {
    return 'Данные устарели · обновлено $time';
  }

  @override
  String get feedRefreshFailed => 'Не удалось обновить ленту';

  @override
  String get feedLoadMoreFailed => 'Не удалось загрузить ещё';

  @override
  String get categoryConcerts => 'Концерты';

  @override
  String get categoryTheatre => 'Театр';

  @override
  String get categoryExhibitions => 'Выставки';

  @override
  String get categorySport => 'Спорт';

  @override
  String get categoryParties => 'Вечеринки';

  @override
  String get categoryKids => 'Детям';

  @override
  String get categoryEducation => 'Образование';

  @override
  String get categoryOther => 'Другое';

  @override
  String moreDates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дат',
      few: '$count даты',
      one: '$count дата',
    );
    return 'и ещё $_temp0';
  }

  @override
  String get onboardingCityTitle => 'Выберите город';

  @override
  String get onboardingCitySubtitle =>
      'Покажем события рядом с вами. Регистрация не нужна.';

  @override
  String get citySearchHint => 'Поиск города';

  @override
  String get cityDetectAuto => 'Определить автоматически';

  @override
  String get cityDetecting => 'Определяем…';

  @override
  String get cityDetectExplanation =>
      'Найдём ближайший к вам город. Положение запрашивается один раз, только для этого, и никуда не отправляется.';

  @override
  String get cityDetectNoNearby =>
      'Рядом с вами пока нет доступных городов. Выберите город из списка.';

  @override
  String get cityDetectServicesOff =>
      'Геолокация выключена на устройстве. Включите её или выберите город из списка.';

  @override
  String get cityDetectDenied =>
      'Нет доступа к геолокации. Ничего страшного: выберите город из списка.';

  @override
  String get cityDetectDeniedForever =>
      'Доступ к геолокации запрещён в настройках. Выберите город из списка или разрешите доступ.';

  @override
  String get cityDetectOpenSettings => 'Открыть настройки';

  @override
  String get cityDetectUnavailable =>
      'Не удалось определить местоположение. Выберите город из списка.';

  @override
  String get citySearchEmptyTitle => 'Город не найден';

  @override
  String get citySearchEmptySubtitle =>
      'Проверьте название или выберите город из списка.';

  @override
  String get cityListErrorTitle => 'Не удалось загрузить города';

  @override
  String onboardingCityChosen(String city) {
    return 'Город: $city';
  }

  @override
  String get onboardingValueTitle => 'Всё интересное в вашем городе';

  @override
  String get onboardingValue1 =>
      'Концерты, театр, выставки и вечеринки в одной ленте';

  @override
  String get onboardingValue2 => 'Ближайшие даты и площадки без лишнего поиска';

  @override
  String get onboardingValue3 => 'Сохраняйте понравившееся в избранное';

  @override
  String get onboardingStart => 'В ленту';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get citySelectTitle => 'Выбор города';

  @override
  String get cityChange => 'Сменить город';

  @override
  String get profileCity => 'Город';
}
