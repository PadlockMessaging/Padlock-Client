import 'package:flutter/material.dart';
import 'package:padlock_messaging/screens/search.dart';

class Shell extends StatefulWidget {
  const Shell({super.key, required this.title});
  final String title;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {

  int currentIndex = 0;

  Widget _buildEmptyMessages() {
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

  Widget _buildEmptyContacts() {
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

  @override
  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme.copyWith(primary: const Color(0xFFF9B233), secondary: const Color(0xFFB2B2B2));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontFamily: 'Roboto', fontSize: 20, fontWeight: FontWeight.w600)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle selection
            },
            itemBuilder: (BuildContext context) {
              return {'Settings', 'Profile', 'Logout'}.map((String choice) {
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
        0 => _buildEmptyMessages(),
        1 => _buildEmptyContacts(),
        _ => _buildEmptyMessages(),
      },
    );
  }
}