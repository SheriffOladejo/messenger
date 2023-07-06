import 'dart:io';
import 'package:messenger/views/schedule_message.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:messenger/adapters/message_adapter.dart';
import 'package:messenger/models/message.dart';
import 'package:messenger/utils/db_helper.dart';
import 'package:messenger/utils/hex_color.dart';
import 'package:messenger/utils/methods.dart';
import 'package:messenger/views/backup.dart';
import 'package:messenger/views/new_message.dart';
import 'package:messenger/views/sms_editor.dart';
import 'package:flutter/material.dart';
import 'package:messenger/models/contact.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';

import 'select_contacts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String iconColor = "#9D6FB0";

  final form_key = GlobalKey<FormState>();

  bool is_loading = false;

  var db_helper = DbHelper();

  List<Message> conversations = [];

  List<Contact> selectedContact = [];
  List<String> recipients = [];
  var numberController = TextEditingController();
  var messageController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  String sender = "";

  int count = 0;

  @override
  Widget build(BuildContext context) {
    callback();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Welcome!",
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'inter-bold',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        elevation: 0,
      ),
      body: is_loading
          ? loadingPage()
          :
          mainPage(),
    );
  }

  Widget mainPage() {
    return CustomScrollView(
      slivers: [
        SliverList(
            delegate: SliverChildListDelegate([
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewMessage(
                              callback: callback,
                            )));
                  },
                  child: Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(15),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Image.asset("assets/images/send_sms.png"),
                          Container(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Send SMS",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'inter-medium',
                                ),
                              ),
                              Container(
                                height: 5,
                              ),
                              Text(
                                "Send text message to contacts",
                                style: TextStyle(
                                  color: HexColor("#808080"),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'inter-medium',
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward,
                            size: 24,
                            color: HexColor(iconColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ScheduleMessage(

                            )));
                  },
                  child: Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(15),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Image.asset("assets/images/schedule_message.png"),
                          Container(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Schedule message",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'inter-medium',
                                ),
                              ),
                              Container(
                                height: 5,
                              ),
                              Text(
                                "Schedule messages to be sent later",
                                style: TextStyle(
                                  color: HexColor("#808080"),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'inter-medium',
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward,
                            size: 24,
                            color: HexColor(iconColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Backup()));
                  },
                  child: Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(slideLeft(Backup(
                          callback: callback,
                        )));
                      },
                      child: Container(
                        margin: const EdgeInsets.all(15),
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: [
                            Image.asset("assets/images/backup.png"),
                            Container(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Backup & Restore",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'inter-medium',
                                  ),
                                ),
                                Container(
                                  height: 5,
                                ),
                                Text(
                                  "Backup and restore your messages",
                                  style: TextStyle(
                                    color: HexColor("#808080"),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'inter-medium',
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Icon(
                              Icons.arrow_forward,
                              size: 24,
                              color: HexColor(iconColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 10,
                ),
                InkWell(
                  onTap: () async {
                    showDialog(
                        useSafeArea: false,
                        context: context,
                        builder: (ctx) => AlertDialog(
                            backgroundColor: Colors.transparent,
                            contentPadding: const EdgeInsets.all(0),
                            content: OptionsDialog()));
                  },
                  child: Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(15),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Image.asset("assets/images/privacy_policy.png"),
                          Container(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Privacy policy",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'inter-medium',
                                ),
                              ),
                              Container(
                                height: 5,
                              ),
                              Text(
                                "",
                                style: TextStyle(
                                  color: HexColor("#808080"),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'inter-medium',
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward,
                            size: 24,
                            color: HexColor(iconColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 15,
                ),
                Text(
                  "Messaging history",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'inter-bold',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                Container(
                  height: 15,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 2,
                  child: ListView.builder(
                    controller: ScrollController(),
                    itemCount: conversations.length,
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return MessageAdapter(
                        message: conversations[index],
                        callback: callback,
                        first: index == 0,
                        last: index == conversations.length - 1,
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        ]))
      ],
    );
  }

  Future<void> callback() async {
    conversations = await db_helper.getConversations();
    conversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    setState(() {});
  }

  Future<void> init() async {
    setState(() {
      is_loading = true;
    });
    Map<Permission, PermissionStatus> statuses = await [
      Permission.sms,
      Permission.contacts,
    ].request();
    conversations = await db_helper.getConversations();
    conversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    sender = await db_helper.getPhone();
    setState(() {
      is_loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  Widget scheduleMessage() {
    var date = DateFormat('MMMM dd, yyyy').format(selectedDate);
    final localizations = MaterialLocalizations.of(context);
    final formattedTimeOfDay = localizations.formatTimeOfDay(selectedTime);
    return is_loading
        ? loadingPage()
        : Scaffold(
            backgroundColor: Colors.white,
            body: Form(
              key: form_key,
              child: Container(
                color: Colors.transparent,
                margin: const EdgeInsets.only(top: 0),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(15),
                      topLeft: Radius.circular(15),
                    ),
                    color: HexColor("#E1F7FE"),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          topLeft: Radius.circular(15),
                        )),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 5,
                        ),
                        Container(
                          width: 100,
                          height: 5,
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                        ),
                        Container(
                          height: 25,
                        ),
                        const Text(
                          "Schedule message",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'inter-regular',
                          ),
                        ),
                        Container(
                          height: 15,
                        ),
                        const Text(
                            "Schedule message to be sent at a later date and time"),
                        Container(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 200,
                              child: TextFormField(
                                validator: (value) {
                                  bool ccMissing = false;
                                  List<String> list = value.split(",");
                                  for (var i = 0; i < list.length; i++) {
                                    if (list[i].substring(0, 1) != "+") {
                                      ccMissing = true;
                                    }
                                  }
                                  if (ccMissing) {
                                    return "Country code is required";
                                  } else if (value.isEmpty) {
                                    return "Required";
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.phone,
                                controller: numberController,
                                minLines: 1,
                                maxLines: 5,
                                decoration: InputDecoration(
                                  prefixIcon: GestureDetector(
                                      onTap: () async {
                                        selectedContact = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const SelectContacts()));
                                        numberController.text = "";
                                        for (int i = 0;
                                            i < selectedContact.length;
                                            i++) {
                                          if (selectedContact[i]
                                              .contact
                                              .phones
                                              .isNotEmpty) {
                                            if (i ==
                                                selectedContact.length - 1) {
                                              numberController.text +=
                                                  selectedContact[i]
                                                      .contact
                                                      .phones[0]
                                                      .value;
                                            } else {
                                              numberController.text +=
                                                  "${selectedContact[i].contact.phones[0].value}, ";
                                            }
                                            recipients.add(selectedContact[i]
                                                .contact
                                                .phones[0]
                                                .value);
                                          }
                                        }
                                        setState(() {});
                                      },
                                      child: const Icon(Icons.contact_phone)),
                                  border: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  hintStyle: TextStyle(color: Colors.grey[800]),
                                  hintText: "Recipient phone",
                                ),
                              ),
                            ),
                            Container(
                              width: 100,
                              alignment: Alignment.center,
                              child: MaterialButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await send();
                                },
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                padding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                color: HexColor("#4897FA"),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Send",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontFamily: 'inter-bold'),
                                    ),
                                    Container(
                                      width: 5,
                                    ),
                                    Image.asset(
                                      "assets/images/send.png",
                                      width: 20,
                                      height: 20,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        Container(height: 20),
                        TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Message is required";
                            }
                            return null;
                          },
                          controller: messageController,
                          minLines: 1,
                          maxLines: 20,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            hintStyle: TextStyle(color: Colors.grey[800]),
                            hintText: "Type in your message",
                          ),
                        ),
                        Container(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () async {
                            final DateTime picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2101));
                            if (picked != null && picked != selectedDate) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_month,
                                size: 24,
                                color: Colors.grey,
                              ),
                              Container(
                                width: 15,
                              ),
                              Column(
                                children: [
                                  const Text(
                                    "Select date",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'inter-regular',
                                        fontSize: 10),
                                  ),
                                  Container(
                                    height: 5,
                                  ),
                                  Text(
                                    date,
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontFamily: 'inter-regular',
                                        fontSize: 8),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const Divider(
                          color: Colors.blue,
                        ),
                        Container(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () async {
                            final TimeOfDay picked = await showTimePicker(
                                context: context, initialTime: TimeOfDay.now());
                            if (picked != null && picked != selectedTime) {
                              setState(() {
                                selectedTime = picked;
                              });
                            }
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 24,
                                color: Colors.grey,
                              ),
                              Container(
                                width: 15,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Select time",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'inter-regular',
                                        fontSize: 10),
                                  ),
                                  Container(
                                    height: 5,
                                  ),
                                  Text(
                                    formattedTimeOfDay,
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontFamily: 'inter-regular',
                                        fontSize: 8),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const Divider(
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  Future<void> send() async {
    if (form_key.currentState.validate()) {
      setState(() {
        //is_loading = true;
      });
      int timestamp = DateTime(selectedDate.year, selectedDate.month,
              selectedDate.day, selectedTime.hour, selectedTime.minute)
          .millisecondsSinceEpoch;
      DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      String formattedDate = DateFormat('MMM d, y').format(date);
      print("formatted dsate: $formattedDate");
      String message = messageController.text.trim();
      recipients = numberController.text.split(",");
      String name = "";

      if (selectedContact.isNotEmpty) {
        for (var i = 0; i < selectedContact.length; i++) {
          name = selectedContact[i].contact.displayName ??
              selectedContact[i].contact.phones[0].value;
          var m = Message(
              id: DateTime.now().millisecondsSinceEpoch,
              text: message,
              recipientName: name,
              recipientNumber: selectedContact[i].contact.phones[0].value,
              timestamp: timestamp,
              sender: sender,
              groupDate: "",
              isSelected: false,
              backup: 'false');
          await db_helper.scheduleMessage(m);
          await db_helper.saveMessage(m);
        }
      } else {
        for (var i = 0; i < recipients.length; i++) {
          name = recipients[i];
          var m = Message(
              id: DateTime.now().millisecondsSinceEpoch,
              text: message,
              recipientName: name,
              recipientNumber: recipients[i],
              timestamp: timestamp,
              sender: sender,
              groupDate: "",
              isSelected: false,
              backup: 'false');
          await db_helper.scheduleMessage(m);
          await db_helper.saveMessage(m);
        }
      }
      showToast("Message scheduled");
      messageController.text = "";
      numberController.text = "";
      selectedTime = TimeOfDay.now();
      selectedDate = DateTime.now();
      conversations = await db_helper.getConversations();
      setState(() {
        is_loading = false;
      });
      conversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
  }
}

class OptionsDialog extends StatefulWidget {

  Function callback;

  OptionsDialog({this.callback});

  @override
  State<OptionsDialog> createState() => _OptionsDialogState();
}

class _OptionsDialogState extends State<OptionsDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: MediaQuery.of(context).size.width,
      color: Colors.transparent,
      child: Column(
        children: [
          InkWell(
            onTap: () async {
              Navigator.pop(context);
              var url = "https://docs.google.com/document/d/1_WrY9nSwO-yQbsnL_hcYq2tSQ60-7nRECuYFE6bvnpQ/edit?usp=sharing";
              if(await canLaunch(url)){
                await launch(url);
              }
              else{
                showToast("Cannot launch URL");
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 88,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: HexColor("#F9F9FE"),
                borderRadius: const BorderRadius.all(Radius.circular(3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                  ),
                  const Text(
                    "Privacy policy",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      fontFamily: 'inter-regular',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 5,
          ),
          InkWell(
            onTap: () async {
              Navigator.pop(context);
              var url = "https://docs.google.com/document/d/1NMvhNmQ7DksCYhOblkegA9NSCigiK9vGNclQJN9uAW8/edit?usp=sharing";
              if(await canLaunch(url)){
                await launch(url);
              }
              else{
                showToast("Cannot launch URL");
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 88,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: HexColor("#F9F9FE"),
                borderRadius: const BorderRadius.all(Radius.circular(3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                  ),
                  const Text(
                    "Terms of use",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      fontFamily: 'inter-regular',
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

}
