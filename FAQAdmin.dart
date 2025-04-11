import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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
      home: FAQAdmin(),
    );
  }
}

class FAQAdmin extends StatefulWidget {
  @override
  _FAQAdminState createState() => _FAQAdminState();
}

class _FAQAdminState extends State<FAQAdmin> {
  final List<Map<String, String>> faqs = [];

  @override
  void initState() {
    super.initState();
    _fetchFAQs();
  }

// Fetch FAQ data from Firestore
  Future<void> _fetchFAQs() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('FAQ').get();
      if (snapshot.docs.isEmpty) {
        print('No FAQs found in Firestore');
      } else {
        setState(() {
          faqs.clear();
          for (var doc in snapshot.docs) {
            faqs.add({
              "faqId": doc.id,
              "question": doc['question'],
              "answer": doc['answer'],
            });
          }
        });
      }
    } catch (e) {
      print("Error fetching FAQs: $e");
    }
  }

// Edit FAQ data in Firestore
  Future<void> _editFAQ(String faqId, String newQuestion, String newAnswer) async {
    try {
      await FirebaseFirestore.instance.collection('FAQs').doc(faqId).update({
        'question': newQuestion,
        'answer': newAnswer,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _fetchFAQs(); // Refresh the list
    } catch (e) {
      print("Error updating FAQ: $e");
    }
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
              Padding(
                padding: const EdgeInsets.only(top: 50, left: 15, right: 15),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Spacer(),
                    Text(
                      "الأسئلة الشائعة",
                      style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: faqs.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: faqs.length,
                  itemBuilder: (context, index) {
                    return FAQItem(
                      faqId: faqs[index]["faqId"]!,
                      question: faqs[index]["question"]!,
                      answer: faqs[index]["answer"]!,
                      onEdit: (newQuestion, newAnswer) {
                        _editFAQ(faqs[index]["faqId"]!, newQuestion, newAnswer);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),

    );
  }
}

class FAQItem extends StatelessWidget {
  final String faqId;
  final String question;
  final String answer;
  final Function(String, String) onEdit;

  FAQItem({
    required this.faqId,
    required this.question,
    required this.answer,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 15),
        childrenPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        title: Row(
          children: [
            Expanded(
              child: Text(
                question,
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                TextEditingController questionController = TextEditingController(text: question);
                TextEditingController answerController = TextEditingController(text: answer);

                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Edit FAQ"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: questionController,
                            decoration: InputDecoration(labelText: "Question"),
                          ),
                          TextField(
                            controller: answerController,
                            decoration: InputDecoration(labelText: "Answer"),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          child: Text("Cancel"),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          child: Text("Save"),
                          onPressed: () {
                            onEdit(
                              questionController.text,
                              answerController.text,
                            );
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              answer,
              style: TextStyle(fontSize: 14, color: Colors.black87),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
