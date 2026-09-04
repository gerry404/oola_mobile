import '../../../../data/repositories/auth/auth_repository.dart';
import '../../../../domain/models/user.dart';
import '../../../../utils/command.dart';
import '../../../../utils/result.dart';

/// ViewModel de connexion.
///
/// Parcours acheteur : email -> OTP -> (mot de passe si compte privilegie).
/// Plus la connexion par empreinte quand une session est memorisee.
class LoginViewModel {
  LoginViewModel({required AuthRepository authRepository})
      : _auth = authRepository {
    requestCode = Command1(_requestCode);
    verifyOtp = Command1(_verifyOtp);
    completePassword = Command1(_completePassword);
    passwordLogin = Command1(_completePassword);
    biometricLogin = Command0(_biometricLogin);
  }

  final AuthRepository _auth;

  late final Command1<void, String> requestCode;
  late final Command1<User, (String email, String code)> verifyOtp;
  late final Command1<void, (String identifier, String password)> completePassword;
  late final Command1<void, (String identifier, String password)> passwordLogin;
  late final Command0<void> biometricLogin;

  bool canBiometric = false;

  Future<void> checkBiometric() async {
    canBiometric = await _auth.canBiometricLogin();
  }

  Future<void> forgetSession() => _auth.logoutFull();

  Future<Result<void>> _requestCode(String email) =>
      _auth.requestClientCode(email);

  Future<Result<User>> _verifyOtp((String, String) c) =>
      _auth.clientLogin(email: c.$1, code: c.$2);

  Future<Result<void>> _completePassword((String, String) c) =>
      _auth.loginWithPassword(identifier: c.$1, password: c.$2);

  Future<Result<void>> _biometricLogin() => _auth.biometricLogin();
}
