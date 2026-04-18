import '../database/daos/cycle_period_dao.dart';
import '../database/mappers/session_mappers.dart';
import '../models/cycle_period.dart';

/// Repository for cardio periodization phases per training cycle.
///
/// Every training cycle has one [CyclePeriod] row per period (created by
/// the v5 backfill). Strength-only cycles usually leave `phase` null;
/// cardio or mixed cycles set one of the [TrainingPhase] values per period.
class CyclePeriodRepository {
  final CyclePeriodDao _dao;

  CyclePeriodRepository(this._dao);

  Future<List<CyclePeriod>> getByTrainingCycleId(
    String trainingCycleId,
  ) async {
    final rows = await _dao.getByTrainingCycleUuid(trainingCycleId);
    return rows.map(CyclePeriodMapper.fromRow).toList();
  }

  Stream<List<CyclePeriod>> watchByTrainingCycleId(String trainingCycleId) {
    return _dao.watchByTrainingCycleUuid(trainingCycleId).map(
      (rows) => rows.map(CyclePeriodMapper.fromRow).toList(),
    );
  }

  Future<CyclePeriod?> getByCycleAndPeriod(
    String trainingCycleId,
    int periodNumber,
  ) async {
    final row = await _dao.getByCycleAndPeriod(trainingCycleId, periodNumber);
    return row != null ? CyclePeriodMapper.fromRow(row) : null;
  }

  Future<void> create(CyclePeriod period) async {
    await _dao.insertPeriod(CyclePeriodMapper.toCompanion(period));
  }

  Future<void> update(CyclePeriod period) async {
    await _dao.updateByUuid(
      period.id,
      CyclePeriodMapper.toCompanion(period),
    );
  }

  Future<void> delete(String id) async {
    await _dao.deleteByUuid(id);
  }
}
