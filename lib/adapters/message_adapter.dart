import 'dart:ffi';

import 'package:messenger/models/message.dart';
import 'package:messenger/utils/hex_color.dart';
import 'package:messenger/utils/methods.dart';
import 'package:messenger/views/conversation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageAdapter extends StatelessWidget {

  Message message;
  Function callback;
  bool first;
  bool last;

  MessageAdapter({
    this.message,
    this.callback,
    this.first,
    this.last,
  });

  @override
  Widget build(BuildContext context) {

    var date = DateTime.fromMillisecondsSinceEpoch(message.timestamp);
    var timestamp = DateFormat('E, MMM d y').format(date);

    String receiver;

    if (message.recipientName == '') {
      receiver = message.recipientNumber;
    }
    else {
      receiver = message.recipientName;
    }

    BorderRadius radius;

    if (first) {
      radius = BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16));
    }
    else if (last) {
      radius = BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16));
    }
    else {
      radius = BorderRadius.all(Radius.circular(0));
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).push(slideLeft(Conversation(message: message, callback: callback,)));
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: radius
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(receiver, style: TextStyle(
                color: Colors.black,
                fontFamily: 'inter-bold',
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),),
              Container(height: 5,),
              Text(timestamp, style: TextStyle(
                color: HexColor("#7D7D7D"),
                fontFamily: 'inter-regular',
                fontWeight: FontWeight.w300,
                fontSize: 8,
              ),),
              Container(height: 5,),
              Text(message.text, style: TextStyle(
                color: Colors.black,
                fontFamily: 'inter-medium',
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),),
            ],
          ),
        ),
      ),
    );
  }
}
