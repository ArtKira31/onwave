import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'onwave'**
  String get appTitle;

  /// No description provided for @selectCity.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать город'**
  String get selectCity;

  /// No description provided for @feedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Лента'**
  String get feedTitle;

  /// Оставшиеся дни до события
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} день} few{{count} дня} other{{count} дней}}'**
  String daysRemaining(int count);

  /// Кнопка повтора
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @errorNetworkTitle.
  ///
  /// In ru, this message translates to:
  /// **'Нет подключения к сети'**
  String get errorNetworkTitle;

  /// No description provided for @errorNetworkSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте интернет и попробуйте ещё раз.'**
  String get errorNetworkSubtitle;

  /// No description provided for @errorGenericTitle.
  ///
  /// In ru, this message translates to:
  /// **'Что-то пошло не так'**
  String get errorGenericTitle;

  /// No description provided for @errorGenericSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить данные. Попробуйте ещё раз.'**
  String get errorGenericSubtitle;

  /// No description provided for @feedEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Событий пока нет'**
  String get feedEmptyTitle;

  /// No description provided for @feedEmptySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'В этом городе нет событий для выбранного фильтра. Загляните позже или измените фильтр.'**
  String get feedEmptySubtitle;

  /// No description provided for @feedErrorTitle.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить ленту'**
  String get feedErrorTitle;

  /// No description provided for @feedErrorSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте подключение к интернету и попробуйте ещё раз.'**
  String get feedErrorSubtitle;

  /// Кнопка обновления
  ///
  /// In ru, this message translates to:
  /// **'Обновить'**
  String get refresh;

  /// Офлайн-баннер
  ///
  /// In ru, this message translates to:
  /// **'Нет подключения к сети'**
  String get offlineBanner;

  /// Пометка, что показан кэш
  ///
  /// In ru, this message translates to:
  /// **'Данные устарели · обновлено {time}'**
  String staleBanner(String time);

  /// Снекбар при неудачном pull-to-refresh
  ///
  /// In ru, this message translates to:
  /// **'Не удалось обновить ленту'**
  String get feedRefreshFailed;

  /// Ошибка подгрузки следующей страницы
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить ещё'**
  String get feedLoadMoreFailed;

  /// No description provided for @categoryConcerts.
  ///
  /// In ru, this message translates to:
  /// **'Концерты'**
  String get categoryConcerts;

  /// No description provided for @categoryTheatre.
  ///
  /// In ru, this message translates to:
  /// **'Театр'**
  String get categoryTheatre;

  /// No description provided for @categoryExhibitions.
  ///
  /// In ru, this message translates to:
  /// **'Выставки'**
  String get categoryExhibitions;

  /// No description provided for @categorySport.
  ///
  /// In ru, this message translates to:
  /// **'Спорт'**
  String get categorySport;

  /// No description provided for @categoryParties.
  ///
  /// In ru, this message translates to:
  /// **'Вечеринки'**
  String get categoryParties;

  /// No description provided for @categoryKids.
  ///
  /// In ru, this message translates to:
  /// **'Детям'**
  String get categoryKids;

  /// No description provided for @categoryEducation.
  ///
  /// In ru, this message translates to:
  /// **'Образование'**
  String get categoryEducation;

  /// No description provided for @categoryOther.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get categoryOther;

  /// Дополнительные даты события
  ///
  /// In ru, this message translates to:
  /// **'и ещё {count, plural, one{{count} дата} few{{count} даты} other{{count} дат}}'**
  String moreDates(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
