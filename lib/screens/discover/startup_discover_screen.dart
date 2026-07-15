import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/enums.dart';
import '../../models/seeds.dart';
import '../../providers/providers.dart';

import '../opportunity/opportunity_details.dart';

class StartupDiscoverScreen extends ConsumerWidget {
  const StartupDiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final state = ref.watch(marketplaceControllerProvider);
    final controller = ref.read(marketplaceControllerProvider.notifier);

    final opportunities = state.filteredOpportunities.where((op) => op.verifiedStartup);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verified startup ecosystem', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  authState.verifiedStartup
                      ? 'Preview what students see and verify your organization’s listing quality.'
                      : 'You need startup verification before your opportunities appear live.',
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
              final list = opportunities.toList(growable: false);
              final opportunity = list.isEmpty
                  ? seedOpportunities.first
                  : list[index % list.length];

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
            itemCount: opportunities.isEmpty ? 1 : opportunities.length,
          ),
        ),
      ],
    );
  }
}

