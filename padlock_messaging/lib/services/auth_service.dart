/* 
    Padlock Messaging Project
    Copyright (C) <2026>  <Padlock Messaging>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'database_service.dart';
import '../config.dart';


class AuthService {
  static final _auth = FirebaseAuth.instance;
  static String? _verificationId;

  static const _apiBase = apiBase;

  // ─── Firebase SMS ─────────────────────────────────────────────────

  /// Sends an SMS verification code to the given phone number.
  /// Phone number must be in E.164 format
  static Future<void> sendSmsCode(String phoneNumber) async {
    await FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: true,
    ); // Remove or set to false in production!
    try {
      await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-resolution on Android (SMS auto-retrieval)
        await _handleCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw Exception('SMS send failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
      timeout: const Duration(seconds: 60),
    );
  } on FirebaseAuthException catch (e) {
      throw Exception('Firebase error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Verifies the code entered by the user.
  /// Returns true on success, throws on failure.
  static Future<bool> verifySmsCode(String code) async {
    if (_verificationId == null) {
      throw Exception('No verification in progress. Call sendSmsCode first.');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: code,
    );

    return await _handleCredential(credential);
  }

  // ─── Token Exchange ───────────────────────────────────────────────

  /// Signs in with credential, gets Firebase id_token, exchanges with FastAPI.
  static Future<bool> _handleCredential(PhoneAuthCredential credential) async {
    final userCredential = await _auth.signInWithCredential(credential);
    final idToken = await userCredential.user?.getIdToken();

    if (idToken == null) throw Exception('Failed to retrieve Firebase id_token.');

    return await _exchangeToken(idToken);
  }

  /// POSTs Firebase id_token to FastAPI, stores returned session tokens.
  static Future<bool> _exchangeToken(String idToken) async {
    final response = await http.post(
      Uri.parse('$_apiBase/auth/v1/login'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'accept': 'application/json',
      },
      body: {'id_token': idToken},
    );

    if (response.statusCode != 200) {
      throw Exception('Token exchange failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    await DatabaseService.insertSession(
      accessToken: data['access_token'],
      refreshToken: data['refresh_token'],
    );

    return true;
  }

  // ─── Session ──────────────────────────────────────────────────────

  /// Called by welcome.dart — returns true if a session exists.
  static Future<bool> verifySession() async {
    final session = await DatabaseService.getSession();
    return session != null;
  }

  /// Clears local session and signs out of Firebase.
  static Future<void> logout() async {
    await DatabaseService.clearSession();
    await _auth.signOut();
  }
}