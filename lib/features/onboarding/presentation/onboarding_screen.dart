import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/providers.dart';
import '../../../shared/widgets/brand_logo.dart';

/// Un panneau de l'onboarding.
class _Slide {
  const _Slide({required this.icon, required this.title, required this.text});
  final IconData icon;
  final String title;
  final String text;
}

const _slides = <_Slide>[
  _Slide(
    icon: Icons.play_circle_fill,
    title: 'Le shopping en video',
    text: 'Decouvrez les produits en video, comme sur vos reseaux preferes. '
        'Faites defiler, le son d\'un simple geste.',
  ),
  _Slide(
    icon: Icons.verified_user,
    title: 'Achetez en confiance',
    text: 'Vendeurs verifies, avis clients, et un code de confirmation remis '
        'au livreur a la reception.',
  ),
  _Slide(
    icon: Icons.smartphone,
    title: 'Payez par Mobile Money',
    text: 'Orange, MTN, Moov, Wave. Suivez votre commande en temps reel, '
        'directement dans l\'application.',
  ),
];

/// Onboarding affiche au tout premier lancement.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  /// Appele quand l'utilisateur termine ou passe l'onboarding.
  final VoidCallback onDone;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _index == _slides.length - 1;

  Future<void> _finish() async {
    await ref.read(localStoreProvider).markOnboardingSeen();
    widget.onDone();
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(
                children: [
                  const BrandLogo(size: 30),
                  const Spacer(),
                  if (!_isLast)
                    TextButton(
                      onPressed: _finish,
                      child: const Text('Passer'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
              ),
            ),
            _Dots(count: _slides.length, index: _index),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(_isLast ? 'Commencer' : 'Suivant'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(slide.icon, size: 56, color: AppColors.orange),
          ),
          const SizedBox(height: 32),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            slide.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: active ? 24 : 8,
          decoration: BoxDecoration(
            color: active ? AppColors.orange : AppColors.gray300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
