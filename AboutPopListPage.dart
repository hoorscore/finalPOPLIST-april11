import 'package:flutter/material.dart';
import 'task.dart';
import 'main.dart';
import 'settings_screen.dart';
import 'edit_profile_screen.dart';

class AboutPopListPage extends StatefulWidget {
  final List<Map<String, dynamic>> tasks;
  const AboutPopListPage({Key? key, required this.tasks}) : super(key: key);

  @override
  _AboutPopListPageState createState() => _AboutPopListPageState();
}

class _AboutPopListPageState extends State<AboutPopListPage> {
  int _selectedIndex = 3;

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    Widget destination;

    switch (index) {
      case 0:
        destination = TaskEntryScreen(tasks: widget.tasks);
        break;
      case 1:
        destination = TaskScreen();
        break;
      case 2:
        destination = EditProfileScreen();
        break;
      case 3:
        destination = SettingsScreen(tasks: widget.tasks);
        break;
      default:
        destination = TaskEntryScreen(tasks: widget.tasks);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/setting_editprofile_bg.jpg"), // Matches Privacy Policy Page
                fit: BoxFit.cover,
              ),
            ),
          ),

          Column(
            children: [
              SizedBox(height: 50),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Spacer(),
                    Text(
                      "عن PopList",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // About Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'بوب لست | PopList هو تطبيق لإدارة المهام اليومية للأشخاص الذين يعانون من اضطراب فرط الحركة وتشتت الانتباه',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'رؤيتنا\nفي بوب لست | PopList نسعى لتمكين الأشخاص من تنظيم المهام اليومية',
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      // Bottom Navigation Bar

      bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
    backgroundColor: const Color(0xFFFFCC63),
    currentIndex: _selectedIndex,
    onTap: _onTabTapped,
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.white.withOpacity(0.7),
    selectedIconTheme: IconThemeData(
    color: _selectedIndex == 3 ? Colors.blue[900] : Colors.white, // الأزرق الغامق إذا كانت الإعدادات مختارة
    ),

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.check_box), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
    );
  }
}
