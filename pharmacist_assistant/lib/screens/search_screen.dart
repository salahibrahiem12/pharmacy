import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/drug_providers.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAll = ref.watch(allDrugsProvider);
    final results = ref.watch(filteredDrugsProvider);
    final params = ref.watch(drugSearchParamsProvider);
    final limit = ref.watch(resultsLimitProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Drugs'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name, generic, manufacturer...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => ref.read(drugSearchParamsProvider.notifier).state = DrugSearchParams(
                query: value,
                category: params.category,
                tier: params.tier,
                status: params.status,
              ),
            ),
          ),
          Expanded(
            child: asyncAll.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (_) => Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final d = results[index];
                        return ListTile(
                          title: Text(d.packageName ?? d.genericName ?? d.drugCode ?? 'Unknown'),
                          subtitle: Text([
                            if (d.genericName != null) d.genericName!,
                            if (d.manufacturerName != null) d.manufacturerName!,
                            if (d.category.isNotEmpty) d.category,
                          ].join(' • ')),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (d.pricePharmacy != null) Text('Pharm: ${d.pricePharmacy!.toStringAsFixed(2)}'),
                              if (d.savingsPercent != null) Text('Save: ${d.savingsPercent!.toStringAsFixed(1)}%'),
                            ],
                          ),
                          onTap: () {},
                        );
                      },
                    ),
                  ),
                  if (results.length >= limit)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.expand_more),
                        label: Text('Load more (${limit}→${limit + 50})'),
                        onPressed: () => ref.read(resultsLimitProvider.notifier).state = limit + 50,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
