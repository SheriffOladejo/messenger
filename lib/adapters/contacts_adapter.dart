import 'package:messenger/models/contact.dart';
import 'package:flutter/material.dart';

class ContactsAdapter extends StatefulWidget {

  Contact contact;
  List<Contact> selectedContacts;

  ContactsAdapter({this.contact, this.selectedContacts});

  @override
  State<ContactsAdapter> createState() => _ContactsAdapterState();
}

class _ContactsAdapterState extends State<ContactsAdapter> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: widget.contact.isSelected,
            onChanged: (newValue) {
              widget.contact.isSelected = !widget.contact.isSelected;
              if (widget.contact.isSelected) {
                widget.selectedContacts.add(widget.contact);
              }
              else {
                widget.selectedContacts.remove(widget.contact);
              }
              setState(() {

              });
            },
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 150,
            child: ListTile(
              onTap: () {
                widget.contact.isSelected = !widget.contact.isSelected;
                if (widget.contact.isSelected) {
                  widget.selectedContacts.add(widget.contact);
                }
                else {
                  widget.selectedContacts.remove(widget.contact);
                }
                setState(() {

                });
              },
              leading: (widget.contact.contact.avatar != null && widget.contact.contact.avatar.isNotEmpty)
                  ? CircleAvatar(backgroundImage: MemoryImage(widget.contact.contact.avatar))
                  : CircleAvatar(child: Text(widget.contact.contact.initials())),
              title: Text(widget.contact.contact.displayName ?? ""),
            ),
          )
        ]
      )
    );
  }
}
