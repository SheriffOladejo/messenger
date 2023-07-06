import 'dart:collection';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:messenger/adapters/conversation_message_adapter.dart';
import 'package:messenger/models/message.dart';
import 'package:messenger/utils/db_helper.dart';
import 'package:messenger/utils/hex_color.dart';
import 'package:messenger/utils/methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';

class Conversation extends StatefulWidget {

  Message message;
  Function callback;

  Conversation({this.message, this.callback});

  @override
  State<Conversation> createState() => _ConversationState();

}

class _ConversationState extends State<Conversation> {

  List<Message> messageList = [];
  List<Widget> messagesWidget = [];

  bool is_loading = false;

  var db_helper = DbHelper();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  var timestamp = DateTime.now().millisecondsSinceEpoch;

  var messageController = TextEditingController();

  String sender = "";

  bool isSchedule = false;

  List<dynamic> getGroupDate() {
    messagesWidget = [];
    var groupDateList = [];
    HashMap groupDateMessageMap = HashMap<String, List<Message>>();

    for (var i = 0; i < messageList.length; i++) {
      if (!groupDateList.contains(messageList[i].groupDate)) {
        groupDateList.add(messageList[i].groupDate);
      }
    }

    for (var i = 0; i < groupDateList.length; i++) {
      for (var j = 0; j < messageList.length; j++) {
        if (messageList[j].groupDate == groupDateList[i]) {
          List<Message> list = groupDateMessageMap[groupDateList[i]];
          if (list == null || list.isEmpty) {
            groupDateMessageMap[groupDateList[i]] = [messageList[j]];
          }
          else {
            list.add(messageList[j]);
            groupDateMessageMap[groupDateList[i]] = list;
          }
        }
      }
    }

    for (var i = 0; i < groupDateList.length; i++) {
      List<Message> l = groupDateMessageMap[groupDateList[i]];
      messagesWidget.add(DateChip(date: DateTime.fromMillisecondsSinceEpoch(l[0].timestamp)));
      for (var j = 0; j < l.length; j++) {
        bool last = false;
        if (j == l.length-1) {
          last = true;
        }
        messagesWidget.add(ConversationMessageAdapter(
          last: last,
          message: l[j],
          callback: callback,
        ));
      }
    }

  }

  @override
  Widget build(BuildContext context) {

    String title;

    if (widget.message.recipientName == widget.message.recipientNumber) {
      title = widget.message.recipientName;
    }
    else if (widget.message.recipientName.isEmpty) {
      title = widget.message.recipientNumber;
    }
    else if (widget.message.recipientName.isNotEmpty && widget.message.recipientNumber.isNotEmpty) {
      title = "${widget.message.recipientName} \n(${widget.message.recipientNumber})";
    }
    else {
      title = widget.message.recipientName;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () async {
            await widget.callback();
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.arrow_back, color: Colors.black,)),
        ),
        title: Row(
          children: [
            Container(
                alignment: Alignment.topLeft,
                child: Image.asset("assets/images/user.png",)),
            Container(width: 10,),
            Text(title, style: const TextStyle(
            color: Colors.black,
            fontFamily: 'inter-bold',
            fontSize: 14),
            softWrap: true,
            ),
          ],
        )
      ),
      body: is_loading ? loadingPage() : Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: SingleChildScrollView(
          child: Column(
            children: messagesWidget
          )
        ),
      ),
      bottomSheet: Container(
        width: MediaQuery.of(context).size.width,
        height: 70,
        color: HexColor("#F5F5F5"),
        child: Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(70)),
              color: Colors.white
          ),
          margin: const EdgeInsets.fromLTRB(15, 0, 15, 20),
          //padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(height: 1,),
              SizedBox(
                width: MediaQuery.of(context).size.width - 100,
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Required";
                    }
                    return null;
                  },
                  controller: messageController,
                  minLines: 1,
                  maxLines: 10,
                  decoration: const InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: InputBorder.none,
                      hintText: "Type message",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontFamily: 'inter-regular',
                      )
                  ),
                ),
              ),
              GestureDetector(
                child: Image.asset('assets/images/send_.png'),
                onTap: () async {
                  await send();
                },
              ),
              Container(width: 10,),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> callback() async {
    messageList = await db_helper.getConversation(widget.message.recipientNumber);
    messageList.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    setState(() {
      is_loading = false;
    });
  }

  Future<void> init() async {
    setState(() {
      is_loading = true;
    });
    messageList = await db_helper.getConversation(widget.message.recipientNumber);
    messageList.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    sender = await db_helper.getPhone();
    isSchedule = false;
    selectedDate = DateTime.now();
    selectedTime = TimeOfDay.now();
    getGroupDate();
    setState(() {
      is_loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> send() async {
    timestamp = DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
        selectedTime.hour, selectedTime.minute).millisecondsSinceEpoch;
    String message = messageController.text.trim();
    var m = Message(
        id: DateTime.now().millisecondsSinceEpoch,
        text: message,
        recipientName: widget.message.recipientName,
        recipientNumber: widget.message.recipientNumber,
        timestamp: timestamp,
        sender: sender,
        groupDate: "",
        isSelected: false,
        backup: 'false'
    );
    messageController.text = "";
    await db_helper.saveMessage(m);
    if (isSchedule) {
      await db_helper.scheduleMessage(m);
    }
    else {
      await sendSMS(message: message, recipients: [widget.message.recipientNumber], sendDirect: true)
          .catchError((onError) {
        print(onError);
      });
    }
    await init();
  }

}
