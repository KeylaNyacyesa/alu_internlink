import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/enums.dart';
import '../../models/opportunity.dart';
import '../../models/application_record.dart';
import '../../providers/providers.dart';
import '../../widgets/common_widgets.dart';

class OpportunityDetailsPage extends ConsumerWidget {
  const OpportunityDetailsPage({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketplace = ref.watch(marketplaceControllerProvider);
    final bookmarked = marketplace.bookmarkedOpportunityIds.contains(opportunity.id);

    return Scaffold(
      body: Stack(
        children: [
          const BackgroundCanvas(),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => ref
                                  .read(marketplaceControllerProvider.notifier)
                                  .toggleBookmark(opportunity.id),
                              icon: Icon(
                                bookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        SurfaceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: opportunity.gradient),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: const Icon(Icons.workspaces_rounded, color: Colors.white),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          opportunity.title,
                                          style: Theme.of(context).textTheme.titleLarge,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          opportunity.startupName,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: Colors.black.withOpacity(0.68),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (opportunity.verifiedStartup) const Badge(label: 'Verified'),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  Pill(label: opportunity.category.label),
                                  Pill(label: opportunity.mode.label),
                                  Pill(label: opportunity.commitment),
                                  Pill(label: opportunity.location),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(opportunity.summary, style: Theme.of(context).textTheme.bodyLarge),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        SurfaceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Startup profile', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Text(
                                'This section explains why the startup is eligible for the ALU platform: campus recognition, clear founder identity, and a reviewable opportunity trail.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.black.withOpacity(0.66),
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: StatMiniCard(
                                      title: 'Applicants',
                                      value: '${opportunity.applicantCount}',
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: StatMiniCard(
                                      title: 'Posted',
                                      value: opportunity.postedLabel,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        SurfaceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Skills required', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [for (final skill in opportunity.skills) Pill(label: skill)],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        SurfaceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Application flow', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Text(
                                'The interest form writes to Firestore immediately and updates local state at once so the user sees instant feedback even when a network call is pending.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.black.withOpacity(0.66),
                                    ),
                              ),
                              const SizedBox(height: 14),
                              FilledButton(
                                onPressed: () => _submitInterest(context, ref),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(52),
                                ),
                                child: const Text('Apply now'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitInterest(BuildContext context, WidgetRef ref) async {
    final noteController = TextEditingController();
    final accepted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Submit interest', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            TextField(
              controller: noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Add a short note about your skills, project links, or why this role matters to you.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Send application'),
            ),
          ],
        ),
      ),
    );

    if (accepted == true) {
      await ref.read(marketplaceControllerProvider.notifier).submitApplication(
            opportunity,
            noteController.text.trim(),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted')),
        );
      }
    }
  }
}

class OpportunityCard extends ConsumerWidget {
  const OpportunityCard({
    super.key,
    required this.opportunity,
    required this.onTap,
    this.compact = true,
  });

  final Opportunity opportunity;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarked =
        ref.watch(marketplaceControllerProvider).bookmarkedOpportunityIds.contains(opportunity.id);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: opportunity.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(1),
          padding: EdgeInsets.all(compact ? 16 : 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(23),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: opportunity.gradient),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.bolt_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(opportunity.title, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          opportunity.startupName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.black.withOpacity(0.64),
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref.read(marketplaceControllerProvider.notifier).toggleBookmark(opportunity.id),
                    icon: Icon(bookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                opportunity.summary,
                maxLines: compact ? 3 : 4,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Pill(label: opportunity.category.label),
                  Pill(label: opportunity.mode.label),
                  Pill(label: opportunity.commitment),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 16, color: Colors.black.withOpacity(0.54)),
                  const SizedBox(width: 6),
                  Text(
                    opportunity.postedLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black.withOpacity(0.58),
                        ),
                  ),
                  const Spacer(),
                  if (opportunity.verifiedStartup) const Badge(label: 'Verified'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ApplicationCard extends StatelessWidget {
  const ApplicationCard({super.key, required this.application});

  final ApplicationRecord application;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5EE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7DDD0)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: application.status.color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(application.status.icon, color: application.status.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(application.title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  application.startupName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black.withOpacity(0.62),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Badge(label: application.status.label),
        ],
      ),
    );
  }
}
