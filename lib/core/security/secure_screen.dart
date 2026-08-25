import 'package:flutter/widgets.dart';
import 'package:screen_protector/screen_protector.dart';

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
    _protect();
  }

  Future<void> _protect() async {
    await ScreenProtector.preventScreenshotOn();
    await ScreenProtector.protectDataLeakageOn();
  }

  @override
  void dispose() {
    ScreenProtector.preventScreenshotOff();
    ScreenProtector.protectDataLeakageOff();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
