import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/enums.dart';
import '../../models/seeds.dart';
import '../../providers/providers.dart';
import '../../widgets/common_widgets.dart';
import '../opportunity/opportunity_form_screen.dart';
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
                height: 360,
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
              Text(
                role == UserRole.startup ? 'Startup control center' : 'Student next steps',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                role == UserRole.startup
                    ? 'Verify your venture, publish roles, and manage applicants from one place.'
                    : 'Search, bookmark, and apply to opportunities while tracking status in real time.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black.withOpacity(0.68),
                    ),
              ),
              const SizedBox(height: 12),
              if (role == UserRole.startup)
                FilledButton.icon(
                  onPressed: authState.verifiedStartup
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const OpportunityFormScreen(),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: Text(authState.verifiedStartup ? 'Post opportunity' : 'Request verification first'),
                ),
              if (role == UserRole.startup) const SizedBox(height: 12),
              if (role == UserRole.startup) ...[
                const WorkflowStep(
                  index: '1',
                  title: 'Request verification',
                  body: 'Only ALU-recognized startups can publish visible opportunities.',
                ),
                const WorkflowStep(
                  index: '2',
                  title: 'Post opportunities',
                  body: 'Create, edit, and remove roles as your hiring needs change.',
                ),
                const WorkflowStep(
                  index: '3',
                  title: 'Review applicants',
                  body: 'Move students through applied, interview, and accepted states.',
                ),
              ] else ...[
                const WorkflowStep(
                  index: '1',
                  title: 'Find roles',
                  body: 'Discover verified opportunities with filters for role and commitment.',
                ),
                const WorkflowStep(
                  index: '2',
                  title: 'Save favorites',
                  body: 'Bookmark opportunities you want to return to later.',
                ),
                const WorkflowStep(
                  index: '3',
                  title: 'Monitor progress',
                  body: 'See status updates as your applications move in Firestore.',
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
