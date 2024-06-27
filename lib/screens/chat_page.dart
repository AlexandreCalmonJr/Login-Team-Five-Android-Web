import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  bool _isOnline = true; // Exemplo de usuário online

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
            _isOnline
                ? const Icon(Icons.circle, color: Colors.green, size: 12)
                : const SizedBox(),
          ],
        ),
      ),
      body: DefaultTabController(
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
                  // Aqui você pode adicionar a tela de troca de imagens e documentos
                  Center(
                    child: Text(
                      'Aqui será a tela para trocar imagens e documentos',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1.0),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Digite sua mensagem...',
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
    );
  }

  void _sendMessage(String text) {
    if (text.isNotEmpty) {
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            text: text,
            isSentByMe: true,
          ),
        );
        _messageController.clear();
      });
      // Simula resposta do outro usuário após 1 segundo
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
              text: 'Resposta automática.',
              isSentByMe: false,
            ),
          );
        });
      });
    }
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isSentByMe;

  const ChatMessage({
    required this.text,
    required this.isSentByMe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
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
    );
  }
}