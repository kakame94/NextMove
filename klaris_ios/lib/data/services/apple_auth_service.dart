import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Sign in with Apple — required by App Store guidelines whenever other
/// social providers are offered.
///
/// Flow:
///   1. Generate raw nonce, hash it (SHA256) for the request.
///   2. Apple returns identityToken + authorizationCode.
///   3. Hand identityToken + raw nonce to Supabase auth.signInWithIdToken.
///
/// Supabase project must have the Apple provider enabled (Authentication
/// → Providers → Apple) with the Service ID + Team ID + key configured.
class AppleAuthService {
  AppleAuthService._();
  static final instance = AppleAuthService._();

  Future<bool> isAvailable() => SignInWithApple.isAvailable();

  Future<AuthResponse?> signIn() async {
    final rawNonce = _generateNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    try {
      final cred = await SignInWithApple.getAppleIDCredential(
        scopes: const [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
        nonce: hashedNonce,
      );
      final idToken = cred.identityToken;
      if (idToken == null) throw const AuthException('No identity token from Apple');

      final res = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
      return res;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;
      if (kDebugMode) debugPrint('apple-signin err: ${e.code} ${e.message}');
      rethrow;
    }
  }

  String _generateNonce({int length = 32}) {
    // Anti-replay nonce MUST come from a CSPRNG — a time-seeded LCG is
    // predictable and defeats the OIDC nonce binding.
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._';
    final r = Random.secure();
    final buf = StringBuffer();
    for (var i = 0; i < length; i++) {
      buf.write(chars[r.nextInt(chars.length)]);
    }
    return buf.toString();
  }
}
