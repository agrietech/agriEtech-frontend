import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/agrietech_logo.dart';
import '../providers/auth_provider.dart';

/// Splash screen displayed on initial app launch with rich Ethiopian branding
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();

    // Fallback timer ensures the app never hangs on splash
    _fallbackTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        final authState = ref.read(authProvider);
        if (authState.isInitializing) {
          // Force refresh router redirect if initialization timed out
          GoRouter.of(context).refresh();
        }
      }
    });
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [
                    Color(0xFF0D2E14),
                    Color(0xFF091F0E),
                    Color(0xFF051208),
                  ]
                : const [
                    Color(0xFFF1F8F1),
                    Color(0xFFE8F5E9),
                    Color(0xFFDCEFDC),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Animated Logo & Wordmark
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: const AgriEtechLogo.hero(
                    size: 92,
                    showTagline: true,
                    customTagline: 'EARLY WARNING & ADVISORY SYSTEM',
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Elegant Spinner & Status Text
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.8,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? const Color(0xFFF59E0B) : const Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Securing Agricultural Resilience...',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.4,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
