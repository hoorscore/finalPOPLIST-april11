import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class PrivacyPolicyAdmins extends StatefulWidget {
  @override
  _PrivacyPolicyAdminsState createState() => _PrivacyPolicyAdminsState();
}

class _PrivacyPolicyAdminsState extends State<PrivacyPolicyAdmins> {
  String privacyText = "جارٍ تحميل سياسة الخصوصية...";
  DateTime lastUpdated = DateTime.now();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ar', null);
    _fetchPrivacyPolicy();
  }

  // Fetch privacy policy from Firestore
  Future<void> _fetchPrivacyPolicy() async {
    print("🔍 Fetching privacy policy...");

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('app_data')
          .doc('privacy_policy')
          .get();

      print("📡 Firestore request sent!");

      if (snapshot.exists) {
        print("✅ Document found: ${snapshot.data()}");
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

  // Update privacy policy in Firestore
  Future<void> _updatePrivacyPolicy(String newText) async {
    try {
      await FirebaseFirestore.instance
          .collection('app_data')
          .doc('privacy_policy')
          .update({
        'content': newText,
        'lastupdated': FieldValue.serverTimestamp(),
      });

      setState(() {
        privacyText = newText;
        lastUpdated = DateTime.now();
      });

      print("✅ Privacy policy updated successfully!");
    } catch (e) {
      print("❌ Error updating privacy policy: $e");
    }
  }

  // Show dialog for editing
  void _editPrivacyPolicy() {
    TextEditingController controller = TextEditingController(text: privacyText);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("تعديل سياسة الخصوصية"),
          content: TextField(
            controller: controller,
            maxLines: 10,
            decoration: InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("إلغاء"),
            ),
            TextButton(
              onPressed: () {
                _updatePrivacyPolicy(controller.text);
                Navigator.pop(context);
              },
              child: Text("حفظ"),
            ),
          ],
        );
      },
    );
  }

  // Format date in Arabic
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
                image: AssetImage("assets/img4.jpg"),
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
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.white, size: 28),
                      onPressed: _editPrivacyPolicy,
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
    );
  }
}
