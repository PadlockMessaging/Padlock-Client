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
import 'package:padlock_messaging/services/auth_service.dart';
import 'package:padlock_messaging/screens/main/settings/user_info.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // ignore: unused_field
  String _name = '';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final name = await AuthService.getUserInfo();
    setState(() => _name = name?['name'] ?? '');
  }

  Text accountNameReturnInitials() {
    if (_name.isEmpty) return const Text('');
    final initials = _name.split(' ').map((word) => word[0]).join();
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
            title: Text(_name, style: const TextStyle(fontSize: 18)),
            subtitle: Text('View your information'),
            onTap: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserInfoPage(title: "Change your information")),
              );
              if (updated == true) _loadName();
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