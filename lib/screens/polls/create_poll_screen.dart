import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/notification_model.dart';
import '../../models/poll_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/poll_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class CreatePollScreen extends StatefulWidget {
  const CreatePollScreen({super.key});

  @override
  State<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends State<CreatePollScreen> {
  final _questionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(text: 'Option 1'),
    TextEditingController(text: 'Option 2'),
    TextEditingController(text: 'Option 3'),
  ];
  String _selectedCategory = 'Facilities';
  PollType _pollType = PollType.public;
  DateTime _endsAt = DateTime.now().add(const Duration(days: 3, hours: 4));
  bool _isCreating = false;

  @override
  void dispose() {
    _questionController.dispose();
    _descriptionController.dispose();
    for (var c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionControllers.length >= 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 8 options allowed')),
      );
      return;
    }
    setState(() {
      _optionControllers.add(
        TextEditingController(text: 'Option ${_optionControllers.length + 1}'),
      );
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A poll must have at least 2 options')),
      );
      return;
    }
    setState(() {
      final removed = _optionControllers.removeAt(index);
      removed.dispose();
    });
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _endsAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_endsAt),
      );

      if (pickedTime != null) {
        setState(() {
          _endsAt = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _submitPoll() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a poll question'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final options = _optionControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide at least 2 non-empty options'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final community = context.read<CommunityProvider>().currentCommunity;
    final pollProvider = context.read<PollProvider>();
    final notifProvider = context.read<NotificationProvider>();

    setState(() {
      _isCreating = true;
    });

    final newPoll = await pollProvider.createPoll(
      communityId: community.id,
      creatorId: auth.currentUser?.id ?? 'u_priya',
      creatorName: auth.currentUser?.name ?? 'Priya Patel',
      creatorAvatar: auth.currentUser?.avatarUrl ?? 'https://i.pravatar.cc/150',
      question: question,
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      optionTexts: options,
      pollType: _pollType,
      endsAt: _endsAt,
    );

    // Also push a local notification so user feels real-time response
    notifProvider.addNotification(
      title: 'New Poll Published',
      message: 'Your poll "$question" is now live for community voting!',
      type: NotificationType.newPoll,
      relatedPollId: newPoll.id,
    );

    setState(() {
      _isCreating = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Poll published successfully to community!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create New Poll'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question Input
              CustomTextField(
                controller: _questionController,
                label: 'Poll Question *',
                hintText: 'e.g. Should we install EV charging stations?',
                maxLines: 2,
              ),

              const SizedBox(height: 18),

              // Description Input
              CustomTextField(
                controller: _descriptionController,
                label: 'Context & Details (Optional)',
                hintText: 'Add background information, cost estimates, or dates to help neighbors decide...',
                maxLines: 3,
              ),

              const SizedBox(height: 20),

              // Category Selection
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.defaultCategories
                    .where((c) => c != 'All')
                    .map((cat) {
                  final isSelected = _selectedCategory == cat;
                  final catColors = AppColors.getCategoryColors(cat);

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? catColors.color : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? catColors.color : AppColors.border,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: catColors.color.withValues(alpha: 0.28),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : AppColors.softShadow,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            catColors.icon,
                            size: 15,
                            color: isSelected ? Colors.white : catColors.color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Options section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Voting Choices',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${_optionControllers.length} of 8 max',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ...List.generate(_optionControllers.length, (index) {
                final letter = String.fromCharCode(65 + index);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          letter,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomTextField(
                          controller: _optionControllers[index],
                          hintText: 'Option ${index + 1}',
                        ),
                      ),
                      if (_optionControllers.length > 2) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                          onPressed: () => _removeOption(index),
                        ),
                      ],
                    ],
                  ),
                );
              }),

              // Add Option button
              InkWell(
                onTap: _addOption,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline_rounded, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Add Another Option',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Poll Type (Public / Anonymous)
              const Text(
                'Voting Privacy',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _pollType = PollType.public),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _pollType == PollType.public ? AppColors.primaryContainer : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _pollType == PollType.public ? AppColors.primary : AppColors.border,
                            width: _pollType == PollType.public ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.public_rounded,
                                  size: 18,
                                  color: _pollType == PollType.public ? AppColors.primary : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Public',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: _pollType == PollType.public ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Voter counts visible',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _pollType = PollType.anonymous),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _pollType == PollType.anonymous ? AppColors.primaryContainer : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _pollType == PollType.anonymous ? AppColors.primary : AppColors.border,
                            width: _pollType == PollType.anonymous ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: 18,
                                  color: _pollType == PollType.anonymous ? AppColors.primary : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Secret Ballot',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: _pollType == PollType.anonymous ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Individual choices hidden',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // End Date Selection
              const Text(
                'Voting Deadline',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormatter.formatDateTime(_endsAt),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Closes in ${DateFormatter.formatClosesIn(_endsAt)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.edit_calendar_rounded, color: AppColors.primary, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Publish Button
              CustomButton(
                text: 'Publish Community Poll',
                width: double.infinity,
                icon: Icons.rocket_launch_rounded,
                isLoading: _isCreating,
                onPressed: _submitPoll,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
