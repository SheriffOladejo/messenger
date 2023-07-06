class Message {

  int id;
  int timestamp;
  String text;
  String groupDate;
  String recipientNumber;
  String recipientName;
  String sender;
  String backup;
  bool isSelected = false;

  Message({
    this.id,
    this.text,
    this.timestamp,
    this.groupDate,
    this.recipientNumber,
    this.recipientName,
    this.sender,
    this.isSelected,
    this.backup,
  });

}