import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/routes.dart';
import '../../../core/themes/colors.dart';
import '../../../core/themes/dimens.dart';
import '../../../core/ui/brand_logo.dart';

/// Ecran d'entree (non connecte) : on ne jette plus l'utilisateur directement
/// sur un champ email. Il choisit d'abord « Creer un compte » ou « Se
/// connecter », comme dans une app classique.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: Dimens.of(context).edgeInsetsScreenSymmetric,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  const Center(child: BrandLogo(size: 84)),
                  const SizedBox(height: 28),
                  const Text(
                    'Le shopping en vidéo, livré à Abidjan',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Crée ton compte en quelques secondes avec ton email : '
                    'pas de mot de passe à retenir, un simple code suffit.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: AppColors.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 36),
                  ElevatedButton(
                    onPressed: () =>
                        context.go('${Routes.login}?mode=register'),
                    child: const Text('Créer un compte'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.go(Routes.login),
                    child: const Text("J'ai déjà un compte"),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () =>
                        context.go('${Routes.login}?mode=staff'),
                    child: const Text('Espace vendeur / livreur'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
