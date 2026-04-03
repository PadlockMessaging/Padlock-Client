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
import 'package:padlock_messaging/screens/search.dart';
import 'package:padlock_messaging/screens/settings.dart';
import 'auth/welcome.dart';


class Shell extends StatefulWidget {
  const Shell({super.key, required this.title});
  final String title;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {

  int currentIndex = 0;

  Widget _emptyMessages() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No messages yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            'Start a conversation!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _emptyContacts() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No contacts yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            'Add someone to get started!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const Settings(title: 'Settings')));
  }
  @override
  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme.copyWith(primary: const Color(0xFFF9B233), secondary: const Color(0xFFB2B2B2));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontFamily: 'Roboto', fontSize: 20, fontWeight: FontWeight.w600)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'Settings':
                  _navigateToSettings();
                  break;
                case 'Logout':
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Settings', 'Logout'}.map((String choice) { 
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        animationDuration: const Duration(milliseconds: 50),
        onDestinationSelected: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        indicatorColor: const Color(0xFFF9B233),
        selectedIndex: currentIndex,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.message),
            icon: Icon(Icons.message_outlined),
            label: 'Messages',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline),
            label: 'Contacts',
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Search()),
          );
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: const Color(0xFFFFFFFF),
        child: const Icon(Icons.person_add),
      ),

      body: switch (currentIndex) {
        0 => _emptyMessages(),
        1 => _emptyContacts(),
        _ => _emptyMessages(),
      },
    );
  }
}