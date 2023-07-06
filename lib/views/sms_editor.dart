import 'package:messenger/adapters/message_adapter.dart';
import 'package:messenger/models/message.dart';
import 'package:messenger/utils/db_helper.dart';
import 'package:flutter/material.dart';

class SMSEditor extends StatefulWidget {
  const SMSEditor({Key key}) : super(key: key);

  @override
  State<SMSEditor> createState() => _SMSEditorState();

}

class _SMSEditorState extends State<SMSEditor> {

  bool is_loading = false;

  var db_helper = DbHelper();

  List<Message> conversations = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: false,
        title: const Text(
          "SMS Editor",
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'inter-bold',
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 10),
        child: ListView.separated(
          separatorBuilder: (context, index) {
            return const Divider();
          },
          controller: ScrollController(),
          itemCount: conversations.length,
          shrinkWrap: false,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          itemBuilder: (context, index){
            return MessageAdapter(
              message: conversations[index],
              callback: callback,
            );
          },
        ),
      ),
    );
  }

  Future<void> callback() async {
    conversations = await db_helper.getConversations();
    conversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> init() async {
    setState(() {
      is_loading = true;
    });
    conversations = await db_helper.getConversations();
    conversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    setState(() {
      is_loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

}
