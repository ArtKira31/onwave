// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'onwave';

  @override
  String get selectCity => 'Select City';

  @override
  String get feedTitle => 'Feed';

  @override
  String daysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String get retry => 'Retry';

  @override
  String get errorNetworkTitle => 'No internet connection';

  @override
  String get errorNetworkSubtitle => 'Check your connection and try again.';

  @override
  String get errorGenericTitle => 'Something went wrong';

  @override
  String get errorGenericSubtitle =>
      'Couldn\'t load the data. Please try again.';

  @override
  String get feedEmptyTitle => 'No events yet';

  @override
  String get feedEmptySubtitle =>
      'There are no events in this city for the current filter. Check back later or change the filter.';

  @override
  String get feedErrorTitle => 'Couldn\'t load the feed';

  @override
  String get feedErrorSubtitle =>
      'Check your internet connection and try again.';

  @override
  String get refresh => 'Refresh';

  @override
  String get offlineBanner => 'No internet connection';

  @override
  String staleBanner(String time) {
    return 'Data may be outdated · updated $time';
  }

  @override
  String get feedRefreshFailed => 'Couldn\'t refresh the feed';

  @override
  String get feedLoadMoreFailed => 'Couldn\'t load more';

  @override
  String get categoryConcerts => 'Concerts';

  @override
  String get categoryTheatre => 'Theatre';

  @override
  String get categoryExhibitions => 'Exhibitions';

  @override
  String get categorySport => 'Sport';

  @override
  String get categoryParties => 'Parties';

  @override
  String get categoryKids => 'Kids';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryOther => 'Other';

  @override
  String moreDates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count more dates',
      one: '+$count more date',
    );
    return '$_temp0';
  }
}
