port 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'settings_screen.dart'; 
import 'edit_profile_screen.dart'; 
import 'adminLogin.dart';
import 'task.dart'; 


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/splash_bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Image.asset("assets/logo.png", height: 500),
        ),
      ),
    );
  }
}

class RoleSelectionScreen extends StatefulWidget {
  @override
  _RoleSelectionScreenState createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/login_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 100),
              SizedBox(height: 20),
              SizedBox(
                width: 280,
                height: 48,
                child: DropdownButtonFormField<String>(
                  value: selectedRole,
                  isExpanded: true, // ضروري يخلي النص يمتد للعرض كله
                  hint: Text(
                    "تسجيل دخول",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  alignment: Alignment.center, // هذا لضبط المحاذاة
                  items: ['مستخدم', 'مسؤول'].map((role) {
                    return DropdownMenuItem(
                      value: role,
                      alignment: Alignment.center,
                      child: Text(
                        role,
                        style: TextStyle(fontSize: 14, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value;
                    });
                    if (value == 'مستخدم') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    } else if (value == 'مسؤول') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdminLoginScreen()),
                      );
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  dropdownColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


//////////////////////////////////////////////////////////////////////////////////////////////////////

class LoginScreen extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;

  Future<List<Map<String, dynamic>>> fetchTasks() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('tasks').get();
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error fetching tasks: $e");
      return [];
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "خطأ في تسجيل الدخول",
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              child: const Text("حسناً"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
            );
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/login_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/logo_small.png', height: 129, width: 105),
                  const SizedBox(height: 20),
                  const Text(
                    "مرحبا بعودتك",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "اسم المستخدم أو البريد الإلكتروني",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: 280,
                        height: 48,
                        child: TextField(
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            email = value;
                          },
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "كلمة المرور",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: 280,
                        height: 48,
                        child: TextField(
                          obscureText: true,
                          onChanged: (value) {
                            password = value;
                          },
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 280,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCC63),
                      ),
                      onPressed: () async {
                        try {
                          final user = await _auth.signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                          if (user != null) {
                            List<Map<String, dynamic>> tasks = await fetchTasks();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => TaskEntryScreen(tasks: tasks)),
                            );
                          }
                        } catch (e) {
                          _showErrorDialog(context, "البريد الإلكتروني أو كلمة المرور غير صحيحة. يرجى المحاولة مرة أخرى.");
                        }
                      },
                      child: const Text("تسجيل الدخول", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                    child: const Text("ليس لديك حساب؟ أنشئ حساب جديد", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
                      );
                    },
                    child: const Text("هل نسيت كلمة المرور؟", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}




/*error message but not centered 11 april
class LoginScreen extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;

  Future<List<Map<String, dynamic>>> fetchTasks() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('tasks').get();
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error fetching tasks: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
            );
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/login_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/logo_small.png', height: 129, width: 105),
                  const SizedBox(height: 20),
                  const Text(
                    "مرحبا بعودتك",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "اسم المستخدم أو البريد الإلكتروني",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: 280,
                        height: 48,
                        child: TextField(
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            email = value;
                          },
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "كلمة المرور",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: 280,
                        height: 48,
                        child: TextField(
                          obscureText: true,
                          onChanged: (value) {
                            password = value;
                          },
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 280,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCC63),
                      ),
                      onPressed: () async {
                        try {
                          final user = await _auth.signInWithEmailAndPassword(email: email, password: password);
                          if (user != null) {
                            List<Map<String, dynamic>> tasks = await fetchTasks();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => TaskEntryScreen(tasks: tasks)),
                            );
                          }
                        } catch (e) {
                          print(e);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("خطأ في تسجيل الدخول"),
                                content: const Text("البريد الإلكتروني أو كلمة المرور غير صحيحة. يرجى المحاولة مرة أخرى."),
                                actions: [
                                  TextButton(
                                    child: const Text("حسناً"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: const Text(
                        "تسجيل الدخول",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                    child: const Text(
                      "ليس لديك حساب؟ أنشئ حساب جديد",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
                      );
                    },
                    child: const Text(
                      "هل نسيت كلمة المرور؟",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
*/

/*
class LoginScreen extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;

  Future<List<Map<String, dynamic>>> fetchTasks() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('tasks').get();
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error fetching tasks: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
            );
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/login_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/logo_small.png', height: 129, width: 105),
                  const SizedBox(height: 20),
                  const Text(
                    "مرحبا بعودتك",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "اسم المستخدم أو البريد الإلكتروني",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: 280,
                        height: 48,
                        child: TextField(
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            email = value;
                          },
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "كلمة المرور",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: 280,
                        height: 48,
                        child: TextField(
                          obscureText: true,
                          onChanged: (value) {
                            password = value;
                          },
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 280,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCC63),
                      ),
                      onPressed: () async {
                        try {
                          final user = await _auth.signInWithEmailAndPassword(email: email, password: password);
                          if (user != null) {
                            List<Map<String, dynamic>> tasks = await fetchTasks();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => TaskEntryScreen(tasks: tasks)),
                            );
                          }
                        } catch (e) {
                          print(e);
                        }
                      },
                      child: const Text("تسجيل الدخول", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                    child: const Text("ليس لديك حساب؟ أنشئ حساب جديد", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
                      );
                    },
                    child: const Text("هل نسيت كلمة المرور؟", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
*/



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class SignupScreen extends StatelessWidget {

  final _auth = FirebaseAuth.instance;
  late String username;
  late String email;
  late String password;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/signup_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Text(
                    "التسجيل",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30),

                  TextField(
                    textAlign: TextAlign.right,
                    onChanged: (value){
                      username = value;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'اسم المستخدم',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,

                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.right,
                    onChanged: (value){
                      email = value;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'البريد الإلكتروني',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  TextField(
                    obscureText: true,
                    textAlign: TextAlign.right,
                    onChanged: (value){
                      password = value;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'كلمة المرور',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  TextField(
                    obscureText: true,
                    textAlign: TextAlign.right,
                    onChanged: (value){
                      password = value;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'تأكيد كلمة المرور',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  Container(
                    width: 280,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        print(username);
                        print(email);
                        print(password);

                        try {
                          final userCredential = await _auth.createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          );

                          final user = userCredential.user;

                          if (user != null) {
                            // 🔹 حفظ بيانات المستخدم في Firestore
                            await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                              'username': username,
                              'email': email,
                            });

                            // ✅ بعد الحفظ، الانتقال إلى الصفحة التالية
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => TaskEntryScreen()),
                            );
                          }
                        }catch(e){
                          print(e);
                        }

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFCC63),
                      ),
                      child: Text(
                        "تسجيل",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Divider(color: Colors.white54, thickness: 1),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "لديك حساب بالفعل؟ سجل الدخول",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//////////// Task Entry Screen - مع الوقت المستحق + تنسيق الكرت الأبيض ////////////////////////////////////////////
class TaskEntryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> tasks;

  const TaskEntryScreen({Key? key, this.tasks = const []}) : super(key: key);

  @override
  _TaskEntryScreenState createState() => _TaskEntryScreenState();
}

class _TaskEntryScreenState extends State<TaskEntryScreen> {
  final _taskNameController = TextEditingController();
  final _taskDescriptionController = TextEditingController();

  String _selectedHour = "12";
  String _selectedMinute = "00";
  String _selectedPeriod = "AM";

  int _currentIndex = 0;
  late List<Map<String, dynamic>> tasksList;

  final _hours = List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
  final _minutes = List.generate(60, (index) => index.toString().padLeft(2, '0'));
  final _periods = ["AM", "PM"];

  @override
  void initState() {
    super.initState();
    tasksList = List.from(widget.tasks);
  }

  Future<void> _addTask() async {
    final taskName = _taskNameController.text.trim();
    final taskDesc = _taskDescriptionController.text.trim();

    if (taskName.isEmpty || taskDesc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Text("الرجاء إدخال اسم المهمة ووصفها"),
          ),
          backgroundColor: Colors.black87,
        ),
      );
      return;
    }


    final newTask = {
      'name': taskName,
      'description': taskDesc,
      'hour': _selectedHour,
      'minute': _selectedMinute,
      'period': _selectedPeriod,
      'created_at': FieldValue.serverTimestamp(),
      'completed': false,
    };

    try {
      await FirebaseFirestore.instance.collection('Task').add(newTask);

      setState(() {
        tasksList.add(newTask);
      });

      _taskNameController.clear();
      _taskDescriptionController.clear();

      _showSnackBar("تمت إضافة المهمة بنجاح!");
      _showConfirmationDialog();

    } catch (e) {
      _showSnackBar("حدث خطأ أثناء الإضافة: $e");
    }
  }

  void _showSnackBar(String message) {
    void _showSnackBar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                message,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 8, right: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          elevation: 0,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
            title: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'تمت إضافة المهمة بنجاح',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            actionsAlignment: MainAxisAlignment.end, // محاذاة الأزرار لليمين
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('العودة'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFCC63),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => TaskScreen()),
                  );
                },
                child: const Text("عرض المهام"),
              ),
            ],
          ),
        );
      },
    );
  }
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    Widget screen;
    switch (index) {
      case 0:
        screen = TaskEntryScreen();
        break;
      case 1:
        screen = TaskScreen();
        break;
      case 2:
        screen = EditProfileScreen();
        break;
      case 3:
        screen = SettingsScreen(tasks: []);
        break;
      default:
        screen = TaskEntryScreen();
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/setting_editprofile_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اللوقو يسار
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                  child: Image.asset('assets/logo.png', height: 80),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'ادخل مهامك اليومية',
                    style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildLabeledTextField("اسم المهمة", _taskNameController),
                          _buildLabeledTextField("وصف المهمة", _taskDescriptionController, maxLines: 2),

                          const SizedBox(height: 10),

                          Text(
                            "الوقت المستحق",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Card(
                            elevation: 4,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              child: Row(
                                children: [
                                  // الساعة أولاً
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('الساعة', style: TextStyle(color: Colors.black)),
                                        const SizedBox(height: 5),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: DropdownButton<String>(
                                            value: _selectedHour,
                                            underline: const SizedBox(),
                                            isExpanded: true,
                                            alignment: Alignment.center,
                                            dropdownColor: Colors.white,
                                            iconEnabledColor: Colors.black,
                                            style: const TextStyle(color: Colors.black, fontSize: 16),
                                            items: _hours.map((e) => DropdownMenuItem(
                                              value: e,
                                              child: Center(child: Text(e)),
                                            )).toList(),
                                            onChanged: (val) => setState(() => _selectedHour = val!),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // الدقيقة ثانياً
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'الدقيقة',
                                          style: TextStyle(color: Colors.black),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 5),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: DropdownButton<String>(
                                            value: _selectedMinute,
                                            underline: const SizedBox(),
                                            isExpanded: true,
                                            alignment: Alignment.center,
                                            dropdownColor: Colors.white,
                                            iconEnabledColor: Colors.black,
                                            style: const TextStyle(color: Colors.black, fontSize: 16),
                                            items: _minutes.map((e) => DropdownMenuItem(
                                              value: e,
                                              child: Center(child: Text(e)),
                                            )).toList(),
                                            onChanged: (val) => setState(() => _selectedMinute = val!),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // AM/PM ثالثاً
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('AM/PM', style: TextStyle(color: Colors.black)),
                                        const SizedBox(height: 5),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: DropdownButton<String>(
                                            value: _selectedPeriod,
                                            underline: const SizedBox(),
                                            isExpanded: true,
                                            alignment: Alignment.centerLeft,
                                            dropdownColor: Colors.white,
                                            iconEnabledColor: Colors.black,
                                            style: const TextStyle(color: Colors.black, fontSize: 16),
                                            items: _periods.map((e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e),
                                            )).toList(),
                                            onChanged: (val) => setState(() => _selectedPeriod = val!),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _addTask,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFFCC63), // خلفية بيضاء
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Color(0xFFFFCC63), width: 2), // إطار أزرق
                                ),
                                elevation: 0, // بدون ظل
                              ),
                              child: Text(
                                "إضافة المهمة",
                                style: TextStyle(color: Colors.black, fontSize: 18), // لون النص أزرق
                              ),
                            ),
                          ),
                        ],
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
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFFFFCC63),
        selectedItemColor: Colors.blue[900],
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.check_box), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
    );
  }

  Widget _buildLabeledTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold, // <<< هذا هو المفتاح
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          maxLines: maxLines,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: label == "اسم المهمة" ? "مثال: تناول الدواء" : "مثال: تناول دواء كونسيرتا لمرة واحدة فقط",
            hintTextDirection: TextDirection.rtl,
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
  Widget _buildTimeDropdown(String label, List<String> items, String value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.black)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            underline: SizedBox(),
            isDense: true,
            dropdownColor: Colors.white,
            iconEnabledColor: Colors.black,
            style: const TextStyle(color: Colors.black),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

//////////////////////////////////////////////////////////////////////////////////////////

class CustomTextField extends StatelessWidget {
  final String label;
  final bool isPassword;

  const CustomTextField({required this.label, this.isPassword = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Container(
          width: 280,
          height: 48,
          child: TextField(
            obscureText: isPassword,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}

class ResetPasswordScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PasswordBackground(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("هل نسيت كلمة المرور؟", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 10),
            Text("يرجى كتابة بريدك الإلكتروني لاستلام رمز التأكيد وإعادة تعيين كلمة المرور", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
            SizedBox(height: 20),
            EmailInputField(controller: _emailController),
            SizedBox(height: 20),
            ConfirmButton(
              text: "تأكيد البريد الإلكتروني",
              onPressed: () async {
                final email = _emailController.text.trim();

                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResetLinkSentScreen(email: email),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("حدث خطأ: ${e.toString()}")),
                  );
                }
              },
            ),

            SizedBox(height: 10),
            BackButtonWidget()
          ],
        ),
      ),
    );
  }
}
class EmailInputField extends StatelessWidget {
  final TextEditingController controller;

  EmailInputField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          hintText: "عنوان البريد الإلكتروني",
        ),
      ),
    );
  }
}

class ResetLinkSentScreen extends StatelessWidget {
  final String email;

  const ResetLinkSentScreen({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PasswordBackground(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "تم إرسال رابط إعادة التعيين",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              "لقد تم إرسال رابط لإعادة تعيين كلمة المرور على بريدك الإلكتروني",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 30),
            ConfirmButton(
              text: "إعادة الإرسال",
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("تمت إعادة إرسال الرابط إلى بريدك الإلكتروني")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("حدث خطأ: ${e.toString()}")),
                  );
                }
              },
              color: Color(0xFFFFCC63),
            ),
            const SizedBox(height: 10),
            ConfirmButton(
              text: "حسنًا",
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                      (Route<dynamic> route) => false,
                );
              },
              color: Color(0xFFFFCC63),
            ),
          ],
        ),
      ),
    );
  }
}

class PasswordBackground extends StatelessWidget {
  final Widget child;
  PasswordBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/reset_password_screens.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: child,
      ),
    );
  }
}

class ConfirmButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  ConfirmButton({required this.text, required this.onPressed,this.color = const Color(0xFFFFCC63),});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color),
        onPressed: onPressed,
        child: Text(text, style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}

class BackButtonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text("العودة", style: TextStyle(color: Colors.orange)),
    );
  }
}
