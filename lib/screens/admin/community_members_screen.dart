import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/community_provider.dart';
import '../../widgets/admin/member_tile.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class CommunityMembersScreen extends StatefulWidget {
  const CommunityMembersScreen({super.key});

  @override
  State<CommunityMembersScreen> createState() => _CommunityMembersScreenState();
}

class _CommunityMembersScreenState extends State<CommunityMembersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showInviteModal(BuildContext context, CommunityProvider provider) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    UserRole selectedRole = UserRole.member;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Invite Member', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: nameCtrl,
                label: 'Full Name',
                hintText: 'e.g. John Doe',
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: emailCtrl,
                label: 'Email Address',
                hintText: 'john@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              const Text('Assign Role', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Member'),
                    selected: selectedRole == UserRole.member,
                    onSelected: (v) => setModalState(() => selectedRole = UserRole.member),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('Admin'),
                    selected: selectedRole == UserRole.admin,
                    onSelected: (v) => setModalState(() => selectedRole = UserRole.admin),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Send Invitation',
                width: double.infinity,
                onPressed: () {
                  if (nameCtrl.text.trim().isNotEmpty && emailCtrl.text.trim().isNotEmpty) {
                    provider.inviteMember(
                      name: nameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      role: selectedRole,
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invitation sent successfully!')),
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
    final communityProvider = context.watch<CommunityProvider>();
    final members = communityProvider.filteredMembers;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Members'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
            label: const Text(
              'Invite',
              style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
            onPressed: () => _showInviteModal(context, communityProvider),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => communityProvider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search members...',
                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),

          // Filter Tabs: [All (128)] | [Admins (3)] | [Members (125)]
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All (${communityProvider.totalMembersCount})',
                  key: 'all',
                  provider: communityProvider,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Admins (${communityProvider.adminMembersCount})',
                  key: 'admin',
                  provider: communityProvider,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Members (${communityProvider.regularMembersCount})',
                  key: 'member',
                  provider: communityProvider,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Members List
          Expanded(
            child: members.isEmpty
                ? const Center(
                    child: Text('No members found matching your search', style: TextStyle(color: AppColors.textSecondary)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return MemberTile(
                        member: member,
                        onToggleRole: () {
                          final newRole = member.isAdmin ? UserRole.member : UserRole.admin;
                          communityProvider.updateMemberRole(member.id, newRole);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Updated ${member.name} to ${newRole.name}')),
                          );
                        },
                        onRemove: () {
                          communityProvider.removeMember(member.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Removed ${member.name}')),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String key,
    required CommunityProvider provider,
  }) {
    final isSelected = provider.memberFilter == key;
    return GestureDetector(
      onTap: () => provider.setMemberFilter(key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
