import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/user_avatar.dart';
import '../admin/admin_dashboard_screen.dart';
import '../auth/welcome_screen.dart';
import '../community/community_selection_screen.dart';
import 'user_polls_screen.dart';
import 'user_votes_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Profile Header Card
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.18),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: UserAvatar(
                            imageUrl: user?.avatarUrl ?? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
                            name: user?.name ?? 'Priya Patel',
                            radius: 46,
                          ),
                        ),
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: AppColors.softShadow,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user?.name ?? 'Priya Patel',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      user?.email ?? 'priya.patel@example.com',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    StatusBadge(
                      text: (user?.isAdmin ?? false) ? '🛡️ Admin Account' : '✓ Verified Resident',
                      type: (user?.isAdmin ?? false) ? BadgeType.admin : BadgeType.member,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Resident Activity Stats Row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppColors.softShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(value: '14', label: 'Votes Cast', color: AppColors.primary),
                    Container(height: 30, width: 1, color: AppColors.borderLight),
                    _buildStatItem(value: '3', label: 'Polls Made', color: const Color(0xFF0284C7)),
                    Container(height: 30, width: 1, color: AppColors.borderLight),
                    _buildStatItem(value: '28', label: 'Comments', color: const Color(0xFFD97706)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Menu Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppColors.softShadow,
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    children: [
                      _buildModernMenuItem(
                        icon: Icons.groups_rounded,
                        iconColor: const Color(0xFF4F46E5),
                        iconBg: const Color(0xFFEEF2FF),
                        title: 'My Communities',
                        subtitle: 'Switch or discover neighborhoods',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CommunitySelectionScreen()),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 68, endIndent: 16, color: AppColors.borderLight),
                      _buildModernMenuItem(
                        icon: Icons.ballot_rounded,
                        iconColor: const Color(0xFF0284C7),
                        iconBg: const Color(0xFFE0F2FE),
                        title: 'My Polls',
                        subtitle: 'Manage polls you have proposed',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const UserPollsScreen()),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 68, endIndent: 16, color: AppColors.borderLight),
                      _buildModernMenuItem(
                        icon: Icons.how_to_vote_rounded,
                        iconColor: const Color(0xFF059669),
                        iconBg: const Color(0xFFD1FAE5),
                        title: 'My Voting History',
                        subtitle: 'Review past ballots & decisions',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const UserVotesScreen()),
                          );
                        },
                      ),
                      if (auth.isAdmin) ...[
                        const Divider(height: 1, indent: 68, endIndent: 16, color: AppColors.borderLight),
                        _buildModernMenuItem(
                          icon: Icons.admin_panel_settings_rounded,
                          iconColor: const Color(0xFF7C3AED),
                          iconBg: const Color(0xFFF3E8FF),
                          title: 'Admin Dashboard',
                          subtitle: 'Manage community quorum & decisions',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                            );
                          },
                        ),
                      ],
                      const Divider(height: 1, indent: 68, endIndent: 16, color: AppColors.borderLight),
                      _buildModernMenuItem(
                        icon: Icons.settings_rounded,
                        iconColor: const Color(0xFF475569),
                        iconBg: const Color(0xFFF1F5F9),
                        title: 'Settings & Privacy',
                        subtitle: 'Notifications, dark mode & security',
                        onTap: () => _showSettingsSheet(context),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Switch Admin / Member Role Helper for easy demo inspection
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppColors.softShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: auth.isAdmin ? AppColors.primaryContainer : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            auth.isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                            color: auth.isAdmin ? AppColors.primary : AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.isAdmin ? 'Admin View Active' : 'Resident View Active',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            const Text(
                              'Tap to toggle role permissions',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        auth.toggleAdminRole();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              auth.isAdmin ? 'Switched to Admin View' : 'Switched to Resident View',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Toggle', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Logout Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.dangerBg),
                  boxShadow: AppColors.softShadow,
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.dangerBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 18),
                    ),
                    title: const Text(
                      'Log Out',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.danger, size: 20),
                    onTap: () {
                      auth.logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({required String value, required String label, required Color color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildModernMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 22),
          ],
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Settings & Preferences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: true,
                onChanged: (_) {},
                title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Receive alerts for new polls and decisions', style: TextStyle(fontSize: 12)),
                activeThumbColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                value: true,
                onChanged: (_) {},
                title: const Text('Anonymous Voting by Default', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Keep your personal choices private', style: TextStyle(fontSize: 12)),
                activeThumbColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Save Preferences',
                width: double.infinity,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
