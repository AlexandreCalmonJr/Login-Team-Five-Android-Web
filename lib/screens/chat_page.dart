import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:file_picker/file_picker.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final List<String> _onlineUsers = ["User1", "User2", "User3"]; // Exemplo de usuários online
  final String _currentUser = "CurrentUser"; // Substitua pelo usuário atual
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://demo.piesocket.com/v3/channel_123?api_key=VCXCEuvhGcBDP7XhiJJUDvR1e1D3eiVjgZ9VRiaV&notify_self'), // Substitua pelo seu servidor WebSocket
    );
    _channel.stream.listen((message) {
      final parsedMessage = _parseMessage(message);
      setState(() {
        _messages.insert(0, parsedMessage);
      });
    });
  }

  @override
  void dispose() {
    _channel.sink.close(status.goingAway);
    _messageController.dispose();
    super.dispose();
  }

  ChatMessage _parseMessage(String message) {
    // Supondo que a mensagem seja um JSON com os campos `text`, `username` e `isSentByMe`
    final parsed = Map<String, dynamic>.from(jsonDecode(message));
    return ChatMessage(
      text: parsed['text'],
      isSentByMe: parsed['username'] == _currentUser,
      username: parsed['username'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png', // Substitua pelo caminho da sua logo
              height: 40,
            ),
            const SizedBox(width: 8),
            const Text('Chat'),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.link),
              onPressed: () {
                // Substitua pela sua URL
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebViewPage(url: 'https://example.com'),
                  ),
                );
              },
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: SizedBox(
            height: 50.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _onlineUsers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Chip(
                    label: Text(_onlineUsers[index]),
                    avatar: const Icon(Icons.circle, color: Colors.green, size: 12),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Expanded(
                child: TabBarView(
                  children: [
                    // Lista de Mensagens
                    ListView.builder(
                      reverse: true,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _messages[index];
                      },
                    ),
                    // Placeholder para compartilhamento de arquivos e imagens
                    Center(
                      child: Text(
                        'Aqui será a tela para trocar imagens e documentos',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1.0),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: _pickFile,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Digite sua mensagem...',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _sendMessage(_messageController.text);
                      },
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.isNotEmpty) {
      final message = {
        'text': text,
        'username': _currentUser,
      };
      _channel.sink.add(jsonEncode(message));
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            text: text,
            isSentByMe: true,
            username: _currentUser,
          ),
        );
        _messageController.clear();
      });
    }
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;
      // Enviar o arquivo via WebSocket ou qualquer outro método que você esteja usando
      // Exemplo:
      final message = {
        'text': 'Arquivo enviado: ${file.name}',
        'username': _currentUser,
      };
      _channel.sink.add(jsonEncode(message));
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            text: 'Arquivo enviado: ${file.name}',
            isSentByMe: true,
            username: _currentUser,
          ),
        );
      });
    }
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isSentByMe;
  final String username;

  const ChatMessage({
    Key? key,
    required this.text,
    required this.isSentByMe,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            username,
            style: TextStyle(
              color: isSentByMe ? Colors.white : Colors.grey[300],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          decoration: BoxDecoration(
            color: isSentByMe ? Colors.blueAccent : Colors.grey[300],
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSentByMe ? Colors.white : Colors.black,
              fontSize: 16.0,
            ),
          ),
        ),
      ],
    );
  }
}

class WebViewPage extends StatelessWidget {
  final String url;

  const WebViewPage({super.key, required this.url});
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}
