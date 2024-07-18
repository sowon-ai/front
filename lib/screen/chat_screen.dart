import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false; // 로딩 상태를 나타내는 변수

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) {
      return; // 입력된 텍스트가 비어 있거나 공백만 있는 경우 반환
    }

    _textController.clear();
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true; // 응답을 기다리는 동안 로딩 상태로 설정
    });

    // 새 메시지가 추가된 후 스크롤을 맨 아래로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // 백엔드로부터 응답 받기
    final response = await _getResponseFromBackend(text);
    if (response != null) {
      setState(() {
        _messages.add({'role': 'bot', 'content': response});
      });
    }
    setState(() {
      _isLoading = false; // 응답을 받은 후 로딩 상태 해제
    });

    // 새 메시지가 추가된 후 스크롤을 맨 아래로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<String?> _getResponseFromBackend(String message) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/chat'), // 백엔드 서버 주소
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'];
      } else {
        print('Failed to get response from backend');
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  void _clearMessages() {
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Colors.blueAccent.shade200,
          title: const Row(
            children: [
              Text(
                "Sowon_AI",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 10),
              Icon(
                Icons.chat,
                color: Colors.white,
              ),
            ],
          ),
          actions: [
            IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _clearMessages,
            ),
          ],
        ),
        body: Stack(
          children: [
            ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length +
                  (_isLoading ? 1 : 0), // 로딩 상태일 때 추가로 항목을 하나 더 표시
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 10.0),
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.shade200,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              topRight: Radius.circular(15.0),
                              bottomLeft: Radius.circular(0.0),
                              bottomRight: Radius.circular(15.0),
                            ),
                          ),
                          child: Image.asset(
                            'assets/images/emoji/emoji1.png',
                            width: 20,
                          )),
                    ),
                  );
                }
                final message = _messages[index];
                final isUserMessage = message['role'] == 'user';
                return Align(
                  alignment: isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 10.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: isUserMessage
                            ? Colors.blue.shade900
                            : Colors.blueAccent.shade200,
                        borderRadius: isUserMessage
                            ? const BorderRadius.only(
                                topLeft: Radius.circular(15.0),
                                topRight: Radius.circular(15.0),
                                bottomLeft: Radius.circular(15.0),
                                bottomRight: Radius.circular(0.0),
                              )
                            : const BorderRadius.only(
                                topLeft: Radius.circular(15.0),
                                topRight: Radius.circular(15.0),
                                bottomLeft: Radius.circular(0.0),
                                bottomRight: Radius.circular(15.0),
                              ),
                      ),
                      child: Text(
                        message['content']!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
            if (_messages.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "궁금한점은 저에게 말씀해주세요!",
                      style: TextStyle(color: Colors.black.withOpacity(0.5)),
                    ),
                  ],
                ),
              ),
          ],
        ),
        bottomNavigationBar: Container(
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 50),
          height: 60,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: "경소고의 궁금한 점을 입력해주세요!",
                    hintStyle: const TextStyle(
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 1.0),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  cursorColor: Colors.blue,
                  maxLines: 3,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.question_mark_rounded),
                onPressed: () {
                  if (_textController.text.trim().isNotEmpty) {
                    _handleSubmitted(_textController.text.trim());
                  }
                },
                style: IconButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                  backgroundColor: Colors.blueAccent.shade200,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
