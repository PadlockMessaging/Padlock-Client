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
import 'package:padlock_messaging/screens/auth/welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {

  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const PadlockApp());
}

class PadlockApp extends StatelessWidget {
  const PadlockApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return MaterialApp(
      title: 'Padlock Messaging', 
      theme: ThemeData(
        appBarTheme: AppBarTheme(),
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFF9B233),
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: const Color(0xFFF9B233),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(fontWeight: FontWeight.bold);
            }
            return const TextStyle(fontWeight: FontWeight.normal);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.white);
            }
            return const IconThemeData(color: Colors.grey);
          }),
        ),
      ),

      darkTheme: ThemeData(
        appBarTheme: AppBarTheme(),
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF9B233),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF1E1E1E),
          indicatorColor: const Color(0xFFF9B233),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontWeight: FontWeight.bold,
              );
            }
            return const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.grey,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.white);
            }
            return const IconThemeData(color: Colors.grey);
          }),
        ),
      ),

      themeMode: ThemeMode.system,
      home: const Welcome());
  }
}
