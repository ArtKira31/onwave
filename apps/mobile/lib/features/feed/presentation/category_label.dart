import 'package:mobile/core/l10n/app_localizations.dart';

/// Контракт отдаёт `nameKey` («category.concerts»), а переводы живут в мобилке.
/// Неизвестный slug (появился новый на бэке) → null, и карточка просто скрывает метку.
String? categoryLabel(AppLocalizations l10n, String? slug) => switch (slug) {
  'concerts' => l10n.categoryConcerts,
  'theatre' => l10n.categoryTheatre,
  'exhibitions' => l10n.categoryExhibitions,
  'sport' => l10n.categorySport,
  'parties' => l10n.categoryParties,
  'kids' => l10n.categoryKids,
  'education' => l10n.categoryEducation,
  'other' => l10n.categoryOther,
  _ => null,
};
