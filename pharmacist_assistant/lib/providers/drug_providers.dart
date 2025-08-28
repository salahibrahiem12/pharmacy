import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/drug.dart';
import 'drug_repository.dart';

final drugRepositoryProvider = Provider<DrugRepository>((ref) => DrugRepository());

final allDrugsProvider = FutureProvider<List<Drug>>((ref) async {
  final repo = ref.read(drugRepositoryProvider);
  return repo.loadAll();
});

final recentQueriesProvider = StateProvider<List<String>>((ref) => <String>[]);

class DrugSearchParams {
  final String query;
  final String? category;
  final int? tier;
  final String? status;

  const DrugSearchParams({
    this.query = '',
    this.category,
    this.tier,
    this.status,
  });
}

final drugSearchParamsProvider = StateProvider<DrugSearchParams>((ref) => const DrugSearchParams());

final resultsLimitProvider = StateProvider<int>((ref) => 50);

final filteredDrugsProvider = Provider<List<Drug>>((ref) {
  final data = ref.watch(allDrugsProvider).maybeWhen(data: (v) => v, orElse: () => const <Drug>[]);
  final params = ref.watch(drugSearchParamsProvider);
  final limit = ref.watch(resultsLimitProvider);
  final q = params.query.trim().toLowerCase();

  bool matches(Drug d) {
    bool contains(String? s) => s != null && s.toLowerCase().contains(q);
    final okQuery = q.isEmpty || contains(d.packageName) || contains(d.genericName) || contains(d.manufacturerName) || contains(d.agentName);
    final okCategory = params.category == null || params.category == d.category;
    final okTier = params.tier == null || params.tier == d.tier;
    final okStatus = params.status == null || params.status == d.status;
    return okQuery && okCategory && okTier && okStatus;
  }

  final iter = data.where(matches);
  final out = <Drug>[];
  for (final d in iter) {
    out.add(d);
    if (out.length >= limit) break;
  }
  return out;
});
