import 'package:flutter/material.dart';
import 'FAQ.dart';
import 'edit_profile_screen.dart';
import 'main.dart';
import 'task.dart'; // صفحة المهام
//import 'login_screen.dart' as login;
import 'PrivacyPolicyPage.dart';
import 'Terms_and_Conditions_page.dart';
import 'AboutPopListPage.dart';

class SettingsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> tasks;

  const SettingsScreen({Key? key, required this.tasks}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isBackgroundSoundOn = true;
  bool _isNotificationsOn = false;

  int _selectedIndex = 3; // الإعدادات

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "الإعدادات",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/setting_editprofile_bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfileScreen()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "تعديل الحساب الشخصي",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white), // السهم بأقصى اليسار
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _buildSettingsOption(title: "عن PopList", icon: Icons.arrow_forward_ios, context: context,
                  page: AboutPopListPage(tasks: [],),
                ),

                // ✅ Navigating to PrivacyPolicyPage
                _buildSettingsOption(
                  title: "سياسة الخصوصية",
                  icon: Icons.arrow_forward_ios,
                  context: context,
                  page: PrivacyPolicyPage(tasks: [],),
                ),

                _buildSettingsOption(
                    title: "الشروط والأحكام",
                    icon: Icons.arrow_forward_ios,
                    context: context,
                    page: TermsAndConditionsPage(tasks: [],)
                ),
                _buildSettingsOption(title: "الأسئلة الشائعة", icon: Icons.arrow_forward_ios, context: context,
                    page: FAQPage(tasks: [],)
                ),
                const SizedBox(height: 30),
                _buildLogoutButton(context),
              ],
            ),
          ),
        ),
      ),
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

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,
          );
        },
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          "تسجيل خروج",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFCC63),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsOption({
    required String title,
    required IconData icon,
    required BuildContext context,
    Widget? page,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl, // Keep text on the right
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white), // White arrow on the left
          ],
        ),
        onTap: () {
          if (page != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('الميزة "$title" غير مفعلة حالياً')),
            );
          }
        },
      ),
    );
  }


  Widget _buildToggleOption(String title, bool currentValue, Function(bool) onChanged) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        value: currentValue,
        activeColor: Colors.white,
        activeTrackColor: const Color(0xFFFFCC63),
        inactiveTrackColor: Colors.grey[700],
        onChanged: (bool value) {
          onChanged(value); // استدعاء الدالة لتغيير الحالة
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title: ${value ? "مفعل" : "معطل"}')),
          );
        },
      ),
    );
  }
}
