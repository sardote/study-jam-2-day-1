import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surf_practice_chat_flutter/features/auth/models/token_dto.dart';
import 'package:surf_practice_chat_flutter/features/auth/repository/auth_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/chat_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/screens/chat_screen.dart';
import 'package:surf_practice_chat_flutter/features/topics/screens/topics_screen.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

import '../../topics/repository/chart_topics_repository.dart';

/// Screen for authorization process.
///
/// Contains [IAuthRepository] to do so.
class AuthScreen extends StatefulWidget {
  /// Repository for auth implementation.
  final IAuthRepository authRepository;

  /// Constructor for [AuthScreen].
  const AuthScreen({
    required this.authRepository,
    Key? key,
  }) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // TODO(task): Implement Auth screen.
  final loginField = TextEditingController(text: 'sardote');
  final passwordField = TextEditingController(text: '2Sc7rvXOGMHg');
  late TokenDto token;

  void _login() async {
    final login = loginField.text;
    final password = passwordField.text;
    try {
      token =
          await widget.authRepository.signIn(login: login, password: password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token.token);
      _pushToChat(context, token);
    } on Exception catch (e) {
      _showSnakBar(e.toString());
    }
  }

  void _showSnakBar(final String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$message')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: loginField,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
                labelText: 'Login',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordField,
              obscureText: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock_outlined),
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _login,
                child: const Text('Далее'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pushToChat(BuildContext context, TokenDto token) {
    Navigator.push<ChatScreen>(
      context,
      MaterialPageRoute(
        builder: (_) {
          // return ChatScreen(
          //   chatRepository: ChatRepository(
          //     StudyJamClient().getAuthorizedClient(token.token),
          //   ),
          // );
          return TopicsScreen(
            topicsRepository: ChatTopicsRepository(
              StudyJamClient().getAuthorizedClient(token.token),
            ),
          );
        },
      ),
    );
  }
}
