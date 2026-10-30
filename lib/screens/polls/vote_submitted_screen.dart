import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/custom_painters.dart';
import '../../models/poll_model.dart';
import '../../widgets/common/custom_button.dart';
import '../main/main_shell.dart';
import 'poll_results_screen.dart';

class VoteSubmittedScreen extends StatefulWidget {
  final PollModel poll;

  const VoteSubmittedScreen({super.key, required this.poll});

  @override
  State<VoteSubmittedScreen> createState() => _VoteSubmittedScreenState();
}

class _VoteSubmittedScreenState extends State<VoteSubmittedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _confettiController;
  final List<ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initParticles();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        _updateParticles();
        setState(() {});
      });
    _confettiController.repeat();
  }

  void _initParticles() {
    final colors = [
      AppColors.primary,
      AppColors.chartTeal,
      AppColors.chartGreen,
      AppColors.chartAmber,
      AppColors.chartPink,
      AppColors.chartPurple,
    ];

    for (int i = 0; i < 40; i++) {
      _particles.add(
        ConfettiParticle(
          x: _random.nextDouble(),
          y: _random.nextDouble() * 0.4,
          size: _random.nextDouble() * 8 + 6,
          color: colors[_random.nextInt(colors.length)],
          speedY: _random.nextDouble() * 0.003 + 0.002,
          speedX: (_random.nextDouble() - 0.5) * 0.002,
          rotation: _random.nextDouble() * 2 * math.pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.1,
        ),
      );
    }
  }

  void _updateParticles() {
    for (var p in _particles) {
      p.y += p.speedY;
      p.x += p.speedX;
      p.rotation += p.rotationSpeed;
      if (p.y > 1.0) {
        p.y = -0.05;
        p.x = _random.nextDouble();
      }
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated Confetti Painter
          Positioned.fill(
            child: CustomPaint(
              painter: ConfettiPainter(particles: _particles),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Ballot Box Graphic with Checkmark
                  Center(
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        // Ballot Box Container
                        Container(
                          width: 140,
                          height: 140,
                          margin: const EdgeInsets.only(top: 25),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF4F46E5),
                                Color(0xFF3730A3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Top slot
                              Positioned(
                                top: 16,
                                child: Container(
                                  width: 64,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                              // Shield / Badge icon on box
                              Icon(
                                Icons.verified_user_rounded,
                                size: 42,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ],
                          ),
                        ),

                        // Green Success Checkmark Badge
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.success.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 30),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Title
                  const Text(
                    'Thank you!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Subtitle
                  const Text(
                    'Your vote has been\nsuccessfully submitted.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const Spacer(),

                  // "Back to Home" Button
                  CustomButton(
                    text: 'Back to Home',
                    width: double.infinity,
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MainShell()),
                        (route) => false,
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // "View Results" Button
                  CustomButton(
                    text: 'View Results',
                    width: double.infinity,
                    variant: ButtonVariant.text,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PollResultsScreen(poll: widget.poll),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
