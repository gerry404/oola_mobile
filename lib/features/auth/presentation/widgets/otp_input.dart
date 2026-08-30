import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';

/// Champ de saisie OTP segmente (une case par chiffre).
///
/// - Auto-avance a la frappe, recul au backspace.
/// - Collage d'un code complet (depuis le presse-papier) reparti sur les cases.
/// - `autofillHints: oneTimeCode` : iOS propose le code recu, Android tente le
///   remplissage automatique (SMS Retriever). Pour un OTP par email, le systeme
///   ne peut pas l'auto-lire : le collage reste le geste le plus rapide.
/// - Appelle [onCompleted] quand les [length] chiffres sont saisis.
class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    this.length = 6,
    required this.onChanged,
    this.onCompleted,
    this.enabled = true,
    this.hasError = false,
  });

  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final bool enabled;
  final bool hasError;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _value => _controllers.map((c) => c.text).join();

  void _emit() {
    final v = _value;
    widget.onChanged(v);
    if (v.length == widget.length && !v.contains(' ')) {
      widget.onCompleted?.call(v);
      FocusScope.of(context).unfocus();
    }
  }

  /// Repartit un collage (ex. "123456") sur toutes les cases.
  void _distribute(String pasted, int startIndex) {
    final digits = pasted.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;
    for (var i = 0; i < widget.length; i++) {
      final srcIndex = i - startIndex;
      if (i >= startIndex && srcIndex < digits.length) {
        _controllers[i].text = digits[srcIndex];
      }
    }
    final filled = (startIndex + digits.length).clamp(0, widget.length);
    final target = filled >= widget.length ? widget.length - 1 : filled;
    _nodes[target].requestFocus();
    _emit();
  }

  void _onChanged(int index, String raw) {
    // Collage multi-caracteres (autofill ou paste).
    if (raw.length > 1) {
      _distribute(raw, index);
      return;
    }
    if (raw.isNotEmpty && index < widget.length - 1) {
      _nodes[index + 1].requestFocus();
    }
    _emit();
  }

  KeyEventResult _onKey(int index, FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _nodes[index - 1].requestFocus();
      _emit();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(widget.length, (i) => _box(i)),
      ),
    );
  }

  Widget _box(int index) {
    final borderColor = widget.hasError
        ? AppColors.danger
        : (_nodes[index].hasFocus ? AppColors.orange : AppColors.gray200);

    return SizedBox(
      width: 48,
      height: 56,
      child: Focus(
        onKeyEvent: (node, event) => _onKey(index, node, event),
        child: TextField(
          controller: _controllers[index],
          focusNode: _nodes[index],
          enabled: widget.enabled,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: index == 0 ? widget.length : 1,
          autofillHints: index == 0 ? const [AutofillHints.oneTimeCode] : null,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            filled: true,
            fillColor: widget.enabled ? Colors.white : AppColors.gray100,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor, width: 1.4),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.hasError ? AppColors.danger : AppColors.orange,
                width: 1.8,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) => _onChanged(index, v),
          onTap: () {
            // Repositionne le curseur en fin de champ.
            _controllers[index].selection = TextSelection.collapsed(
              offset: _controllers[index].text.length,
            );
            setState(() {});
          },
        ),
      ),
    );
  }
}
