import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class TermsAndConditionsAdminsPage extends StatefulWidget {
  @override
  _TermsAndConditionsAdminsPageState createState() => _TermsAndConditionsAdminsPageState();
}

class _TermsAndConditionsAdminsPageState extends State<TermsAndConditionsAdminsPage> {
  String termsText = "جارٍ تحميل الشروط و الأحكام...";
  DateTime lastUpdated = DateTime.now();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ar', null);
    _fetchTermsAndConditions();
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
          isLoading = false;
        });
      } else {
        print("⚠️ Document does not exist in Firestore.");
        isLoading = false;
      }
    } catch (e) {
      print("❌ Error fetching terms and conditions: $e");
      isLoading = false;
    }
  }

  // Save edited terms to Firestore
  Future<void> _saveTermsAndConditions(String newText) async {
    try {
      await FirebaseFirestore.instance
          .collection('app_data')
          .doc('terms_and_conditions')
          .update({
        'content': newText,
        'lastupdated': Timestamp.now(),
      });

      setState(() {
        termsText = newText;
        lastUpdated = DateTime.now();
      });

      print("✅ Terms and conditions updated successfully!");
    } catch (e) {
      print("❌ Error updating terms and conditions: $e");
    }
  }

  // Open edit dialog
  void _editTermsAndConditions() {
    TextEditingController controller = TextEditingController(text: termsText);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("تعديل الشروط و الأحكام"),
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
                _saveTermsAndConditions(controller.text);
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
              SizedBox(height: 50), // Space for status bar

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
                      "الشروط و الأحكام ",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.white, size: 28),
                      onPressed: _editTermsAndConditions,
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
                          if (isLoading)
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
    );
  }
}
