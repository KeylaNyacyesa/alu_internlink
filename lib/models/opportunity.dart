import 'package:flutter/material.dart';
import 'enums.dart';

class Opportunity {
  Opportunity({
    required this.id,
    required this.title,
    required this.startupName,
    required this.summary,
    required this.category,
    required this.mode,
    required this.commitment,
    required this.location,
    required this.skills,
    required this.postedDaysAgo,
    required this.verifiedStartup,
    required this.applicantCount,
    required this.gradient,
    this.ownerId = '',
  });

  final String id;
  /// uid of the startup account that owns this posting. Empty for local seed data.
  final String ownerId;
  final String title;
  final String startupName;
  final String summary;
  final OpportunityCategory category;
  final OpportunityMode mode;
  final String commitment;
  final String location;
  final List<String> skills;
  final int postedDaysAgo;
  final bool verifiedStartup;
  final int applicantCount;
  final List<Color> gradient;

  String get postedLabel => 'Posted ${postedDaysAgo}d ago';

  factory Opportunity.fromMap(Map<String, dynamic> data, String id) {
    return Opportunity(
      id: id,
      ownerId: data['ownerId'] as String? ?? '',
      title: data['title'] as String? ?? 'Untitled opportunity',
      startupName: data['startupName'] as String? ?? 'ALU Startup',
      summary: data['summary'] as String? ?? 'Opportunity details are available in Firestore.',
      category: _categoryFromValue(data['category'] as String?),
      mode: _modeFromValue(data['mode'] as String?),
      commitment: data['commitment'] as String? ?? 'Part-time',
      location: data['location'] as String? ?? 'ALU Kigali',
      skills: (data['skills'] as List<dynamic>? ?? const ['Flutter'])
          .map((value) => value.toString())
          .toList(growable: false),
      postedDaysAgo: data['postedDaysAgo'] as int? ?? 0,
      verifiedStartup: data['verifiedStartup'] as bool? ?? true,
      applicantCount: data['applicantCount'] as int? ?? 0,
      gradient: const [Color(0xFF0F766E), Color(0xFF7DD3FC)],
    );
  }

  Map<String, dynamic> toMap() => {
        'ownerId': ownerId,
        'title': title,
        'startupName': startupName,
        'summary': summary,
        'category': category.label,
        'mode': mode.label,
        'commitment': commitment,
        'location': location,
        'skills': skills,
        'postedDaysAgo': postedDaysAgo,
        'verifiedStartup': verifiedStartup,
        'applicantCount': applicantCount,
      };
}

OpportunityCategory _categoryFromValue(String? value) {
  return OpportunityCategory.values.firstWhere(
    (category) => category.label.toLowerCase() == value?.toLowerCase(),
    orElse: () => OpportunityCategory.engineering,
  );
}

OpportunityMode _modeFromValue(String? value) {
  return OpportunityMode.values.firstWhere(
    (mode) => mode.label.toLowerCase() == value?.toLowerCase(),
    orElse: () => OpportunityMode.hybrid,
  );
}
