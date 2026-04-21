import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/sports.dart';
import '../../data/models/cardio_session_template.dart';
import '../../data/services/cardio_session_library_service.dart';

/// All bundled cardio session templates. Cached in-memory on first read.
final cardioSessionTemplatesProvider =
    FutureProvider<List<CardioSessionTemplate>>((ref) {
  return CardioSessionLibraryService.instance.loadAll();
});

/// Cardio session templates filtered to a single sport. Backs the sport
/// tabs on the template picker.
final cardioSessionTemplatesBySportProvider =
    FutureProvider.autoDispose.family<List<CardioSessionTemplate>, Sport>((
      ref,
      sport,
    ) {
      return CardioSessionLibraryService.instance.loadForSport(sport);
    });
