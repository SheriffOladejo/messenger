import 'package:messenger/models/message.dart';
import 'package:messenger/utils/db_helper.dart';
import 'package:messenger/utils/hex_color.dart';
import 'package:messenger/utils/methods.dart';
import 'package:messenger/views/select_contacts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:messenger/models/contact.dart';

class ScheduleMessage extends StatefulWidget {
  const ScheduleMessage({Key key}) : super(key: key);

  @override
  State<ScheduleMessage> createState() => _ScheduleMessageState();
}

class _ScheduleMessageState extends State<ScheduleMessage> {
  final form_key = GlobalKey<FormState>();

  bool is_loading = false;

  var db_helper = DbHelper();

  List<Contact> selectedContact = [];
  List<String> recipients = [];
  var numberController = TextEditingController();
  var messageController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  String sender = "";

  String mDate = "";
  String mTime = "";

  @override
  Widget build(BuildContext context) {
    var date = DateFormat('MMMM dd, yyyy').format(selectedDate);
    final localizations = MaterialLocalizations.of(context);
    final formattedTimeOfDay = localizations.formatTimeOfDay(selectedTime);
    return is_loading
        ? loadingPage()
        : Scaffold(
            backgroundColor: HexColor("#F5F5F5"),
            appBar: AppBar(
              backgroundColor: HexColor("#F5F5F5"),
              iconTheme: IconThemeData(color: Colors.black),
              title: Text(
                "Schedule message",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'inter-bold',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              elevation: 0,
            ),
            body: Form(
              key: form_key,
              child: SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width - 30,
                        alignment: Alignment.center,
                        child: TextFormField(
                          controller: numberController,
                          validator: (value) {
                            bool ccMissing = false;
                            List<String> list = numberController.text.split(",");
                            for (var i = 0; i < list.length; i++) {
                              if (list[i].replaceAll(" ", "").substring(0, 1) != "+") {
                                ccMissing = true;
                              }
                            }
                            if (ccMissing) {
                              return "Country code is required";
                            }
                            else if (value.isEmpty) {
                              return "Select contact";
                            }

                            return null;
                          },
                          minLines: 1,
                          maxLines: 10,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "To: Enter recipient's phone number",
                              hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontFamily: 'inter-medium',
                                  fontSize: 14),
                              prefixIcon: GestureDetector(
                                  onTap: () async {
                                    selectedContact = await Navigator.push(context, MaterialPageRoute(builder: (context) => const SelectContacts()));
                                    numberController.text = "";
                                    for (int i = 0; i < selectedContact.length; i++) {
                                      if (selectedContact[i].contact.phones.isNotEmpty) {
                                        if (i == selectedContact.length - 1) {
                                          numberController.text += selectedContact[i].contact.phones[0].value;
                                        }
                                        else {
                                          numberController.text += "${selectedContact[i].contact.phones[0].value}, ";
                                        }
                                        recipients.add(selectedContact[i].contact.phones[0].value);
                                      }
                                    }
                                    setState(() {

                                    });
                                  },
                                  child: const Icon(Icons.contact_phone,)
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(10),
                              )
                          ),
                        ),
                      ),
                      Container(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Required";
                                  }
                                  return null;
                                },
                                controller: messageController,
                                minLines: 4,
                                maxLines: 10,
                                decoration: InputDecoration(
                                  hintText: "Type message",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                    fontFamily: 'inter-regular',
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Image.asset('assets/images/send_.png'),
                              onPressed: () async {
                                if (form_key.currentState.validate()) {
                                  await send();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(height: 10,),
                      InkWell(
                        onTap: () async {
                          final DateTime picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101));
                          if (picked != null && picked != selectedDate) {
                            int timestamp = DateTime(selectedDate.year, selectedDate.month,
                                selectedDate.day, selectedTime.hour, selectedTime.minute)
                                .millisecondsSinceEpoch;
                            DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
                            mDate = DateFormat('MMM d, y').format(date);
                            setState(() {
                              selectedDate = picked;
                            });
                          }
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
                                Icon(Icons.calendar_month, color: HexColor("#7D7D7D"),),
                                Container(
                                  width: 10,
                                ),
                                Text(
                                  "Set delivery day",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'inter-medium',
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  date,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'inter-medium',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(height: 10,),
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
                        child: Card(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(15),
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              children: [
                                Image.asset("assets/images/clock.png"),
                                Container(
                                  width: 10,
                                ),
                                Text(
                                  "Set delivery time",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'inter-medium',
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  "$formattedTimeOfDay",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'inter-medium',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    ],
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
      // conversations = await db_helper.getConversations();
      setState(() {
        is_loading = false;
      });
      // conversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
  }

}
