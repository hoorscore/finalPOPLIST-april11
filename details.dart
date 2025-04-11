import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'task.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({Key? key, required List tasks}) : super(key: key);

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late List<Map<String, dynamic>> tasks;
  late List<TextEditingController> nameControllers;
  late List<TextEditingController> descriptionControllers;
  late List<TextEditingController> timeControllers;

  int _currentIndex = 1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasksFromFirestore();
  }

  Future<void> _fetchTasksFromFirestore() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Task').get();
      tasks = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      nameControllers = tasks.map((task) => TextEditingController(text: task["name"] ?? "")).toList();
      descriptionControllers = tasks.map((task) => TextEditingController(text: task["description"] ?? "")).toList();
      timeControllers = tasks.map((task) {
        String hour = task["hour"]?.toString().padLeft(2, '0') ?? "12";
        String minute = task["minute"]?.toString().padLeft(2, '0') ?? "00";
        String period = task["period"] ?? "AM";
        return TextEditingController(text: "$hour:$minute $period");
      }).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('خطأ أثناء جلب المهام: $e');
    }
  }

  Future<void> _saveChanges() async {
    try {
      for (int i = 0; i < tasks.length; i++) {
        final taskId = tasks[i]['id'];

        final timeParts = timeControllers[i].text.split(RegExp(r'[: ]'));
        if (timeParts.length != 3) {
          throw Exception("تنسيق الوقت غير صحيح للمهمة رقم ${i + 1}");
        }

        final hour = timeParts[0];
        final minute = timeParts[1];
        final period = timeParts[2];

        await FirebaseFirestore.instance.collection('Task').doc(taskId).update({
          'name': nameControllers[i].text,
          'description': descriptionControllers[i].text,
          'hour': hour,
          'minute': minute,
          'period': period,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              'تم حفظ التعديلات بنجاح!',
              textAlign: TextAlign.right,
            ),
          ),
          backgroundColor: Colors.black,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء الحفظ: $e')),
      );
    }
  }

  Future<void> _deleteTask(int index) async {
    final taskId = tasks[index]['id'];

    try {
      await FirebaseFirestore.instance.collection('Task').doc(taskId).delete();

      setState(() {
        tasks.removeAt(index);
        nameControllers.removeAt(index);
        descriptionControllers.removeAt(index);
        timeControllers.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black,
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Text("تم حذف المهمة"),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء الحذف: $e')),
      );
    }
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;

    setState(() => _currentIndex = index);

    Widget destination;
    switch (index) {
      case 0:
        destination = const TaskEntryScreen();
        break;
      case 1:
        destination = TaskScreen();
        break;
      case 2:
        destination =  EditProfileScreen();
        break;
      case 3:
        destination = const SettingsScreen(tasks: []);
        break;
      default:
        destination = const TaskEntryScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFCC63),
        title: const Text("تعديل المهام", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _isLoading ? null : _saveChanges,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/signup_bg.jpg", fit: BoxFit.cover),
          ),

          // اللوقو أعلى يسار الصفحة
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0),
              child: Image.asset(
                'assets/logo.png', // أو logo_small.PNG حسب الملف الموجود عندك
                width: 80,
                height: 80,
              ),
            ),
          ),

          // باقي المحتوى
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : tasks.isEmpty
              ? const Center(
            child: Text(
              "لا توجد مهام للتعديل!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textDirection: TextDirection.rtl,
            ),
          )
              : Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.white.withOpacity(0.9),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "مهمة ${index + 1}",
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog(
                                  context: context,
                                  builder: (context) => Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: AlertDialog(
                                      title: const Text("تأكيد الحذف"),
                                      content: const Text("هل أنت متأكد أنك تريد حذف هذه المهمة؟"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text("إلغاء"),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: const Text("حذف", style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                                if (confirm == true) {
                                  _deleteTask(index);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: TextField(
                            controller: nameControllers[index],
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(
                              labelText: "اسم المهمة",
                              labelStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              hintText: "اكتب اسم المهمة",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: TextField(
                            controller: descriptionControllers[index],
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(
                              labelText: "وصف المهمة",
                              labelStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              hintText: "اكتب وصف المهمة",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: TextField(
                            controller: timeControllers[index],
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(
                              labelText: "الوقت المستحق",
                              labelStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              hintText: "حدد الوقت",
                              hintStyle: TextStyle(color: Colors.blue),
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
}
