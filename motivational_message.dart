import 'package:flutter/material.dart';
import 'level_selection_screen.dart';
import 'main.dart';

class MotivationalMessageScreen extends StatefulWidget {
  const MotivationalMessageScreen({Key? key}) : super(key: key);

  @override
  _MotivationalMessageScreenState createState() => _MotivationalMessageScreenState();
}

class _MotivationalMessageScreenState extends State<MotivationalMessageScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) _controller.stop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
          children: [
      Container(
      decoration: const BoxDecoration(

      image: DecorationImage(
            image: AssetImage('assets/reset_password_screens.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [


// Bubble with the text
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/bubble.png',
                          width: 300,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            '!عمل رائع لقد أنجزت المهام بنجاح\n'
                                'استمر بهذا الأداء\n'
                                'وستتفوق على السمكة\n'
                                'الذهبية بمعدل التركيز!\n'
                                '\n✨',

                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    ScaleTransition(
                      scale: _animation,
                      child: Image.asset(
                        'assets/logo.png',
                        width: 300, // Reduced to prevent overflow
                        height: 300,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 20),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: 280,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LevelSelectionScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFCC63),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'ابدأ اللعبة',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

            // ← Back Arrow Button (top left)
            Positioned(
              top: 40,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const TaskEntryScreen()),
                  );
                },
              ),
            ),
          ],
      ),

    );

  }
}
