import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/skins/skin_provider.dart';
import '../../data/repositories/community_repository.dart';
import '../../data/services/community_service.dart';
import '../../data/services/theme_image_service.dart';
import 'auth_providers.dart';
import 'template_providers.dart';

/// Singleton [CommunityService] instance.
final communityServiceProvider = Provider<CommunityService>((ref) {
  return CommunityService();
});

/// Singleton [CommunityRepository] — wires service + local repos together.
final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepository(
    communityService: ref.watch(communityServiceProvider),
    templateRepository: ref.watch(templateRepositoryProvider),
    skinRepository: ref.watch(skinRepositoryProvider),
    themeImageService: ref.watch(themeImageServiceProvider),
  );
});

// ── Template browsing ──────────────────────────────────────────────────

/// Sort order for the community browse list.
enum CommunitySortOrder { popular, recent }

/// Currently selected sort order for community templates.
class CommunityTemplateSortNotifier extends Notifier<CommunitySortOrder> {
  @override
  CommunitySortOrder build() => CommunitySortOrder.popular;

  void set(CommunitySortOrder order) => state = order;
}

final communityTemplateSortProvider = NotifierProvider<CommunityTemplateSortNotifier, CommunitySortOrder>(
  CommunityTemplateSortNotifier.new,
);

/// Currently selected sport filter (null = all sports).
class CommunityTemplateSportFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? sport) => state = sport;
}

final communityTemplateSportFilterProvider = NotifierProvider<CommunityTemplateSportFilterNotifier, String?>(
  CommunityTemplateSportFilterNotifier.new,
);

/// Fetches the first page of community templates.
///
/// Re-fetches when sort order or sport filter changes.
final communityTemplatesProvider = FutureProvider<CommunityPage<CommunityTemplate>>((ref) async {
  final sort = ref.watch(communityTemplateSortProvider);
  final sportFilter = ref.watch(communityTemplateSportFilterProvider);
  final repo = ref.watch(communityRepositoryProvider);

  return repo.fetchTemplates(
    orderBy: sort == CommunitySortOrder.popular ? 'downloadCount' : 'createdAt',
    sportFilter: sportFilter,
  );
});

/// Search query for community templates.
class CommunityTemplateSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String query) => state = query;
}

final communityTemplateSearchQueryProvider = NotifierProvider<CommunityTemplateSearchQueryNotifier, String>(
  CommunityTemplateSearchQueryNotifier.new,
);

/// Search results for community templates.
final communityTemplateSearchProvider = FutureProvider<List<CommunityTemplate>>((ref) async {
  final query = ref.watch(communityTemplateSearchQueryProvider);
  if (query.trim().length < 2) return [];
  final repo = ref.watch(communityRepositoryProvider);
  return repo.searchTemplates(query.trim());
});

// ── Skin browsing ──────────────────────────────────────────────────────

/// Currently selected sort order for community skins.
class CommunitySkinSortNotifier extends Notifier<CommunitySortOrder> {
  @override
  CommunitySortOrder build() => CommunitySortOrder.popular;

  void set(CommunitySortOrder order) => state = order;
}

final communitySkinSortProvider = NotifierProvider<CommunitySkinSortNotifier, CommunitySortOrder>(
  CommunitySkinSortNotifier.new,
);

/// Fetches the first page of community skins.
final communitySkinsProvider = FutureProvider<CommunityPage<CommunitySkin>>((ref) async {
  final sort = ref.watch(communitySkinSortProvider);
  final repo = ref.watch(communityRepositoryProvider);

  return repo.fetchSkins(
    orderBy: sort == CommunitySortOrder.popular ? 'downloadCount' : 'createdAt',
  );
});

// ── My uploads ──────────────────────────────────────────────────────

/// Templates uploaded by the current user.
final myUploadedTemplatesProvider = FutureProvider.autoDispose<List<CommunityTemplate>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(communityRepositoryProvider);
  return repo.fetchMyTemplates(user.uid);
});

/// Skins uploaded by the current user.
final myUploadedSkinsProvider = FutureProvider.autoDispose<List<CommunitySkin>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(communityRepositoryProvider);
  return repo.fetchMySkins(user.uid);
});

// ── Pagination state ─────────────────────────────────────────────────

/// State for a paginated community list.
class CommunityListState<T> {
  final List<T> items;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;
  final bool isLoadingMore;

  const CommunityListState({
    this.items = const [],
    this.lastDocument,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  CommunityListState<T> copyWith({
    List<T>? items,
    DocumentSnapshot? lastDocument,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return CommunityListState<T>(
      items: items ?? this.items,
      lastDocument: lastDocument ?? this.lastDocument,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
