import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'details.dart';
import 'main.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'motivational_message.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final Random random = Random();
  int _currentIndex = 1;

  List<DocumentSnapshot> _tasksDocs = [];

  void _completeTask(String taskId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text("إنهاء المهمة"),
            content: const Text("هل أنت متأكد أنك أنهيت هذه المهمة؟"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("إلغاء"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("نعم، انتهيت"),
              ),
            ],
          ),
        );
      },
    );

    if (confirm != null && confirm) {
      try {
        await FirebaseFirestore.instance
            .collection('Task')
            .doc(taskId)
            .update({
          'completed': true,
          'completed_at': FieldValue.serverTimestamp(),
        });

        setState(() {
          _tasksDocs.removeWhere((doc) => doc.id == taskId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Directionality(
              textDirection: TextDirection.rtl,
              child: Text("تم إنهاء المهمة"),
            ),
            backgroundColor: Colors.black,
          ),
        );

        if (_tasksDocs.isEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MotivationalMessageScreen()),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("حدث خطأ: $error")),
        );
      }
    }
  }

  void _onTabTapped(int index) {
    Widget destination;

    switch (index) {
      case 0:
        destination = TaskEntryScreen();
        break;
      case 1:
        destination = TaskScreen();
        break;
      case 2:
        destination = EditProfileScreen();
        break;
      case 3:
        destination = SettingsScreen(tasks: []);
        break;
      default:
        destination = TaskScreen();
    }

    setState(() => _currentIndex = index);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  void _shuffleTasks() {
    setState(() {
      _tasksDocs.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFCC63),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TaskEntryScreen()),
            );
          },
        ),
        title: const Text("مهامك اليوم", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailsScreen(tasks: [])),
              );
            },
          ),
        ],
      ),

      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/reset_password_screens.jpg'),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                child: Image.asset(
                  'assets/logo.png',
                  width: 80,
                  height: 80,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Task')
                      .where('completed', isEqualTo: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'لا توجد مهام حالياً',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    _tasksDocs = snapshot.data!.docs;
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: SingleChildScrollView(
                        reverse: true,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: _tasksDocs.map((doc) {
                              Map<String, dynamic> task = doc.data() as Map<String, dynamic>;
                              String taskId = doc.id;
                              final double bubbleSize = 80.0 + random.nextInt(70).toDouble();
                              return GestureDetector(
                                onTap: () => _completeTask(taskId),
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: 1.0,
                                  child: Container(
                                    width: bubbleSize,
                                    height: bubbleSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: const DecorationImage(
                                        image: AssetImage('assets/bubble.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(task['name'] ?? '',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: ElevatedButton.icon(
                  onPressed: _shuffleTasks,
                  icon: const Icon(Icons.shuffle),
                  label: const Text("إعادة ترتيب المهام"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE0F7FA),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
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
