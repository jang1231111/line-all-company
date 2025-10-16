import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/condition_form_widget.dart';
import '../widgets/condition_surcharge_panel.dart';
import '../../data/repositories/in_memory_condition_repository.dart';
import '../providers/condition_notifier.dart';

class ConditionFormPage extends ConsumerWidget {
  const ConditionFormPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        conditionRepositoryProvider.overrideWithValue(InMemoryConditionRepository()),
      ],
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          toolbarHeight: 72,
          titleSpacing: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1C63D6), Color(0xFF154E9C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
          ),
          title: Row(
            children: [
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.local_shipping, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('운임 계산기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  SizedBox(height: 2),
                  Text('신속하고 정확한 운임 산출', style: TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(icon: const Icon(Icons.help_outline, color: Colors.white), onPressed: () {}),
            IconButton(icon: const Icon(Icons.settings, color: Colors.white), onPressed: () {}),
            const SizedBox(width: 8),
          ],
        ),
        backgroundColor: const Color(0xFFF5F7FA), // soft gray background like the screenshot
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 720) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(child: ConditionFormWidget()),
                  SizedBox(width: 16),
                  SizedBox(width: 380, child: ConditionSurchargePanel()),
                ],
              );
            } else {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: const [ConditionFormWidget(), SizedBox(height: 12), ConditionSurchargePanel()],
              );
            }
          },
        ),
      ),
    );
  }
}
