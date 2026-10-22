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

  @override
  String get onboardingCityTitle => 'Choose your city';

  @override
  String get onboardingCitySubtitle =>
      'We\'ll show events near you. No sign-up needed.';

  @override
  String get citySearchHint => 'Search city';

  @override
  String get cityDetectAuto => 'Detect automatically';

  @override
  String get cityDetecting => 'Detecting…';

  @override
  String get cityDetectExplanation =>
      'We\'ll find the nearest city. Your location is requested once, only for this, and is never sent anywhere.';

  @override
  String get cityDetectNoNearby =>
      'There are no available cities near you yet. Pick a city from the list.';

  @override
  String get cityDetectServicesOff =>
      'Location is turned off on this device. Turn it on or pick a city from the list.';

  @override
  String get cityDetectDenied =>
      'No access to location. No problem: pick a city from the list.';

  @override
  String get cityDetectDeniedForever =>
      'Location access is blocked in settings. Pick a city from the list or allow access.';

  @override
  String get cityDetectOpenSettings => 'Open settings';

  @override
  String get cityDetectUnavailable =>
      'Couldn\'t determine your location. Pick a city from the list.';

  @override
  String get citySearchEmptyTitle => 'City not found';

  @override
  String get citySearchEmptySubtitle =>
      'Check the name or pick a city from the list.';

  @override
  String get cityListErrorTitle => 'Couldn\'t load cities';

  @override
  String onboardingCityChosen(String city) {
    return 'City: $city';
  }

  @override
  String get onboardingValueTitle => 'Everything happening in your city';

  @override
  String get onboardingValue1 =>
      'Concerts, theatre, exhibitions and parties in one feed';

  @override
  String get onboardingValue2 => 'Upcoming dates and venues without the search';

  @override
  String get onboardingValue3 => 'Save what you like to favorites';

  @override
  String get onboardingStart => 'Open the feed';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get citySelectTitle => 'Choose city';

  @override
  String get cityChange => 'Change city';

  @override
  String get profileCity => 'City';
}
