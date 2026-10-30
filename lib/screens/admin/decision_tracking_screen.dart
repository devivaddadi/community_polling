import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/decision_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/decision_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/status_badge.dart';

class DecisionTrackingScreen extends StatefulWidget {
  const DecisionTrackingScreen({super.key});

  @override
  State<DecisionTrackingScreen> createState() => _DecisionTrackingScreenState();
}

class _DecisionTrackingScreenState extends State<DecisionTrackingScreen> {
  void _showRecordDecisionModal(BuildContext context, DecisionProvider provider, AuthProvider auth) {
    final titleCtrl = TextEditingController();
    final summaryCtrl = TextEditingController();
    final rationaleCtrl = TextEditingController();
    final budgetCtrl = TextEditingController(text: '₹1,50,000');
    final targetDateCtrl = TextEditingController(text: '30 July 2024');
    final actionCtrl1 = TextEditingController(text: 'Finalize contractor quotation');
    final actionCtrl2 = TextEditingController(text: 'Execute community rollout');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Record Community Decision', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: titleCtrl,
                label: 'Decision Title',
                hintText: 'e.g. Solar Street Lighting Installation',
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: summaryCtrl,
                label: 'Decision Summary & Scope',
                hintText: 'Brief summary of what was decided based on voting results',
                maxLines: 2,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: rationaleCtrl,
                label: 'Voter Mandate Rationale',
                hintText: 'e.g. 68% voter approval with positive discussion sentiment',
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: budgetCtrl,
                      label: 'Budget Allocated',
                      hintText: '₹2,00,000',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: targetDateCtrl,
                      label: 'Target Completion',
                      hintText: 'DD MMM YYYY',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Action Checklist', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              CustomTextField(controller: actionCtrl1, hintText: 'Action step 1'),
              const SizedBox(height: 8),
              CustomTextField(controller: actionCtrl2, hintText: 'Action step 2'),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Record Decision & Notify',
                width: double.infinity,
                onPressed: () {
                  if (titleCtrl.text.trim().isNotEmpty) {
                    provider.recordDecision(
                      communityId: 'c1',
                      pollId: 'poll_1',
                      pollTitle: 'What improvement should we prioritize in our community?',
                      title: titleCtrl.text.trim(),
                      summary: summaryCtrl.text.trim(),
                      rationale: rationaleCtrl.text.trim(),
                      decidedBy: auth.currentUser?.name ?? 'Executive Council',
                      actionTitles: [actionCtrl1.text.trim(), actionCtrl2.text.trim()],
                      estimatedBudget: budgetCtrl.text.trim(),
                      targetCompletionDate: targetDateCtrl.text.trim(),
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Decision recorded and published to community timeline!')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final decisionProvider = context.watch<DecisionProvider>();
    final auth = context.watch<AuthProvider>();
    final decisions = decisionProvider.decisions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Decision Tracking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.add_task_rounded, color: AppColors.primary),
              onPressed: () => _showRecordDecisionModal(context, decisionProvider, auth),
            ),
        ],
      ),
      body: decisions.isEmpty
          ? const Center(child: Text('No decisions recorded yet'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: decisions.length,
              itemBuilder: (context, index) {
                final decision = decisions[index];
                final isCompleted = decision.status == DecisionStatus.completed;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StatusBadge(
                            text: isCompleted ? 'Completed' : 'In Progress',
                            type: isCompleted ? BadgeType.completed : BadgeType.inProgress,
                            isSmall: true,
                          ),
                          Text(
                            DateFormatter.formatDate(decision.decidedAt),
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        decision.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        decision.summary,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
                      ),
                      const SizedBox(height: 12),

                      // Meta specs: Budget & Target
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (decision.estimatedBudget.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(Icons.account_balance_wallet_outlined, size: 14, color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Budget: ${decision.estimatedBudget}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            if (decision.targetCompletionDate.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(Icons.event_available, size: 14, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Target: ${decision.targetCompletionDate}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      const Divider(color: AppColors.borderLight),
                      const SizedBox(height: 8),

                      // Action Items Checklist
                      const Text(
                        'Action Items',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      ...decision.actionItems.map((action) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: InkWell(
                            onTap: auth.isAdmin
                                ? () => decisionProvider.toggleActionItem(decision.id, action.id)
                                : null,
                            child: Row(
                              children: [
                                Icon(
                                  action.isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                                  size: 18,
                                  color: action.isCompleted ? AppColors.success : AppColors.textMuted,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    action.title,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: action.isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                                      decoration: action.isCompleted ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
