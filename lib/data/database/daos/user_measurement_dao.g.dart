// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_measurement_dao.dart';

// ignore_for_file: type=lint
mixin _$UserMeasurementDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserMeasurementsTable get userMeasurements =>
      attachedDatabase.userMeasurements;
  UserMeasurementDaoManager get managers => UserMeasurementDaoManager(this);
}

class UserMeasurementDaoManager {
  final _$UserMeasurementDaoMixin _db;
  UserMeasurementDaoManager(this._db);
  $$UserMeasurementsTableTableManager get userMeasurements =>
      $$UserMeasurementsTableTableManager(
        _db.attachedDatabase,
        _db.userMeasurements,
      );
}
