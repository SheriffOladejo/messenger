import 'dart:convert';
import 'package:messenger/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:messenger/models/message.dart';
import 'package:messenger/utils/methods.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class DbHelper {

  DbHelper._createInstance();

  String db_name = "messenger.db";

  static Database _database;
  static DbHelper helper;

  String user_table = "user_table";
  String col_phone_number = "phone_number";

  String message_table = "message_table";
  String col_message_id = "id";
  String col_message_text = "text";
  String col_message_timestamp = "timestamp";
  String col_message_groupdate = "group_date";
  String col_message_recipient_number = "recipient_number";
  String col_message_recipient_name = "recipient_name";
  String col_message_sender = "sender";
  String col_message_backup = "backup";


  factory DbHelper(){
    if(helper == null){
      helper = DbHelper._createInstance();
    }
    return helper;
  }

  Future<Database> get database async {
    if(_database == null){
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<void> backup(List<Message> convos) async {
    String device_id = await getPhone();
    String hash = sha256.convert(utf8.encode(device_id)).toString();
    Database db = await database;
    for (var j = 0; j < convos.length; j++) {
      DatabaseReference ref = FirebaseDatabase.instance.ref().child("backups/$hash/${convos[j].timestamp.toString()}");
      await ref.set({
        col_message_id: convos[j].id,
        col_message_timestamp: convos[j].timestamp,
        col_message_text: convos[j].text,
        col_message_groupdate: convos[j].groupDate,
        col_message_recipient_number: convos[j].recipientNumber,
        col_message_recipient_name: convos[j].recipientName,
        col_message_sender: convos[j].sender,
      });
      String query = "update $message_table set $col_message_backup = 'true' where $col_message_id = ${convos[j].id}";
      await db.execute(query);
    }

  }

  Future<void> restore() async {
    String deviceId = await getPhone();
    String hash = sha256.convert(utf8.encode(deviceId)).toString();
    final snapshot = await FirebaseDatabase.instance.ref().child('backups/$hash/').get();
    final list = snapshot.children;
    list.forEach((element) async {
      var m = Message(
        id: int.parse(element.child(col_message_id).value.toString()),
        sender: element.child(col_message_sender).value,
        recipientName: element.child(col_message_recipient_name).value,
        recipientNumber: element.child(col_message_recipient_number).value,
        isSelected: false,
        groupDate: element.child(col_message_groupdate).value,
        backup: 'true',
        text: element.child(col_message_text).value,
        timestamp: int.parse(element.child(col_message_timestamp).value.toString()),
      );
      await saveMessage(m);
    });
  }

  Future createDb(Database db, int version) async {
    String createMessageTable = "create table $message_table ("
        "$col_message_id integer primary key,"
        "$col_message_timestamp integer,"
        "$col_message_groupdate varchar(100),"
        "$col_message_text text,"
        "$col_message_recipient_number text,"
        "$col_message_recipient_name text,"
        "$col_message_sender text,"
        "$col_message_backup varchar(10))";

    String createUserTable = "create table $user_table ("
        "$col_phone_number text)";

    await db.execute(createMessageTable);
    await db.execute(createUserTable);
  }

  Future<Database> initializeDatabase() async{
    final db_path = await getDatabasesPath();
    final path = join(db_path, db_name);
    return await openDatabase(path, version: 1, onCreate: createDb);
  }

  Future<void> savePhoneNumber(String phone) async {
    Database db = await database;
    String query = "insert into $user_table ("
        "$col_phone_number) values ('$phone')";
    await db.execute(query);
  }

  Future<String> getPhone() async {
    String phone = "";
    Database db = await database;
    String query = "select * from $user_table";
    List<Map<String, Object>> result = await db.rawQuery(query);
    for (var i = 0; i < result.length; i++) {
      phone = result[i][col_phone_number];
    }
    return phone;
  }

  Future<void> saveMessage(Message message) async {
    Database db = await database;
    String query = "insert into $message_table ("
        "$col_message_id, $col_message_timestamp, $col_message_groupdate, $col_message_text, "
        "$col_message_recipient_number, $col_message_recipient_name, $col_message_sender, $col_message_backup) values ("
        "${message.id}, '${message.timestamp}', '${message.groupDate}', '${message.text}', '${message.recipientNumber.replaceAll(' ', '')}', "
        "'${message.recipientName}', '${message.sender}', '${message.backup}')";
    await db.execute(query);
  }

  Future<List<Message>> getBackedUpMessages() async {
    Database db = await database;
    List<Message> list = [];
    List<String> numbers = [];
    String query = "select distinct $col_message_recipient_number from $message_table";
    List<Map<String, Object>> result = await db.rawQuery(query);
    for (var i = 0; i < result.length; i++) {
      numbers.add(result[i][col_message_recipient_number]);
    }

    for (var i = 0; i < numbers.length; i++) {
      String query = "select * from $message_table where $col_message_recipient_number "
          "= '${numbers[i]}' and $col_message_backup = 'true'";
      List<Map<String, Object>> result = await db.rawQuery(query);
      for (var j = 0; j < result.length; j++) {
        var m = Message(
            isSelected: false,
            id: result[j][col_message_id],
            timestamp: result[j][col_message_timestamp],
            recipientNumber: result[j][col_message_recipient_number],
            recipientName: result[j][col_message_recipient_name],
            text: result[j][col_message_text],
            sender: result[j][col_message_sender],
            groupDate: result[j][col_message_groupdate],
            backup: result[j][col_message_backup]
        );
        list.add(m);
      }
    }
    return list;
  }

  Future<List<Message>> getUnBackedUpMessages() async {
    Database db = await database;
    List<Message> list = [];
    List<String> numbers = [];
    String query = "select distinct $col_message_recipient_number from $message_table";
    List<Map<String, Object>> result = await db.rawQuery(query);
    for (var i = 0; i < result.length; i++) {
      numbers.add(result[i][col_message_recipient_number]);
    }

    for (var i = 0; i < numbers.length; i++) {
      String query = "select * from $message_table where $col_message_recipient_number "
          "= '${numbers[i]}' and $col_message_backup = 'false'";
      List<Map<String, Object>> result = await db.rawQuery(query);

      for (var j = 0; j < result.length; j++) {
        var m = Message(
            isSelected: false,
            id: result[j][col_message_id],
            timestamp: result[j][col_message_timestamp],
            recipientNumber: result[j][col_message_recipient_number],
            recipientName: result[j][col_message_recipient_name],
            text: result[j][col_message_text],
            sender: result[j][col_message_sender],
            groupDate: result[j][col_message_groupdate],
            backup: result[j][col_message_backup]
        );
        list.add(m);
      }
    }
    return list;
  }

  Future<List<Message>> getConversations() async {
    Database db = await database;
    List<Message> list = [];
    List<String> numbers = [];
    String query = "select distinct $col_message_recipient_number from $message_table";
    List<Map<String, Object>> result = await db.rawQuery(query);
    for (var i = 0; i < result.length; i++) {
      numbers.add(result[i][col_message_recipient_number]);
    }

    for (var i = 0; i < numbers.length; i++) {
      String query = "select * from $message_table where"
          " $col_message_recipient_number = '${numbers[i]}' "
          "order by $col_message_timestamp desc limit 1";
      List<Map<String, Object>> result = await db.rawQuery(query);
      for (var j = 0; j < result.length; j++) {
        var m = Message(
            isSelected: false,
            id: result[j][col_message_id],
            timestamp: result[j][col_message_timestamp],
            recipientNumber: result[j][col_message_recipient_number],
            recipientName: result[j][col_message_recipient_name],
            text: result[j][col_message_text],
            sender: result[j][col_message_sender],
            groupDate: result[j][col_message_groupdate],
            backup: result[j][col_message_backup]
        );
        list.add(m);
      }
    }
    return list;
  }

  Future<List<Message>> getConversation(String recipientNumber) async {
    Database db = await database;
    List<Message> list = [];
    String query = "select * from $message_table where $col_message_recipient_number = '$recipientNumber'";
    List<Map<String, Object>> result = await db.rawQuery(query);
    for (int i = 0; i < result.length; i++) {

      DateTime date = DateTime.fromMillisecondsSinceEpoch(result[i][col_message_timestamp]);
      String formattedDate = DateFormat('MMM d, y').format(date);

      var m = Message(
          isSelected: false,
          id: result[i][col_message_id],
          timestamp: result[i][col_message_timestamp],
          recipientNumber: result[i][col_message_recipient_number],
          recipientName: result[i][col_message_recipient_name],
          text: result[i][col_message_text],
          sender: result[i][col_message_sender],
          groupDate: formattedDate,
          backup: result[i][col_message_backup],
      );
      list.add(m);
    }
    return list;
  }

  Future<void> scheduleMessage(Message m) async {
    Map<String, dynamic> params = {
      col_message_id: m.id.toString(),
      col_message_text: m.text,
      col_message_timestamp: m.timestamp.toString(),
      col_message_groupdate: m.groupDate,
      col_message_recipient_number: m.recipientNumber,
      col_message_recipient_name: m.recipientName,
      col_message_sender: m.sender,
      col_message_backup: m.backup,
    };

    try{
      var uri = Uri.parse("${Constants.server_url}${Constants.api_url}/_schedule.php");
      var response = await http.post(uri, body: params);
      if(response.body == 'success'){
        return true;
      }
      else{
        showToast(response.body);
        return false;
      }
    }
    catch(e){
      print("dbHelper.scheduleMessage: ${e.toString()}");
      return false;
    }
  }

  Future<void> deleteSchedule(Message m) async {
    Map<String, dynamic> params = {
      col_message_id: m.id.toString(),
    };

    try{
      var uri = Uri.parse("${Constants.server_url}${Constants.api_url}/_deleteSchedule.php");
      var response = await http.post(uri, body: params);
      if(response.body == 'success'){
        return true;
      }
      else{
        showToast(response.body);
        return false;
      }
    }
    catch(e){
      print("dbHelper.deleteSchedule: ${e.toString()}");
      return false;
    }
  }

  Future<void> deleteMessage(Message m) async {
    if (m.timestamp > DateTime.now().millisecondsSinceEpoch) {
      await deleteSchedule(m);
    }
    String device_id = await getPhone();
    String hash = sha256.convert(utf8.encode(device_id)).toString();
    Database db = await database;
    await FirebaseDatabase.instance.ref().child(
        "backups/$hash/${m.timestamp.toString()}").remove();

    String query = "delete from $message_table where $col_message_id = ${m.id}";
    await db.execute(query);
  }

}