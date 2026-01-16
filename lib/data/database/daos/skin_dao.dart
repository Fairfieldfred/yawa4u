import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'skin_dao.g.dart';

/// Data Access Object for Skins table
@DriftAccessor(tables: [Skins])
class SkinDao extends DatabaseAccessor<AppDatabase> with _$SkinDaoMixin {
  SkinDao(super.db);

  /// Get all skins sorted by name
  Future<List<Skin>> getAllSorted() {
    return (select(skins)..orderBy([(s) => OrderingTerm.asc(s.name)])).get();
  }

  /// Watch all skins for reactive updates
  Stream<List<Skin>> watchAllSorted() {
    return (select(skins)..orderBy([(s) => OrderingTerm.asc(s.name)])).watch();
  }

  /// Get the active skin
  Future<Skin?> getActive() {
    return (select(
      skins,
    )..where((s) => s.isActive.equals(true))).getSingleOrNull();
  }

  /// Watch the active skin
  Stream<Skin?> watchActive() {
    return (select(
      skins,
    )..where((s) => s.isActive.equals(true))).watchSingleOrNull();
  }

  /// Get a skin by UUID
  Future<Skin?> getByUuid(String uuid) {
    return (select(skins)..where((s) => s.uuid.equals(uuid))).getSingleOrNull();
  }

  /// Get a skin by name
  Future<Skin?> getByName(String name) {
    return (select(skins)..where((s) => s.name.equals(name))).getSingleOrNull();
  }

  /// Insert a new skin
  Future<int> insertSkin(SkinsCompanion skin) {
    return into(skins).insert(skin);
  }

  /// Update an existing skin
  Future<bool> updateSkin(Skin skin) {
    return update(skins).replace(skin);
  }

  /// Set a skin as active (deactivates all others)
  Future<void> setActive(String uuid) async {
    await transaction(() async {
      // Deactivate all skins
      await (update(skins)).write(const SkinsCompanion(isActive: Value(false)));
      // Activate the selected skin
      await (update(skins)..where((s) => s.uuid.equals(uuid))).write(
        const SkinsCompanion(isActive: Value(true)),
      );
    });
  }

  /// Delete a skin by UUID
  Future<int> deleteByUuid(String uuid) {
    return (delete(skins)..where((s) => s.uuid.equals(uuid))).go();
  }

  /// Delete all skins
  Future<int> deleteAll() {
    return delete(skins).go();
  }
}
