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
import 'package:padlock_messaging/tools/country_code.dart';
import 'verify_phone.dart';

class PhoneEntryPage extends StatefulWidget {
  const PhoneEntryPage({super.key});

  @override
  State<PhoneEntryPage> createState() => _PhoneEntryPageState();
}

class _PhoneEntryPageState extends State<PhoneEntryPage> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isValid = false;

  // Add this
  Country _selectedCountry = getCountryFromLocale();

  void _openCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CountryPickerBottomSheet(
        selectedCountry: _selectedCountry,
        onCountrySelected: (country) {
          setState(() => _selectedCountry = country);
        },
      ),
    );
  }

  void _onPhoneChanged(String value) {
    setState(() {
      _isValid = value.replaceAll(RegExp(r'\D'), '').length >= 10;
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
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
                'Enter your\nphone number.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "We'll send a verification code to this number.",
                style: TextStyle(color: Color(0xFF888888), fontSize: 14),
              ),
              const SizedBox(height: 40),
              // Phone input
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: Row(
                  children: [
                    // Country code
                    GestureDetector(
                      onTap: _openCountryPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text(
                              _selectedCountry.flag,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _selectedCountry.code,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Theme.of(context).hintColor,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 1, height: 24, color: const Color(0xFF2A2A2A)),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        onChanged: _onPhoneChanged,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                        decoration: const InputDecoration(
                          hintText: 'XXX XXX XX XX',
                          hintStyle: TextStyle(color: Color(0xFF444444)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isValid
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SmsVerificationPage(
                                phoneNumber: _phoneController.text,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF9B233),
                    disabledBackgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                    foregroundColor: const Color(0xFF0A0A0A),
                    disabledForegroundColor: const Color(0xFF444444),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Send Code',
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