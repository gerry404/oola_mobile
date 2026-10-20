import 'package:flutter/material.dart';

/// Champ mot de passe avec bouton oeil (afficher / masquer). S'appuie sur le
/// thème global (InputDecorationTheme) pour rester cohérent partout.
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    required this.controller,
    this.label = 'Mot de passe',
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints = const [AutofillHints.password],
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;
  final bool enabled;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: _hidden,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      autofillHints: widget.autofillHints,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: IconButton(
          icon: Icon(
            _hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          ),
          onPressed: () => setState(() => _hidden = !_hidden),
          tooltip: _hidden ? 'Afficher' : 'Masquer',
        ),
      ),
    );
  }
}
