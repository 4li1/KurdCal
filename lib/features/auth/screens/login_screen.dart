import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/kurdish_painters.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _sunPulseController;

  @override
  void initState() {
    super.initState();
    _sunPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _sunPulseController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    // Simulate a brief loading feel
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isLoading = false);
      widget.onLoginSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.loginGradient,
        ),
        child: Stack(
          children: [
            // Top Kilim border
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: KilimBorderWidget(
                height: 50,
                color: AppColors.sunGold,
                opacity: 0.07,
              ),
            ),

            // Bottom Kilim border
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: KilimBorderWidget(
                height: 50,
                color: AppColors.sunGold,
                opacity: 0.07,
                flipVertical: true,
              ),
            ),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  height: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),

                      // ── Sun Logo ───────────────────────────────
                      AnimatedBuilder(
                        animation: _sunPulseController,
                        builder: (context, child) {
                          final glowIntensity =
                              12.0 + (_sunPulseController.value * 8.0);
                          return KurdishSunWidget(
                            size: 160,
                            color: AppColors.sunGold,
                            glowColor: AppColors.sunGold.withOpacity(0.3),
                            glowRadius: glowIntensity,
                          );
                        },
                      )
                          .animate()
                          .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                          .scale(
                            begin: const Offset(0.7, 0.7),
                            end: const Offset(1.0, 1.0),
                            duration: 800.ms,
                            curve: Curves.easeOutBack,
                          ),

                      const SizedBox(height: 28),

                      // ── App Title ──────────────────────────────
                      Text(
                        'ساڵنامەی کوردستان',
                        style: AppTypography.textTheme.displayMedium!.copyWith(
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: AppColors.sunGold.withOpacity(0.3),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 600.ms),

                      const SizedBox(height: 8),

                      Text(
                        'Kurdistan Calendar',
                        style: AppTypography.textTheme.bodyMedium!.copyWith(
                          color: Colors.white.withOpacity(0.5),
                          letterSpacing: 3,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(delay: 500.ms, duration: 600.ms),

                      const SizedBox(height: 48),

                      // ── Glassmorphism Input: Username ──────────
                      _GlassInput(
                        controller: _usernameController,
                        hintText: 'ناوی بەکارهێنەر',
                        icon: Icons.person_outline_rounded,
                      )
                          .animate()
                          .fadeIn(delay: 600.ms, duration: 500.ms)
                          .slideY(begin: 0.3, end: 0, delay: 600.ms, duration: 500.ms),

                      const SizedBox(height: 16),

                      // ── Glassmorphism Input: Password ──────────
                      _GlassInput(
                        controller: _passwordController,
                        hintText: 'وشەی نهێنی',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white.withOpacity(0.4),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 700.ms, duration: 500.ms)
                          .slideY(begin: 0.3, end: 0, delay: 700.ms, duration: 500.ms),

                      const SizedBox(height: 32),

                      // ── Login Button ───────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.kurdishRed,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                AppColors.kurdishRed.withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 8,
                            shadowColor: AppColors.kurdishRed.withOpacity(0.4),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  'بچۆ ژوورەوە',
                                  style: AppTypography.textTheme.labelLarge!
                                      .copyWith(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 500.ms)
                          .slideY(begin: 0.3, end: 0, delay: 800.ms, duration: 500.ms),

                      const Spacer(flex: 2),

                      // ── Footer ─────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          KurdishSunWidget(
                            size: 14,
                            color: Colors.white.withOpacity(0.25),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'v1.0.0',
                            style: AppTypography.textTheme.labelSmall!.copyWith(
                              color: Colors.white.withOpacity(0.25),
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(delay: 1000.ms, duration: 600.ms),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Glassmorphism-style semi-transparent text field.
class _GlassInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;

  const _GlassInput({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: AppTypography.textTheme.bodyLarge!.copyWith(
              color: Colors.white,
            ),
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTypography.textTheme.bodyMedium!.copyWith(
                color: Colors.white.withOpacity(0.35),
              ),
              prefixIcon: Icon(
                icon,
                color: AppColors.sunGold.withOpacity(0.6),
                size: 22,
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
