import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/application_record.dart';
import '../../models/enums.dart';
import '../../providers/providers.dart';
import '../../widgets/common_widgets.dart';

class StartupApplicationsScreen extends ConsumerWidget {
  const StartupApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final marketplace = ref.watch(marketplaceControllerProvider);

    final grouped = <ApplicationStatus, List<ApplicationRecord>>{
      for (final status in ApplicationStatus.values) status: [],
    };
    for (final application in marketplace.applications) {
      grouped[application.status]!.add(application);
    }

    final hasAny = marketplace.applications.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      children: [
        Text('Applicant pipeline', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          authState.verifiedStartup
              ? 'Review inbound interest and move candidates through your stages.'
              : 'Request verification to post opportunities and receive applications.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black.withOpacity(0.65),
              ),
        ),
        const SizedBox(height: 16),
        if (!hasAny)
          const SurfaceCard(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No applications yet. When students apply to your opportunities, '
                'they will appear here in real time.',
              ),
            ),
          )
        else
          for (final status in const [
            ApplicationStatus.pending,
            ApplicationStatus.shortlisted,
            ApplicationStatus.interview,
            ApplicationStatus.accepted,
          ]) ...[
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(status.label, style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      Text(
                        '${grouped[status]!.length}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF0F766E),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (grouped[status]!.isEmpty)
                    Text(
                      'No applicants in this stage yet.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black.withOpacity(0.55),
                          ),
                    )
                  else
                    for (final application in grouped[status]!) ...[
                      _ApplicantCard(application: application),
                      if (application != grouped[status]!.last) const SizedBox(height: 10),
                    ],
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
      ],
    );
  }
}

class _ApplicantCard extends ConsumerWidget {
  const _ApplicantCard({required this.application});

  final ApplicationRecord application;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicant =
        application.applicantName.isNotEmpty ? application.applicantName : 'Applicant';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5EE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7DDD0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    Text(applicant, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      'Applied to ${application.title}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black.withOpacity(0.62),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AppBadge(label: application.status.label),
            ],
          ),
          if (application.note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              application.note,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black.withOpacity(0.72),
                  ),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: PopupMenuButton<ApplicationStatus>(
              onSelected: (status) => ref
                  .read(marketplaceControllerProvider.notifier)
                  .updateApplicationStatus(application, status),
              itemBuilder: (context) => [
                for (final status in ApplicationStatus.values)
                  if (status != application.status)
                    PopupMenuItem(
                      value: status,
                      child: Row(
                        children: [
                          Icon(status.icon, size: 18, color: status.color),
                          const SizedBox(width: 10),
                          Text('Move to ${status.label}'),
                        ],
                      ),
                    ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Update status', style: TextStyle(color: Color(0xFF0F766E))),
                    SizedBox(width: 6),
                    Icon(Icons.expand_more_rounded, size: 18, color: Color(0xFF0F766E)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
