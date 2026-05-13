import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthUser {
  final String email;
  final String displayName;

  const GoogleAuthUser({required this.email, required this.displayName});
}

class GoogleAuthService {
  GoogleAuthService._();

  static final GoogleAuthService instance = GoogleAuthService._();

  static const String _clientId = String.fromEnvironment('GOOGLE_CLIENT_ID');
  static const String _serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    await GoogleSignIn.instance.initialize(
      clientId: _clientId.isEmpty ? null : _clientId,
      serverClientId: _serverClientId.isEmpty ? null : _serverClientId,
    );
    _initialized = true;
  }

  Future<GoogleAuthUser> signIn() async {
    await initialize();
    final account = await GoogleSignIn.instance.authenticate();
    final name = account.displayName?.trim();

    return GoogleAuthUser(
      email: account.email,
      displayName: name == null || name.isEmpty ? account.email : name,
    );
  }
}
