import 'package:flutter/material.dart';
import 'main.dart';
import 'settings_screen.dart';   // صفحة الإعدادات
import 'task.dart';// صفحة المهام، تأكد أنها موجودة
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task.dart'; // استيراد صفحة المهام

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  int _selectedIndex = 2; // الصفحة الحالية (حساب المستخدم)
  User? _user;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      _userId = _user!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(_userId).get();

      if (userDoc.exists) {
        setState(() {
          _nameController.text = userDoc['username'] ?? 'لا يوجد اسم';
          _emailController.text = _user!.email ?? '';
        });
      }
    }
  }
  Future<void> _updateUserData() async {
    if (_userId != null && _user != null) {
      try {
        final cred = EmailAuthProvider.credential(
          email: _user!.email!,
          password: _passwordController.text,
        );

        // إعادة المصادقة
        await _user!.reauthenticateWithCredential(cred);

        // تحديث الاسم
        await FirebaseFirestore.instance.collection('users').doc(_userId).update({
          'username': _nameController.text.trim(),
          'email': _emailController.text.trim(),
        });

        // تحديث البريد إذا تغيّر
        if (_user!.email != _emailController.text) {
          await _user!.updateEmail(_emailController.text);
        }

        // تحديث كلمة المرور إذا تم إدخال واحدة جديدة
        if (_newPasswordController.text.isNotEmpty) {
          await _user!.updatePassword(_newPasswordController.text);
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("نجاح", textAlign: TextAlign.right),
              content: Text("تم حفظ التغييرات بنجاح", textAlign: TextAlign.right),
              actions: [
                TextButton(
                  child: Text("حسناً"),
                  onPressed: () {
                    Navigator.of(context).pop(); // يغلق النافذة المنبثقة
                  },
                ),
              ],
            );
          },
        );

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("حدث خطأ: $e")),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // التنقل إلى الصفحة المطلوبة
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TaskEntryScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TaskScreen()));
        break;
      case 2:
      // البقاء في صفحة تعديل الحساب
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SettingsScreen(tasks: [],)));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // مهم لتفعيل التمرير عند ظهور الكيبورد
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/setting_editprofile_bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 80, // مساحة كافية عشان يبان الزر فوق البار
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerLeft,

                  ),
                  Text(
                    "تعديل الحساب الشخصي",
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  buildInputField("اسم المستخدم", _nameController, false),
                  buildInputField("البريد الإلكتروني", _emailController, false),
                  buildInputField("كلمة المرور", _passwordController, true),
                  buildInputField("كلمة المرور الجديدة", _newPasswordController, true),
                  SizedBox(height: 30), // مسافة بعد آخر حقل

                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 100),
                      width: 200, // العرض تم تصغيره
                      height: 42,  // الارتفاع تم تصغيره
                      child: ElevatedButton(
                        onPressed: _updateUserData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFCC63),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6), // زوايا ناعمة أكثر
                          ),
                        ),
                        child: Text(
                          "حفظ التغييرات",
                          style: TextStyle(
                            fontSize: 16, // تصغير حجم الخط
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 150), // مهم عشان ما يلصق بالأسفل
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFFFCC63),
        selectedItemColor: Colors.blue[900],
        unselectedItemColor: Colors.white.withOpacity(0.7),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '',
          ),
        ],
      ),
    );
  }
  Widget buildInputField(String label, TextEditingController controller, bool isPassword) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end, // هنا التعديل للمحاذاة لليمين
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0), // عشان مايلصق مره
            child: Text(
              label,
              style: TextStyle(fontSize: 18, color: Colors.white),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(height: 5),
          Container(
            width: 280,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              //textAlign: TextAlign.right, // تقدر تحذفينه لو تبين النص داخل التيكست يصير يسار
              controller: controller,
              obscureText: isPassword,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
