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
import 'enter_phone.dart';
import 'dart:math';
import 'dart:async';
import '../../services/auth_service.dart';
import '../main/shell.dart';

class _EncryptedTextEffect extends StatefulWidget {
  final String text;
  final TextStyle style;
  final bool tapToScramble;

  const _EncryptedTextEffect({required this.text, required this.style, this.tapToScramble = false});

  @override
  State<_EncryptedTextEffect> createState() => _EncryptedTextEffectState();
}

class _EncryptedTextEffectState extends State<_EncryptedTextEffect> {
  static const _chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*<>?/';
  final Random _random = Random();
  late List<String> _displayed;
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    _displayed = List.generate(widget.text.length, (i) {
      final ch = widget.text[i];
      return (ch == '\n' || ch == ' ') ? ch : _randomChar();
    });
    _startEffect();

    _timers.add(
      Timer.periodic(const Duration(seconds: 15), (_) {
        _startEffect();
      }),
    );
  }

  String _randomChar() => _chars[_random.nextInt(_chars.length)];

  void _startEffect() {
    const staggerDelay = Duration(milliseconds: 60);
    const scrambleDuration = Duration(milliseconds: 400);
    const scrambleInterval = Duration(milliseconds: 50);

    int letterIndex = 0;

    for (int i = 0; i < widget.text.length; i++) {
      final ch = widget.text[i];
      if (ch == '\n' || ch == ' ') continue;

      final capturedIndex = i;
      final revealDelay = staggerDelay * letterIndex;

      // Scramble until reveal
      final scramble = Timer.periodic(scrambleInterval, (t) {
        if (!mounted) { t.cancel(); return; }
        setState(() => _displayed[capturedIndex] = _randomChar());
      });
      _timers.add(scramble);

      // Reveal the real character
      final reveal = Timer(revealDelay + scrambleDuration, () {
        scramble.cancel();
        if (!mounted) return;
        setState(() => _displayed[capturedIndex] = ch);
      });
      _timers.add(reveal);

      letterIndex++;
    }
  }

  @override
  void dispose() {
    for (final t in _timers) { t.cancel(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.tapToScramble ? _startEffect : null,
      child: Text(
        _displayed.join(),
        style: widget.style,
      ),
    );
  }
}

class Init extends StatelessWidget {
  const Init({super.key});

  @override
  Widget build(BuildContext context) {

  return FutureBuilder<bool>(
      future: AuthService.verifySession(),
      builder: (context, snapshot) {
        // Still checking
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Session exists → redirect to shell
        if (snapshot.data == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const Shell(title: "Padlock Messaging")),
              (route) => false,
            );
          });
        }
    
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/images/PadlockMP.png',
                      width: 72,
                      height: 72,
                    ),
                  ),
                  const SizedBox(height: 32),
                    _EncryptedTextEffect(
                      text: 'Welcome to\nPadlock Messaging.',
                      tapToScramble: true,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -1.5,
                      ),
                    ),
                  const SizedBox(height:10),
                    _EncryptedTextEffect(
                      text: 'Your secure communication\nstarts here.',
                      tapToScramble: true,
                      style: TextStyle(
                        color: const Color(0xFF888888),
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  const Spacer(flex: 3),
                  // Phone login button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PhoneEntryPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: const Color(0xFF0A0A0A),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Continue with Phone',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}