import 'dart:async'; // Import Timer
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showFirstImage = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Start the timer to toggle the image every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 7), (timer) {
      setState(() {
        _showFirstImage = !_showFirstImage; // Toggle between true/false
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.brown, // Change background color of the entire screen

      appBar: AppBar(
        toolbarHeight: 70,
        centerTitle: true,
        flexibleSpace: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ClipOval(
              child: Image.asset(
                'assets/icons/head.png', // Replace with your image path
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.brown[800],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient between image and background
            Stack(
              children: [
                // AnimatedOpacity wrapped around both image and content

                AnimatedOpacity(
                  opacity: _showFirstImage ? 1.0 : 0.0,
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOut,
                  child: Stack(
                    children: [
                      // Image with dissolve effect
                      Image.asset(
                        'assets/home_images/professor_snape.jpg', // First image
                        height: 400,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      // Gradient layer with changed color
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.brown.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 50,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Watch: Ten minutes \nof sublime Severus \nSnape moments!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Cinzel',
                              ),
                            ),
                            const Text(
                              'As it’s Severus Snape’s birthday, obviously we thought \nit would be the perfect occasion to showcase \nsome of his most memorable moments.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () {
                                // Action for the button (e.g., navigate to another screen)
                                print('Button Pressed!');
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white.withOpacity(0.7),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                              child: const Text('Learn More'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                AnimatedOpacity(
                  opacity: _showFirstImage ? 0.0 : 1.0,
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOut,
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/home_images/train_platform.jpg', // First image
                        height: 400,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      // Gradient layer with changed color
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.brown.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 50,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'The Hogwarts Express: \nWhere Every Journey is \nFilled with Wonder',                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Cinzel',
                              ),
                            ),
                            const Text(
                                'With its steam rising and wheels ready to turn, \nthe Hogwarts Express is more than a train—\nit is the beginning of every magical year.',                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () {
                                // Action for the button (e.g., navigate to another screen)
                                print('Button Pressed!');
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white.withOpacity(0.7),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                              child: const Text('Learn More'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Features section
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Discover the Magic',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            Padding (
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: const [
                   FeatureTile(
                      title: 'Books', 
                      image: 'assets/home_images/books.png'),
                  FeatureTile(
                    title: 'Films', 
                    image: 'assets/home_images/film.jpg'),
                  FeatureTile(
                      title: 'Portkey Games', 
                      image: 'assets/home_images/portkeygames.jpg'),
                  FeatureTile(
                      title: 'On Stage', 
                      image: 'assets/home_images/onstage.jpg'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // News section
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Latest News',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return NewsTile(
                  title: 'News Title $index',
                  subtitle: 'Brief description about news $index.',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureTile extends StatelessWidget {
  final String title;
  final String image;

  const FeatureTile({required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NewsTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const NewsTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {},
      ),
    );
  }
}
