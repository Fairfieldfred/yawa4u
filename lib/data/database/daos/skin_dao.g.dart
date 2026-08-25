// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skin_dao.dart';

// ignore_for_file: type=lint
mixin _$SkinDaoMixin on DatabaseAccessor<AppDatabase> {
  $SkinsTable get skins => attachedDatabase.skins;
  SkinDaoManager get managers => SkinDaoManager(this);
}

class SkinDaoManager {
  final _$SkinDaoMixin _db;
  SkinDaoManager(this._db);
  $$SkinsTableTableManager get skins =>
      $$SkinsTableTableManager(_db.attachedDatabase, _db.skins);
}
