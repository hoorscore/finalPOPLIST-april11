import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import
import 'package:intl/intl.dart'; // For formatting the date
import 'package:intl/date_symbol_data_local.dart';
import 'main.dart';
import 'settings_screen.dart';
import 'task.dart';
import 'edit_profile_screen.dart';

class TermsAndConditionsPage extends StatefulWidget {
  final List<Map<String, dynamic>> tasks;
  const TermsAndConditionsPage({Key? key, required this.tasks}) : super(key: key);

  @override
  _TermsAndConditionsPage createState() => _TermsAndConditionsPage();
}

class _TermsAndConditionsPage extends State<TermsAndConditionsPage> {
  // Store last updated date
  DateTime lastUpdated = DateTime.now();
  // Terms and conditions content
  String termsText = "جارٍ تحميل الشروط و الأحكام...";
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
    _fetchTermsAndConditions(); // Fetch terms on initialization
  }

  // Fetch terms and conditions from Firestore
  Future<void> _fetchTermsAndConditions() async {
    print("🔍 Fetching terms and conditions...");

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('app_data')
          .doc('terms_and_conditions')
          .get();

      print("📡 Firestore request sent!");

      if (snapshot.exists) {
        setState(() {
          termsText = snapshot['content'];
          lastUpdated = (snapshot['lastupdated'] as Timestamp).toDate();
        });
      } else {
        print("⚠️ Document does not exist in Firestore.");
      }
    } catch (e) {
      print("❌ Error fetching terms and conditions: $e");
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
                image: AssetImage("assets/setting_editprofile_bg.jpg"), // Ensure this image exists
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: 50), // Space for status bar

              // Header Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    // Back button
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Spacer(), // Pushes title to the right
                    Text(
                      "الشروط و الأحكام",
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

              // Terms and Conditions Content
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
                          // Display dynamic last updated date
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

                          // Terms and conditions text
                          if (termsText == "جارٍ تحميل الشروط و الأحكام...")
                            CircularProgressIndicator()
                          else
                            Text(
                              termsText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.black87,
                              ),
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

