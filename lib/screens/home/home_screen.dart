import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/enums.dart';
import '../../models/seeds.dart';
import '../../providers/providers.dart';
import '../../widgets/common_widgets.dart';
import '../opportunity/opportunity_details.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final marketplace = ref.watch(marketplaceControllerProvider);
    final featured = marketplace.featuredOpportunities;
    final pendingCount = marketplace.applications
        .where((application) => application.status == ApplicationStatus.pending)
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      children: [
        HomeHeader(role: role, name: authState.displayName),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                label: 'New matches',
                value: '${featured.length}',
                detail: 'Verified startup roles',
                accent: const Color(0xFF0F766E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                label: 'Applications',
                value: '${marketplace.applications.length}',
                detail: '$pendingCount pending review',
                accent: const Color(0xFFD97706),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role == UserRole.startup
                    ? 'Your venture is ready to hire'
                    : 'Recommended for your skill profile',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                role == UserRole.startup
                    ? 'Build a verified team, review interest quickly, and keep communication inside one workflow.'
                    : 'Roles are ranked by relevance, location, commitment level, and ALU startup verification.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black.withOpacity(0.68),
                    ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: featured.isEmpty ? 1 : featured.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final opportunity = featured.isEmpty
                        ? seedOpportunities.first
                        : featured[index % featured.length];
                    return SizedBox(
                      width: 280,
                      child: OpportunityCard(
                        opportunity: opportunity,
                        compact: false,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => OpportunityDetailsPage(opportunity: opportunity),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Workflow snapshot', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  Text(
                    role == UserRole.startup ? 'Startup mode' : 'Student mode',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: const Color(0xFF0F766E),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const WorkflowStep(
                index: '1',
                title: 'Verify identity',
                body: 'ALU email, profile data, and startup review keep the platform trusted.',
              ),
              const WorkflowStep(
                index: '2',
                title: 'Match on skills',
                body: 'Search, bookmark, and filter by discipline, location, and commitment.',
              ),
              const WorkflowStep(
                index: '3',
                title: 'Track progress',
                body: 'Applications move through pending, shortlisted, interview, and accepted.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
