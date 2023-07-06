import 'package:messenger/adapters/contacts_adapter.dart';
import 'package:messenger/models/contact.dart';
import 'package:messenger/utils/methods.dart';
import 'package:messenger/utils/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart' as c;


class SelectContacts extends StatefulWidget {
  const SelectContacts({Key key}) : super(key: key);

  @override
  State<SelectContacts> createState() => _SelectContactsState();
}

class _SelectContactsState extends State<SelectContacts> {
  List<Contact> contactList = [];
  List<Contact> selectedContacts = [];
  List<Contact> searchList = [];

  bool isLoading = false;
  bool isForward = false;

  var focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(left: 15),
          child: GestureDetector(
            onTap: () {
              Navigator.maybePop(context, selectedContacts);
            },
            child: const Text(
              'Done',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'inter-bold',
              ),
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          SearchWidget(
            isForward: isForward,
            callback: callback,
            focusNode: focusNode,
          ),
        ],
      ),
      body: isLoading
          ? loadingPage()
          : SafeArea(
              child: contactList != null
                  ? ListView.builder(
                      itemCount: searchList.isNotEmpty ? searchList.length : contactList?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        Contact c = searchList.isNotEmpty ? searchList?.elementAt(index) : contactList?.elementAt(index);
                        return ContactsAdapter(contact: c, selectedContacts: selectedContacts,);
                      },
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
    );
  }

  void callback(String search) async {
    setState(() {

    });
    if (search.isNotEmpty) {
      setState(() {
        isForward = true;
        isLoading = true;
      });
      await searchContacts(search.trim().toLowerCase());
    }
    else {
      searchList = [];
      setState(() {
        isForward = false;
      });
    }
  }

  Future<void> searchContacts(String search) async {
    searchList.clear();
    for (var i = 0; i < contactList.length; i++) {
      if (contactList[i].contact.displayName != null && contactList[i].contact.displayName.toLowerCase().contains(search)) {
        searchList.add(contactList[i]);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> init() async {
    setState(() {
      isLoading = true;
    });
    await getContacts();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> getContacts() async {
    // Load without thumbnails initially.
    var contacts = (await c.ContactsService.getContacts(withThumbnails: false));
    for (var i = 0; i < contacts.length; i++) {
      Contact c = Contact(contact: contacts[i], isSelected: false);
      contactList.add(c);
    }

    setState(() {

    });

    // Lazy load thumbnails after rendering initial contacts.
    for (final contact in contacts) {
      c.ContactsService.getAvatar(contact).then((avatar) {
        if (avatar == null) return;
        setState(() => contact.avatar = avatar);
      });
    }
  }
}
