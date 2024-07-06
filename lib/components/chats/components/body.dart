import 'package:firebase_login/app/constants.dart';
import 'package:firebase_login/components/filled_outline_button.dart';
import 'package:firebase_login/components/messages/message_screen.dart';
import 'package:firebase_login/models/Chat.dart';
import 'package:firebase_login/models/user_model.dart';
import 'package:flutter/material.dart';

import 'chat_card.dart';

class Body extends StatelessWidget {
  final UserModel user;

  const Body({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(
              kDefaultPadding, 0, kDefaultPadding, kDefaultPadding),
          color: kPrimaryColor,
          child: Row(
            children: [
              FillOutlineButton(press: () {}, text: "Mensagens Recentes"),
              const SizedBox(width: kDefaultPadding),
              FillOutlineButton(
                press: () {},
                text: "Online",
                isFilled: false,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: chatsData.length,
            itemBuilder: (context, index) => ChatCard(
              chat: chatsData[index],
              press: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessagesScreen(user: user),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
