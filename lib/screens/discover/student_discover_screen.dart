import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/enums.dart';
import '../../models/seeds.dart';
import '../../providers/providers.dart';
import '../../widgets/common_widgets.dart';
import '../opportunity/opportunity_details.dart';

class StudentDiscoverScreen extends ConsumerWidget {
  const StudentDiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(marketplaceControllerProvider);
    final controller = ref.read(marketplaceControllerProvider.notifier);
    final opportunities = state.filteredOpportunities;

    if (state.opportunities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SurfaceCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Discover opportunities', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const SizedBox(height: 8),
                Text(
                  'Browse verified startup roles. Seed demo opportunities appear while Firestore hydrates.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: controller.clearFilters,
                  child: const Text('Reset filters'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Discover opportunities', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Search by role, commitment, or mode. Bookmarks and applications update in real time.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black.withOpacity(0.65),
                      ),
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: controller.updateSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search opportunities, startups, or skills',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilterChip(
                      label: const Text('All roles'),
                      selected: state.categoryFilter == OpportunityCategory.all,
                      onSelected: (_) => controller.setCategoryFilter(OpportunityCategory.all),
                    ),
                    for (final category in OpportunityCategory.values.where((value) => value != OpportunityCategory.all))
                      FilterChip(
                        label: Text(category.label),
                        selected: state.categoryFilter == category,
                        onSelected: (_) => controller.setCategoryFilter(category),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final mode in OpportunityMode.values)
                      ChoiceChip(
                        label: Text(mode.label),
                        selected: state.modeFilter == mode,
                        onSelected: (_) => controller.setModeFilter(mode),
                      ),
                    ActionChip(label: const Text('Reset'), onPressed: controller.clearFilters),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          sliver: SliverList.separated(
            itemBuilder: (context, index) {
              final opportunity = opportunities.isEmpty
                  ? seedOpportunities[index % seedOpportunities.length]
                  : opportunities[index];

              return OpportunityCard(
                opportunity: opportunity,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => OpportunityDetailsPage(opportunity: opportunity),
                  ),
                ),
              );
            },
separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: opportunities.isEmpty ? seedOpportunities.length : opportunities.length,
          ),
        ),
      ],
    );
  }
}

