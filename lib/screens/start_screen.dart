import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StartScreen extends StatefulWidget {
  const StartScreen(this.startQuiz, {super.key});

  final void Function() startQuiz;

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  var userName = '';
  var userImageUrl = '';

  Future<void> getUserData() async {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(authenticatedUser.uid)
        .get();

    userName = userData.data()!['username'];
    userImageUrl = userData.data()!['image_url'];
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: userImageUrl.isEmpty || userName.isEmpty
          ? const CircularProgressIndicator()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(userImageUrl),
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withAlpha(180),
                  radius: 60,
                ),
                const SizedBox(height: 20),
                if (userName.isNotEmpty)
                  Text(
                    'Welcome $userName!',
                    style: GoogleFonts.lato(
                      color: const Color.fromARGB(255, 237, 223, 252),
                      fontSize: 24,
                    ),
                  ),
                const SizedBox(height: 30),
                OutlinedButton.icon(
                  onPressed: widget.startQuiz,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.arrow_right_alt),
                  label: const Text('Start Quiz'),
                ),
                OutlinedButton.icon(
                  onPressed: widget.startQuiz,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.history),
                  label: const Text('Your scores'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Log out'),
                )
              ],
            ),
    );
  }
}
