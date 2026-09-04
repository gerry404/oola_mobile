import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../auth/splash/widgets/splash_screen.dart';
import '../../client/widgets/client_shell.dart';
import '../../delivery/widgets/delivery_shell.dart';
import '../../vendor/widgets/vendor_shell.dart';

/// Point d'entree apres authentification : charge l'utilisateur courant si
/// besoin puis affiche la coquille correspondant a son role.
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthRepository>();
    if (auth.currentUser == null) {
      auth.loadCurrentUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthRepository>(
      builder: (context, auth, _) {
        final user = auth.currentUser;
        if (user == null) return const SplashScreen();
        return switch (user.role) {
          _ when user.role.isVendor => const VendorShell(),
          _ when user.role.isDelivery => const DeliveryShell(),
          _ => const ClientShell(),
        };
      },
    );
  }
}
