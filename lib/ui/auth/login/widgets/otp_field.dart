import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/themes/colors.dart';

/// Saisie OTP segmentee (une case par chiffre) : auto-avance, backspace,
/// collage d'un code complet, et `autofillHints: oneTimeCode`.
class OtpField extends StatefulWidget {
  const OtpField({
    super.key,
    this.length = 6,
    required this.onChanged,
    this.onCompleted,
    this.enabled = true,
  });

  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final bool enabled;

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  late final List<TextEditingController> _controllers =
      List.generate(widget.length, (_) => TextEditingController());
  late final List<FocusNode> _nodes =
      List.generate(widget.length, (_) => FocusNode());

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

  void _distribute(String pasted, int start) {
    final digits = pasted.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;
    for (var i = 0; i < widget.length; i++) {
      final src = i - start;
      if (i >= start && src < digits.length) _controllers[i].text = digits[src];
    }
    final filled = (start + digits.length).clamp(0, widget.length);
    _nodes[filled >= widget.length ? widget.length - 1 : filled].requestFocus();
    _emit();
  }

  void _onChanged(int index, String raw) {
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
        children: List.generate(widget.length, _box),
      ),
    );
  }

  Widget _box(int index) {
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
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          decoration: const InputDecoration(counterText: ''),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) => _onChanged(index, v),
          onTap: () => _controllers[index].selection =
              TextSelection.collapsed(offset: _controllers[index].text.length),
        ),
      ),
    );
  }
}

/// Bouton de connexion par empreinte.
class BiometricButton extends StatelessWidget {
  const BiometricButton({super.key, required this.onPressed, this.busy = false});

  final VoidCallback onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: busy ? null : onPressed,
      icon: const Icon(Icons.fingerprint, color: AppColors.orange, size: 26),
      label: const Text("Se connecter avec l'empreinte"),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.orange, width: 1.4),
      ),
    );
  }
}
