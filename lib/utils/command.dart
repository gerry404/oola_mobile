// Architecture de reference : flutter/samples > compass_app.
// Pattern Command : encapsule une action asynchrone d'un ViewModel, expose ses
// etats (running/error/completed) et empeche les lancements concurrents.

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'result.dart';

typedef CommandAction0<T> = Future<Result<T>> Function();
typedef CommandAction1<T, A> = Future<Result<T>> Function(A);

/// Base des commandes. Une action retourne toujours un [Result].
abstract class Command<T> extends ChangeNotifier {
  Command();

  bool _running = false;
  bool get running => _running;

  Result<T>? _result;

  /// true si la derniere execution a echoue.
  bool get error => _result is Error;

  /// true si la derniere execution a reussi.
  bool get completed => _result is Ok;

  /// Dernier resultat (pour lire la valeur/erreur).
  Result<T>? get result => _result;

  /// Reinitialise le resultat une fois consomme.
  void clearResult() {
    _result = null;
    notifyListeners();
  }

  Future<void> _execute(CommandAction0<T> action) async {
    if (_running) return; // empeche les doubles taps
    _running = true;
    _result = null;
    notifyListeners();
    try {
      _result = await action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

/// Commande sans argument.
class Command0<T> extends Command<T> {
  Command0(this._action);
  final CommandAction0<T> _action;

  Future<void> execute() => _execute(_action);
}

/// Commande avec un argument.
class Command1<T, A> extends Command<T> {
  Command1(this._action);
  final CommandAction1<T, A> _action;

  Future<void> execute(A argument) => _execute(() => _action(argument));
}
