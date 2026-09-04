import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Canal natif FLAG_SECURE (anti-capture d'ecran + apercu multitache).
const MethodChannel _channel = MethodChannel('oola/secure_screen');

Future<void> _setSecure(bool enabled) async {
  try {
    await _channel.invokeMethod(enabled ? 'enable' : 'disable');
  } catch (_) {
    // Plateforme sans implementation (ex. iOS) : ignore.
  }
}

/// Protege un ecran sensible (paiement, portefeuille, code de livraison).
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
