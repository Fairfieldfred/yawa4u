import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/training_cycle_template.dart';
import '../../data/repositories/template_repository.dart';

/// Provider for TemplateRepository instance
final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  return TemplateRepository();
});

/// Provider for list of available templates
final availableTemplatesProvider = FutureProvider<List<TrainingCycleTemplate>>((
  ref,
) async {
  final repository = ref.watch(templateRepositoryProvider);
  return await repository.getAllTemplates();
});

/// Provider for currently selected template
/// Provider for currently selected template
final selectedTemplateProvider =
    NotifierProvider<SelectedTemplateNotifier, TrainingCycleTemplate?>(
      SelectedTemplateNotifier.new,
    );

class SelectedTemplateNotifier extends Notifier<TrainingCycleTemplate?> {
  @override
  TrainingCycleTemplate? build() => null;

  void set(TrainingCycleTemplate? template) {
    state = template;
  }
}
