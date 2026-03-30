import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/di.dart';
import '../../../auth/data/data_source/local_data_source/auth_local_data_source.dart';
import '../../../../app/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasToken = false;

  @override
  void initState() {
    super.initState();

    // Token is considered valid when it is non-null and non-empty.
    final local = getIt<AuthLocalDataSource>();
    final token = local.getToken();
    _hasToken = token != null && token.trim().isNotEmpty;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );

    _controller.addStatusListener((status) {
      if (status != AnimationStatus.completed) return;

      final targetRoute =
          _hasToken ? AppRoutes.home : AppRoutes.login;

      if (!mounted) return;
      context.go(targetRoute);
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = _controller;
    final fade = CurvedAnimation(parent: t, curve: const Interval(0.2, 1));
    final scale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: t, curve: const Interval(0.25, 0.9)),
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: t, curve: const Interval(0.35, 1)),
    );
    final rotate = Tween<double>(begin: -0.08, end: 0).animate(
      CurvedAnimation(parent: t, curve: const Interval(0.1, 0.7)),
    );

    return AnimatedBuilder(
      animation: t,
      builder: (context, child) {
        final v = t.value;
        final begin = Alignment(-1 + (2 * v), -1 + (v * 0.6));
        final end = Alignment(1 - (2 * v * 0.35), 1);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: begin,
                    end: end,
                    colors: const [
                      Color(0xFF0EA5E9),
                      Color(0xFF7C3AED),
                      Color(0xFF111827),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
              // Light sweep
              Positioned.fill(
                child: Opacity(
                  opacity: (0.25 + (0.35 * v)).clamp(0.0, 1.0),
                  child: Transform.rotate(
                    angle: -0.08,
                    child: Align(
                      alignment: Alignment(-1, 0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFFFFFFF),
                              Color(0x80FFFFFF),
                              Color(0x00FFFFFF),
                            ],
                            stops: [0.0, 0.35, 1.0],
                          ),
                        ),
                        transform: Matrix4.translationValues(500 * v, 0, 0),
                      ),
                    ),
                  ),
                ),
              ),

              // Floating blobs
              Positioned(
                top: 80 * (1 - v),
                left: -40,
                child: _Blob(
                  size: 120,
                  color: const Color(0x66FFFFFF),
                  opacity: 0.25 + (0.25 * v),
                ),
              ),
              Positioned(
                bottom: 60 * (1 - v),
                right: -50,
                child: _Blob(
                  size: 170,
                  color: const Color(0x66FFFFFF),
                  opacity: 0.12 + (0.28 * v),
                ),
              ),

              SafeArea(
                child: Center(
                  child: FadeTransition(
                    opacity: fade,
                    child: SlideTransition(
                      position: slide,
                      child: ScaleTransition(
                        scale: scale,
                        child: RotationTransition(
                          turns: rotate,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 24),
                              _LogoMark(progress: v),
                              const SizedBox(height: 18),
                              Text(
                                'One App',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: 160,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    minHeight: 6,
                                    backgroundColor:
                                        Colors.white.withOpacity(0.12),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      Color(0xFFFFFFFF),
                                    ),
                                    value: v,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _Blob({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  final double progress;

  const _LogoMark({required this.progress});

  @override
  Widget build(BuildContext context) {
    final glow = (0.4 + 0.6 * progress).clamp(0.0, 1.0);
    return SizedBox(
      height: 92,
      width: 92,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0x80FFFFFF)],
              ),
              boxShadow: [
                BoxShadow(
                color: Colors.white.withOpacity(0.28 * glow),
                  blurRadius: 40,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
          Icon(
            Icons.flash_on_rounded,
            size: 42,
          color: Colors.black.withOpacity(0.88),
          ),
          Positioned(
            bottom: 10,
            right: 12,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.92),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

