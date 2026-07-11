// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_zone_dao.dart';

// ignore_for_file: type=lint
mixin _$SportZoneDaoMixin on DatabaseAccessor<AppDatabase> {
  $SportZonesTable get sportZones => attachedDatabase.sportZones;
  SportZoneDaoManager get managers => SportZoneDaoManager(this);
}

class SportZoneDaoManager {
  final _$SportZoneDaoMixin _db;
  SportZoneDaoManager(this._db);
  $$SportZonesTableTableManager get sportZones => $$SportZonesTableTableManager(_db.attachedDatabase, _db.sportZones);
}
