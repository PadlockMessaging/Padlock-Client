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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:padlock_messaging/services/auth_service.dart';
import 'package:padlock_messaging/screens/main/shell.dart';
import 'package:padlock_messaging/screens/auth/enter_name.dart';

class SmsVerificationPage extends StatefulWidget {
  final String phoneNumber;

  const SmsVerificationPage({super.key, required this.phoneNumber});

  @override
  State<SmsVerificationPage> createState() => _SmsVerificationPageState();
}

class _SmsVerificationPageState extends State<SmsVerificationPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  bool _isLoading = false;
  // ignore: unused_field
  String? _error;

  void _onDigitEntered(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      _verify();
    }
  }

  Future<void> _verify() async {
    final code = _controllers.map((c) => c.text).join();
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await AuthService.verifySmsCode(code);

      if (context.mounted) {
        final userInfo = await AuthService.getUserInfo();
        if (!context.mounted) return;

        if (userInfo?['name'] == null || userInfo!['name']!.isEmpty) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const NameEntryPage()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const Shell(title: "Padlock Messaging")),
            (route) => false,
          );
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) { c.dispose(); }
    for (var f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: Theme.of(context).colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Check your\nmessages.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                      color: Color(0xFF888888), fontSize: 14),
                  children: [
                    const TextSpan(text: 'Code sent to '),
                    TextSpan(
                      text: widget.phoneNumber,
                      style: const TextStyle(
                          color: Color(0xFFF9B233),
                          fontWeight: FontWeight.bold),                        
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 46,
                    height: 56,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      onChanged: (v) => _onDigitEntered(v, index),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF2A2A2A)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF2A2A2A)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFF9B233), width: 2),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              // Resend
              Row(
                children: [
                  const Text("Didn't receive it? ",
                      style: TextStyle(
                          color: Color(0xFF888888), fontSize: 14)),
                  GestureDetector(
                    onTap: () {
                    },
                    child: const Text(
                      'Resend',
                      style: TextStyle(
                        color: Color(0xFFF9B233),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: const Color(0xFF0A0A0A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF0A0A0A),
                          ),
                        )
                      : const Text(
                          'Confirm',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}