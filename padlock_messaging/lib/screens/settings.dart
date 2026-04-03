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

/// Flutter code sample for [ListTile].

void main() => runApp(const SettingsApp());

class SettingsApp extends StatelessWidget {
  const SettingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Settings(title: 'Settings'));
  }
}

class Settings extends StatelessWidget {
  const Settings({super.key, required this.title});

  final String title;

  Text accountName() {
    return const Text('John Doe');
  }

  Text accountNameReturnInitials() {
    final name = accountName().data;
    final initials = name!.split(' ').map((word) => word[0]).join();
    return Text(initials);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: <Widget>[
          ListTile(
            titleAlignment: ListTileTitleAlignment.threeLine,
            minLeadingWidth: 50,
            leading: CircleAvatar(child: accountNameReturnInitials()),
            minVerticalPadding: 25,
            title: accountName(),
            subtitle: Text('View your information'),
            onTap: () {
            },
          ),
          InkWell(
            onTap: () {
            },
            child: ListTile(
              leading: Icon(Icons.person_outlined),
              title: Text('Account Settings'),
              subtitle: Text('Change your account settings'),
            ),
          ),
          InkWell(
            onTap: () {
            },
            child: ListTile(
              leading: Icon(Icons.shield_outlined),
              title: Text('Privacy'),
              subtitle: Text('Change your privacy settings'),
            ),
          ),
          InkWell(
            onTap: () {
            },
            child: ListTile(
              leading: Icon(Icons.backup_outlined),
              title: Text('Backups'),
              subtitle: Text('Change your backup settings'),
            ),
          ),
        ],
      ),
    );
  }
}