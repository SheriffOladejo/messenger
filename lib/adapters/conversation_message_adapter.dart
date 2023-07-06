import 'package:messenger/models/message.dart';
import 'package:messenger/utils/db_helper.dart';
import 'package:messenger/utils/hex_color.dart';
import 'package:messenger/utils/methods.dart';
import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:intl/intl.dart';

class ConversationMessageAdapter extends StatefulWidget {

  Message message;
  bool last;
  Function callback;
  ConversationMessageAdapter({this.callback, this.message, this.last});

  @override
  State<ConversationMessageAdapter> createState() => _ConversationMessageAdapterState();

}

class _ConversationMessageAdapterState extends State<ConversationMessageAdapter> {

  @override
  Widget build(BuildContext context) {

    var date = DateTime.fromMillisecondsSinceEpoch(widget.message.timestamp);
    var timestamp = DateFormat('hh:mm a').format(date);

    bool pending = false;
    if (widget.message.timestamp > DateTime.now().millisecondsSinceEpoch) {
      pending = true;
    }

    return GestureDetector(
      onTap: () {
        showOptionsDialog(context);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          BubbleSpecialThree(
            text: widget.message.text,
            color: HexColor("#9D6FB0"),
            tail: widget.last,
            isSender: true,
            sent: true,
            textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 16
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  padding: const EdgeInsets.only(right: 5),
                  child: Text(timestamp, style: const TextStyle(color: Colors.grey, fontFamily: 'inter-regular', fontSize: 10),)
              ),
              pending ? Image.asset('assets/images/clock.png') : Container(),
              Container(width: 10,),
            ],
          ),
          Container(height: 5,),
        ],
      ),
    );

  }

  showOptionsDialog(BuildContext context){
    AlertDialog d = AlertDialog(
      title: const Text("Select an option"),
      content: Container(
        padding: const EdgeInsets.all(5.0),
        height: 60,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 5,),
            GestureDetector(
              onTap: () async {
                var db = DbHelper();
                showToast("Deleting message, please wait");
                await db.deleteMessage(widget.message);
                await widget.callback();
                Navigator.pop(context);
              },
              child: Container(
                alignment: Alignment.centerLeft,
                child: const Text("Delete message"),
              ),
            ),
            Container(height: 5,),
          ],
        ),
      ),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return d;
      },
    );
  }


}
