import 'package:flutter/material.dart';
import 'opportunity.dart';
import 'application_record.dart';
import 'enums.dart';

final seedOpportunities = <Opportunity>[
  Opportunity(
    id: 'op-1',
    title: 'Flutter Developer',
    startupName: 'Learnify',
    summary:
        'Build learning features for an ALU venture focused on peer-led skill sharing. You will work on onboarding, analytics, and product polish.',
    category: OpportunityCategory.engineering,
    mode: OpportunityMode.hybrid,
    commitment: 'Part-time · 8-10 hrs/week',
    location: 'On campus',
    skills: ['Flutter', 'Dart', 'Firebase'],
    postedDaysAgo: 3,
    verifiedStartup: true,
    applicantCount: 12,
    gradient: const [Color(0xFF0F766E), Color(0xFF7DD3FC)],
  ),
  Opportunity(
    id: 'op-2',
    title: 'UX Research Volunteer',
    startupName: 'EduBridge',
    summary:
        'Interview students, map friction points, and turn insights into product decisions for an education-focused startup.',
    category: OpportunityCategory.research,
    mode: OpportunityMode.remote,
    commitment: '4-6 hrs/week',
    location: 'Remote',
    skills: ['Interviewing', 'Figma', 'Insight synthesis'],
    postedDaysAgo: 2,
    verifiedStartup: true,
    applicantCount: 8,
    gradient: const [Color(0xFFB45309), Color(0xFFF2C98A)],
  ),
  Opportunity(
    id: 'op-3',
    title: 'Social Media Assistant',
    startupName: 'GreenLoop',
    summary:
        'Help shape the voice of a sustainability startup through short-form content, scheduling, and campaign support.',
    category: OpportunityCategory.content,
    mode: OpportunityMode.onCampus,
    commitment: 'Part-time · Flexible',
    location: 'Kigali',
    skills: ['Content writing', 'Canva', 'Scheduling'],
    postedDaysAgo: 5,
    verifiedStartup: true,
    applicantCount: 21,
    gradient: const [Color(0xFF6D28D9), Color(0xFFFBCFE8)],
  ),
  Opportunity(
    id: 'op-4',
    title: 'Operations Intern',
    startupName: 'CampusHive',
    summary:
        'Support daily coordination, vendor follow-up, and startup operations for a student-led productivity platform.',
    category: OpportunityCategory.operations,
    mode: OpportunityMode.hybrid,
    commitment: '6 hrs/week',
    location: 'ALU Kigali',
    skills: ['Operations', 'Communication', 'Coordination'],
    postedDaysAgo: 1,
    verifiedStartup: false,
    applicantCount: 4,
    gradient: const [Color(0xFF475569), Color(0xFFCBD5E1)],
  ),
];

final seedApplications = <ApplicationRecord>[
  ApplicationRecord(
    id: 'app-1',
    opportunityId: 'op-1',
    title: 'Flutter Developer',
    startupName: 'Learnify',
    status: ApplicationStatus.shortlisted,
    submittedAt: DateTime.now().subtract(const Duration(days: 2)),
    note: 'Shared portfolio and product case study.',
  ),
  ApplicationRecord(
    id: 'app-2',
    opportunityId: 'op-2',
    title: 'UX Research Volunteer',
    startupName: 'EduBridge',
    status: ApplicationStatus.pending,
    submittedAt: DateTime.now().subtract(const Duration(days: 1)),
    note: 'Research background with campus interview experience.',
  ),
];
