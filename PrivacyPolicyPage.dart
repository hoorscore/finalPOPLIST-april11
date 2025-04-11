import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'main.dart';
import 'settings_screen.dart';
import 'task.dart';
import 'edit_profile_screen.dart';

class PrivacyPolicyPage extends StatefulWidget {
  final List<Map<String, dynamic>> tasks;
  const PrivacyPolicyPage({Key? key, required this.tasks}) : super(key: key);

  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  String privacyText = "جارٍ تحميل سياسة الخصوصية...";
  DateTime lastUpdated = DateTime.now();
  bool isLoading = true;

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
  void initState() {
    super.initState();
    initializeDateFormatting('ar', null);
    _fetchPrivacyPolicy();
  }

  // Fetch privacy policy from Firestore
  Future<void> _fetchPrivacyPolicy() async {
    print("🔍 Fetching privacy policy..."); // Debugging

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('app_data')
          .doc('privacy_policy')
          .get();

      print("📡 Firestore request sent!"); // Debugging

      if (snapshot.exists) {
        print("✅ Document found: ${snapshot.data()}"); // Debugging
        setState(() {
          privacyText = snapshot['content'];
          lastUpdated = (snapshot['lastupdated'] as Timestamp).toDate();
          isLoading = false;
        });
      } else {
        print("⚠️ Document does not exist in Firestore.");
      }
    } catch (e) {
      print("❌ Error fetching privacy policy: $e");
    }
  }



  // Function to format date in Arabic
  String getFormattedDate() {
    return DateFormat('d MMMM yyyy', 'ar').format(lastUpdated);
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
                image: AssetImage("assets/setting_editprofile_bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: 50),

              // Header Row
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
                      "سياسة الخصوصية",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Privacy Policy Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (isLoading)
                            CircularProgressIndicator()
                          else ...[
                            Text(
                              "آخر تحديث ${getFormattedDate()}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              privacyText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                            ),
                          ]
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
