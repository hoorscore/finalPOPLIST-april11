import 'package:flutter/material.dart';
import 'FAQAdmin.dart';
import 'userslist.dart';
import 'PrivacyPolicyAdmins.dart';
import 'Terms_and_Conditions_Admins_page.dart';
import 'main.dart';

//Admin settings
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/img4.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(top: 50, left: 15, right: 15),
                child: Row(
                  children: [
                    Spacer(),
                    Text(
                      "الإعدادات",
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.settings, color: Colors.white, size: 30),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Settings Options
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "الصلاحيات",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    settingsOption(context, "تعديل سياسة الخصوصية"),
                    settingsOption(context, "تعديل الشروط والأحكام"),
                    settingsOption(context, "إدارة الأسئلة الشائعة"),
                    settingsOption(context, "عرض بيانات المستخدمين"),
                  ],
                ),
              ),
              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
                    );
                    // Add logout logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFCC63),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.white),
                      SizedBox(width: 8),
                      Text("تسجيل خروج",
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Function to create settings option widget
  Widget settingsOption(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () {
          if (title == "إدارة الأسئلة الشائعة") {
            Navigator.push(context, MaterialPageRoute(builder: (context) => FAQAdmin()));
          } else if (title == "عرض بيانات المستخدمين") {
            Navigator.push(context, MaterialPageRoute(builder: (context) => UsersListPage()));
          } else if (title == "تعديل سياسة الخصوصية") {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicyAdmins()));
          } else if (title == "تعديل الشروط والأحكام") {
            Navigator.push(context, MaterialPageRoute(builder: (context) => TermsAndConditionsAdminsPage()));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Pressed: $title")),
            );
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.arrow_back, color: Colors.white),
            Text(
              title,
              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget divider() {
    return Divider(color: Colors.white, thickness: 1, height: 20);
  }
}
