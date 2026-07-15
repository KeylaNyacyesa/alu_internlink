import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../models/enums.dart';
import '../../models/opportunity.dart';
import '../../providers/providers.dart';
import '../../widgets/common_widgets.dart';

class OpportunityFormScreen extends ConsumerStatefulWidget {
  const OpportunityFormScreen({super.key, this.existingOpportunity});

  final Opportunity? existingOpportunity;

  @override
  ConsumerState<OpportunityFormScreen> createState() => _OpportunityFormScreenState();
}

class _OpportunityFormScreenState extends ConsumerState<OpportunityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _startupController;
  late final TextEditingController _summaryController;
  late final TextEditingController _commitmentController;
  late final TextEditingController _locationController;
  late final TextEditingController _skillsController;
  OpportunityCategory _category = OpportunityCategory.engineering;
  OpportunityMode _mode = OpportunityMode.hybrid;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final draft = widget.existingOpportunity;
    _titleController = TextEditingController(text: draft?.title ?? '');
    _startupController = TextEditingController(text: draft?.startupName ?? '');
    _summaryController = TextEditingController(text: draft?.summary ?? '');
    _commitmentController = TextEditingController(text: draft?.commitment ?? '');
    _locationController = TextEditingController(text: draft?.location ?? '');
    _skillsController = TextEditingController(text: draft?.skills.join(', ') ?? '');
    _category = draft?.category ?? OpportunityCategory.engineering;
    _mode = draft?.mode ?? OpportunityMode.hybrid;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _startupController.dispose();
    _summaryController.dispose();
    _commitmentController.dispose();
    _locationController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _saving = true);
    final ownerId = widget.existingOpportunity?.ownerId.isNotEmpty == true
        ? widget.existingOpportunity!.ownerId
        : (FirebaseAuth.instance.currentUser?.uid ?? '');
    final opportunity = Opportunity(
      id: widget.existingOpportunity?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      ownerId: ownerId,
      title: _titleController.text.trim(),
      startupName: _startupController.text.trim(),
      summary: _summaryController.text.trim(),
      category: _category,
      mode: _mode,
      commitment: _commitmentController.text.trim(),
      location: _locationController.text.trim(),
      skills: _skillsController.text
          .split(',')
          .map((skill) => skill.trim())
          .where((skill) => skill.isNotEmpty)
          .toList(growable: false),
      postedDaysAgo: 0,
      verifiedStartup: true,
      applicantCount: widget.existingOpportunity?.applicantCount ?? 0,
      gradient: widget.existingOpportunity?.gradient ?? const [Color(0xFF0F766E), Color(0xFF7DD3FC)],
    );

    await ref.read(marketplaceControllerProvider.notifier).upsertOpportunity(opportunity);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final id = widget.existingOpportunity?.id;
    if (id == null) {
      return;
    }
    await ref.read(marketplaceControllerProvider.notifier).deleteOpportunity(id);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existingOpportunity == null ? 'Post opportunity' : 'Edit opportunity')),
      body: Stack(
        children: [
          const BackgroundCanvas(),
          SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(labelText: 'Opportunity title'),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Title is required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _startupController,
                          decoration: const InputDecoration(labelText: 'Startup / organization name'),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Startup name is required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _summaryController,
                          maxLines: 3,
                          decoration: const InputDecoration(labelText: 'Summary'),
                          validator: (value) => value == null || value.trim().length < 20 ? 'Add a short but descriptive summary' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<OpportunityCategory>(
                          value: _category,
                          items: [
                            for (final category in OpportunityCategory.values.where((value) => value != OpportunityCategory.all))
                              DropdownMenuItem(value: category, child: Text(category.label)),
                          ],
                          onChanged: (value) {
                            if (value != null) setState(() => _category = value);
                          },
                          decoration: const InputDecoration(labelText: 'Category'),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<OpportunityMode>(
                          value: _mode,
                          items: [
                            for (final mode in OpportunityMode.values)
                              DropdownMenuItem(value: mode, child: Text(mode.label)),
                          ],
                          onChanged: (value) {
                            if (value != null) setState(() => _mode = value);
                          },
                          decoration: const InputDecoration(labelText: 'Mode'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _commitmentController,
                          decoration: const InputDecoration(labelText: 'Commitment (e.g. Part-time)'),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Commitment is required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(labelText: 'Location'),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Location is required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _skillsController,
                          decoration: const InputDecoration(labelText: 'Skills, comma separated'),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Add at least one skill' : null,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _saving ? null : _save,
                          child: Text(_saving ? 'Saving...' : 'Save opportunity'),
                        ),
                        if (widget.existingOpportunity != null) ...[
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: _saving ? null : _delete,
                            child: const Text('Delete opportunity'),
                          ),
                        ],
                      ],
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
