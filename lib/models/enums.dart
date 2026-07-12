import 'package:flutter/material.dart';

enum UserRole { student, startup }

extension UserRoleLabel on UserRole {
  String get label => switch (this) {
        UserRole.student => 'Student',
        UserRole.startup => 'Startup',
      };
}

enum OpportunityCategory {
  all('All roles'),
  design('Design'),
  engineering('Engineering'),
  marketing('Marketing'),
  operations('Operations'),
  research('Research'),
  content('Content');

  const OpportunityCategory(this.label);

  final String label;
}

enum OpportunityMode { remote, onCampus, hybrid }

extension OpportunityModeLabel on OpportunityMode {
  String get label => switch (this) {
        OpportunityMode.remote => 'Remote',
        OpportunityMode.onCampus => 'On campus',
        OpportunityMode.hybrid => 'Hybrid',
      };
}

enum ApplicationStatus { pending, shortlisted, interview, accepted, closed }

extension ApplicationStatusLabel on ApplicationStatus {
  String get label => switch (this) {
        ApplicationStatus.pending => 'Pending',
        ApplicationStatus.shortlisted => 'Shortlisted',
        ApplicationStatus.interview => 'Interview',
        ApplicationStatus.accepted => 'Accepted',
        ApplicationStatus.closed => 'Closed',
      };

  Color get color => switch (this) {
        ApplicationStatus.pending => const Color(0xFFD97706),
        ApplicationStatus.shortlisted => const Color(0xFF0F766E),
        ApplicationStatus.interview => const Color(0xFF2563EB),
        ApplicationStatus.accepted => const Color(0xFF15803D),
        ApplicationStatus.closed => const Color(0xFF6B7280),
      };

  IconData get icon => switch (this) {
        ApplicationStatus.pending => Icons.hourglass_top_rounded,
        ApplicationStatus.shortlisted => Icons.verified_rounded,
        ApplicationStatus.interview => Icons.video_call_rounded,
        ApplicationStatus.accepted => Icons.check_circle_rounded,
        ApplicationStatus.closed => Icons.archive_rounded,
      };
}
