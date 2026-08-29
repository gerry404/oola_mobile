import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Canal natif pour activer/desactiver la protection anti-capture.
/// Cote Android : FLAG_SECURE (bloque captures + apercu multitache).
/// Cote iOS : non implemente pour l'instant -> l'appel echoue silencieusement.
const MethodChannel _secureChannel = MethodChannel('oola/secure_screen');

Future<void> _setSecure(bool enabled) async {
  try {
    await _secureChannel.invokeMethod(enabled ? 'enable' : 'disable');
  } catch (_) {
    // Plateforme sans implementation (ex. iOS) : on ignore.
  }
}

/// Protege un ecran sensible contre les captures d'ecran et l'apercu
/// multitache (cahier des charges 3.2 : paiement, portefeuille, code de
/// livraison).
///
/// Enveloppez l'ecran concerne dans [SecureScreen]. La protection est activee
/// au montage et retiree au demontage.
class SecureScreen extends StatefulWidget {
  const SecureScreen({super.key, required this.child});

  final Widget child;

  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen> {
  @override
  void initState() {
    super.initState();
    _setSecure(true);
  }

  @override
  void dispose() {
    _setSecure(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
