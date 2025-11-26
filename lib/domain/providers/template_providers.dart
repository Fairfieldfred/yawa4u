import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/mesocycle_template.dart';
import '../../data/repositories/template_repository.dart';

/// Provider for TemplateRepository instance
final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  return TemplateRepository();
});

/// Provider for list of available templates
final availableTemplatesProvider = FutureProvider<List<MesocycleTemplate>>((
  ref,
) async {
  final repository = ref.watch(templateRepositoryProvider);
  return await repository.getAllTemplates();
});

/// Provider for currently selected template
/// Provider for currently selected template
final selectedTemplateProvider =
    NotifierProvider<SelectedTemplateNotifier, MesocycleTemplate?>(
      SelectedTemplateNotifier.new,
    );

class SelectedTemplateNotifier extends Notifier<MesocycleTemplate?> {
  @override
  MesocycleTemplate? build() => null;

  void set(MesocycleTemplate? template) {
    state = template;
  }
}
