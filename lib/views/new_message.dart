import 'package:messenger/models/contact.dart';
import 'package:messenger/models/message.dart';
import 'package:messenger/utils/db_helper.dart';
import 'package:messenger/utils/methods.dart';
import 'package:messenger/views/select_contacts.dart';
import 'package:flutter/material.dart';
import '../utils/hex_color.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:permission_handler/permission_handler.dart';

class NewMessage extends StatefulWidget {

  Function callback;

  NewMessage({
    this.callback,
  });

  @override
  State<NewMessage> createState() => _NewMessageState();

}

class _NewMessageState extends State<NewMessage> {

  List<Contact> selectedContact = [];
  List<String> recipients = [];

  bool editable = true;
  bool isLoading = false;

  final form_key = GlobalKey<FormState>();

  var numberController = TextEditingController();
  var messageController = TextEditingController();

  var db_helper = DbHelper();

  String sender = "";

  @override
  Widget build(BuildContext context) {
    return Form(
      key: form_key,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: HexColor("#F5F5F5"),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          title: const Text("New message", style: TextStyle(
              color: Colors.black,
              fontFamily: 'inter-bold',
              fontSize: 18,
              fontWeight: FontWeight.w600,
          ),
          ),
        ),
        body: isLoading ? loadingPage() : Container(
          color: HexColor("#F5F5F5"),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(15),
                child: Row(
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
                    )
                  ],
                ),
              )
            ],
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
                    if (form_key.currentState.validate()) {
                      await send();
                    }
                  },
                ),
                Container(width: 10,),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> init() async {
    setState(() {
      isLoading = true;
    });
    //await _askPermissions(null);
    Map<Permission, PermissionStatus> statuses = await [
      Permission.sms,
      Permission.contacts,
    ].request();
    sender = await db_helper.getPhone();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> _askPermissions(String routeName) async {
    PermissionStatus smsStatus = await _getSMSPermission();
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      if (routeName != null) {
        Navigator.of(context).pushNamed(routeName);
      }
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  Future<PermissionStatus> _getSMSPermission() async {
    PermissionStatus permission = await Permission.sms.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      final snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      final snackBar =
      SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> send() async {
    setState(() {
      isLoading = true;
    });

    String message = messageController.text.trim();
    recipients = numberController.text.split(",");
    String name = "";

    if (selectedContact.isNotEmpty) {
      for (var i = 0; i < selectedContact.length; i++) {
        name = selectedContact[i].contact.displayName ?? selectedContact[i].contact.phones[0].value;
        await sendSMS(message: message, recipients: [selectedContact[i].contact.phones[0].value.replaceAll(" ", "")], sendDirect: true)
            .catchError((onError) {
          print(onError);
        });
        var timestamp = DateTime.now().millisecondsSinceEpoch;
        var m = Message(
            id: timestamp,
            text: message,
            recipientName: name,
            recipientNumber: selectedContact[i].contact.phones[0].value,
            timestamp: timestamp,
            sender: sender,
            groupDate: "",
            isSelected: false,
            backup: 'false'
        );
        await db_helper.saveMessage(m);
      }
    }
    else {
      for (var i = 0; i < recipients.length; i++) {
        name = recipients[i];
        await sendSMS(message: message, recipients: [recipients[i]], sendDirect: true)
            .catchError((onError) {
          print(onError);
        });
        var timestamp = DateTime.now().millisecondsSinceEpoch;
        var m = Message(
          id: timestamp,
          text: message,
          recipientName: name,
          recipientNumber: recipients[i],
          timestamp: timestamp,
          sender: sender,
          groupDate: "",
          isSelected: false,
          backup: 'false'
        );
        await db_helper.saveMessage(m);
      }
    }

    messageController.text = "";
    numberController.text = "";

    setState(() {
      isLoading = false;
    });
    showToast("Message sent");
    await widget.callback();
    Navigator.pop(context);
  }

}
