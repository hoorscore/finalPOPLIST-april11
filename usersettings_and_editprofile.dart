import 'package:flutter/material.dart';
import 'main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatelessWidget {

  final _auth = FirebaseAuth.instance;
  late User signedinUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // يجعل الخلفية تمتد خلف شريط التطبيق
      appBar: AppBar(
        title: Text(
          "الإعدادات",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/setting_editprofile_bg.jpg"), // استبدل بمسار الصورة الصحيح
            fit: BoxFit.cover, // يغطي الخلفية بالكامل
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSettingsOption(
                  title: "تعديل الحساب الشخصي",
                  icon: Icons.arrow_forward_ios,
                  context: context,
                  page: EditProfileScreen(), // انتقال لصفحة تعديل الحساب
                ),
                _buildSettingsOption(title: "تغيير كلمة المرور", icon: Icons.lock, context: context),
                _buildToggleOption("أصوات الخلفية", true),
                _buildToggleOption("الإشعارات", false),
                SizedBox(height: 20),
                _buildSettingsOption(title: "عن PopList", icon: Icons.info, context: context),
                _buildSettingsOption(title: "سياسة الخصوصية", icon: Icons.privacy_tip, context: context),
                _buildSettingsOption(title: "الشروط والأحكام", icon: Icons.rule, context: context),
                _buildSettingsOption(title: "الأسئلة الشائعة", icon: Icons.help, context: context),
                SizedBox(height: 30),
                SizedBox(
                  width: 280,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _auth.signOut();
                      Navigator.pop(context);
                      /* Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                            (Route<dynamic> route) => false, // يزيل جميع الصفحات السابقة من سجل التنقل
                      );*/
                    },

                    icon: Icon(Icons.logout, color: Colors.white),
                    label: Text(
                      "تسجيل خروج",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFCC63),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // إضافة هذا السطر لحل المشكلة
        backgroundColor: Color(0xFFFFCC63), // نفس لون الزر
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        currentIndex: 3,
        onTap: (index) {
          // تنفيذ التنقل عند الحاجة
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
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

  // تعديل بحيث يتم تمرير الصفحة عند الحاجة
  Widget _buildSettingsOption({
    required String title,
    required IconData icon,
    required BuildContext context,
    Widget? page,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      trailing: Icon(icon, color: Colors.white),
      onTap: () {
        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
      },
    );
  }

  Widget _buildToggleOption(String title, bool initialValue) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      value: initialValue,
      activeColor: Colors.white,
      activeTrackColor: Color(0xFFFFCC63), // لون مطابق للزر
      inactiveTrackColor: Colors.grey[700],
      onChanged: (bool value) {},
    );
  }
}




class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int _selectedIndex = 2; // لتحديد التبويب الحالي

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/setting_editprofile_bg.jpg"), // تأكد من وضع الصورة في مجلد assets
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
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
                SizedBox(height: 20),
                SizedBox(
                  width: 280,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFCC63),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "حفظ التغييرات",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFFFCC63),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, // يحافظ على اللون عند وجود أكثر من 3 عناصر
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
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
