import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surf_practice_chat_flutter/features/chat/screens/chat_screen.dart';
import 'package:surf_practice_chat_flutter/features/topics/models/chat_topic_send_dto.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

import '../../chat/repository/chat_repository.dart';
import '../models/chat_topic_dto.dart';
import '../repository/chart_topics_repository.dart';

/// Screen with different chat topics to go to.
class TopicsScreen extends StatefulWidget {
  /// Repository for chat functionality.
  final IChatTopicsRepository topicsRepository;

  /// Constructor for [TopicsScreen].
  const TopicsScreen({Key? key, required this.topicsRepository})
      : super(key: key);

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  Iterable<ChatTopicDto> _currentTopics = [];

  Future<void> _onUpdatePressed() async {
    final topics = await widget.topicsRepository
        .getTopics(topicsStartDate: DateTime(2022, 08, 12));
    setState(() {
      _currentTopics = topics;
    });
  }

  TextEditingController _nameField = TextEditingController();
  TextEditingController _descriptionField = TextEditingController();

  Future<void> _createTopicDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Создать новый чат'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _nameField,
                  decoration:
                      const InputDecoration(hintText: "Введите имя чата"),
                ),
                TextField(
                  controller: _descriptionField,
                  decoration:
                      const InputDecoration(hintText: "Введите описание"),
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  textStyle: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                child: const Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  textStyle: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                child: const Text('OK'),
                onPressed: () {
                  setState(() {
                    name = _nameField.text;
                    description = _descriptionField.text;
                    if (name.isNotEmpty && description.isNotEmpty) {
                      widget.topicsRepository.createTopic(ChatTopicSendDto(
                          name: name, description: description));
                      _onUpdatePressed();
                    }
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  String name = '';
  String description = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: _TopicAppBar(
          onUpdatePressed: _onUpdatePressed,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _TopicsBody(
              topics: _currentTopics,
            ),
          ),
          // _ChatTextField(onSendPressed: _onSendPressed),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: () => _createTopicDialog(context),
              child: const Icon(Icons.add_circle_outline),
            ),
          )
        ],
      ),
    );
  }
}

class _TopicsBody extends StatelessWidget {
  final Iterable<ChatTopicDto> topics;

  const _TopicsBody({
    required this.topics,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: topics.length,
      itemBuilder: (_, index) => _ChatTopic(
        chatTopic: topics.elementAt(index),
      ),
    );
  }
}

class _ChatTopic extends StatelessWidget {
  final ChatTopicDto chatTopic;

  const _ChatTopic({
    required this.chatTopic,
    Key? key,
  }) : super(key: key);

  topicData(int id) async {
    final prefs = await SharedPreferences.getInstance();

    final token = await prefs.getString('token') ?? '';

    return ChatScreen(
      chatRepository: ChatRepository(
        StudyJamClient().getAuthorizedClient(token),
      ),
    );
  }

  visitTopic(int id) async {
    return await topicData(id);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        child: GestureDetector(
          onTap: () => Navigator.push<ChatScreen>(
            context,
            MaterialPageRoute(
              builder: (_) {
                return visitTopic(chatTopic.id);
              },
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _ChatAvatar(userData: chatData.chatUserDto),
              // const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      chatTopic.name ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(chatTopic.description ?? ''),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicAppBar extends StatelessWidget {
  final VoidCallback onUpdatePressed;

  const _TopicAppBar({
    required this.onUpdatePressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: onUpdatePressed,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
