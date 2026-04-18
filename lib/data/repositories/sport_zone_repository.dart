import '../../core/constants/sports.dart';
import '../database/daos/sport_zone_dao.dart';
import '../database/mappers/session_mappers.dart';
import '../models/sport_zone.dart';

/// Repository for user-configured HR / pace / power zones per sport.
class SportZoneRepository {
  final SportZoneDao _dao;

  SportZoneRepository(this._dao);

  Future<List<SportZone>> getBySport(Sport sport) async {
    final rows = await _dao.getBySport(sport.index);
    return rows.map(SportZoneMapper.fromRow).toList();
  }

  Stream<List<SportZone>> watchBySport(Sport sport) {
    return _dao.watchBySport(sport.index).map(
      (rows) => rows.map(SportZoneMapper.fromRow).toList(),
    );
  }

  Future<List<SportZone>> getAll() async {
    final rows = await _dao.getAll();
    return rows.map(SportZoneMapper.fromRow).toList();
  }

  Future<void> create(SportZone zone) async {
    await _dao.insertZone(SportZoneMapper.toCompanion(zone));
  }

  Future<void> replaceAllForSport(Sport sport, List<SportZone> zones) async {
    await _dao.deleteBySport(sport.index);
    if (zones.isEmpty) return;
    await _dao.insertAll(zones.map(SportZoneMapper.toCompanion).toList());
  }

  Future<void> update(SportZone zone) async {
    await _dao.updateByUuid(zone.id, SportZoneMapper.toCompanion(zone));
  }

  Future<void> delete(String id) async {
    await _dao.deleteByUuid(id);
  }

  /// Return the zone number (1..5) for [value] within the given [sport].
  /// Returns null if no zones are configured or the value is outside every
  /// zone's range.
  Future<int?> zoneFor(Sport sport, double value) async {
    final zones = await getBySport(sport);
    if (zones.isEmpty) return null;
    for (final z in zones) {
      if (z.contains(value)) return z.zoneNumber;
    }
    return null;
  }
}
