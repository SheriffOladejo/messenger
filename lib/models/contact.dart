import 'package:contacts_service/contacts_service.dart' as contacts;

class Contact {
  contacts.Contact contact;
  bool isSelected = false;

  Contact({
    this.contact,
    this.isSelected,
  });
}