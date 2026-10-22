/// Город для выбора. Доменная модель: про DTO из `lib/api` знает только
/// репозиторий.
class CityOption {
  final String id;

  /// Идентификатор для API (`GET /events?city=slug`) и ключ в `cityProvider`.
  final String slug;
  final String name;

  /// Координаты центра города. В контракте необязательные.
  final double? lat;
  final double? lon;

  const CityOption({
    required this.id,
    required this.slug,
    required this.name,
    this.lat,
    this.lon,
  });

  bool get hasCoordinates => lat != null && lon != null;
}
