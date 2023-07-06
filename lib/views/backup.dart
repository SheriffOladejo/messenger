import 'package:messenger/adapters/backup_message_adapter.dart';
import 'package:messenger/models/message.dart';
import 'package:messenger/utils/db_helper.dart';
import 'package:messenger/utils/hex_color.dart';
import 'package:messenger/utils/methods.dart';
import 'package:messenger/views/home.dart';
import 'package:flutter/material.dart';

class Backup extends StatefulWidget {

  Function callback;
  Backup({this.callback});

  @override
  State<Backup> createState() => _BackupState();
}

class _BackupState extends State<Backup> {

  var db_helper = DbHelper();

  bool is_loading = false;

  List<Message> list = [];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
          actions: [
            GestureDetector(
              onTap: () async {
                showToast("Restoring messages");
                setState(() {
                  is_loading = true;
                });
                await db_helper.restore();
                setState(() {
                  is_loading = false;
                });
                showToast("Messages restored");
              },
              child: const Icon(Icons.download_for_offline, color: Colors.white,),
            ),
            Container(width: 10,),
          ],
          backgroundColor: HexColor("#9D6FB0"),
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Text(
                  "Backup",
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'inter-bold',
                      fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FirstTab(list: list,),
          ],
        ),
      ),
    );
  }

}

class FirstTab extends StatefulWidget {

  List<Message> list;
  FirstTab({this.list});

  @override
  State<FirstTab> createState() => _FirstTabState();

}

class _FirstTabState extends State<FirstTab> {

  bool selectAll = false;

  bool is_loading = false;

  var db_helper = DbHelper();

  List<Message> messages = [];

  @override
  Widget build(BuildContext context) {
    return is_loading ? loadingPage() : Column(
      children: [
        CheckboxListTile(
          title: const Text("Select all", style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontFamily: 'inter-bold',
          ),),
          value: selectAll,
          onChanged: (newValue) {
            if (newValue) {
              for (var i = 0; i < messages.length; i++) {
                messages[i].isSelected = true;
                widget.list.add(messages[i]);
              }
            }
            else {
              for (var i = 0; i < messages.length; i++) {
                messages[i].isSelected = false;
                widget.list.remove(messages[i]);
              }
            }
            setState(() {
              selectAll = !selectAll;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
        ),
        Container(height: 10,),
        SizedBox(
          height: MediaQuery.of(context).size.height - 380,
          child: ListView.separated(
            separatorBuilder: (context, index) {
              return const Divider();
            },
            controller: ScrollController(),
            itemCount: messages.length,
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index){
              return BackupMessageAdapter(
                message: messages[index],
                list: widget.list,
              );
            },
          ),
        ),
        MaterialButton(
          onPressed: () async {
            if (widget.list.isNotEmpty) {
              showToast("Backing up messages");
              setState(() {
                is_loading = true;
              });
              await db_helper.backup(widget.list);
              setState(() {
                is_loading = false;
              });
              showToast("Messages backed up");
            }
          },
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          padding: const EdgeInsets.fromLTRB(70, 10, 70, 10),
          color: HexColor("#9D6FB0"),
          child:
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Backup",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: 'inter-bold'
                ),
              ),
              Container(width: 10,),
              Image.asset("assets/images/backup_.png", width: 20, height: 20, color: Colors.white,),
            ],
          ),
        )
      ],
    );
  }

  Future<void> init() async {
    setState(() {
      is_loading = true;
    });
    messages = await db_helper.getUnBackedUpMessages();
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

class SecondTab extends StatefulWidget {

  const SecondTab({Key key}) : super(key: key);

  @override
  State<SecondTab> createState() => _SecondTabState();

}

class _SecondTabState extends State<SecondTab> {

  bool selectAll = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text("Select all", style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontFamily: 'inter-bold',
          ),),
          value: selectAll,
          onChanged: (newValue) {
            setState(() {
              selectAll = !selectAll;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
        ),
        Container(height: 10,),
        SizedBox(
          height: MediaQuery.of(context).size.height - 260,
          child: ListView.separated(
            separatorBuilder: (context, index) {
              return const Divider();
            },
            controller: ScrollController(),
            itemCount: 7,
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index){
              return BackupMessageAdapter();
            },
          ),
        ),
        MaterialButton(
          onPressed: () {

          },
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          padding: const EdgeInsets.fromLTRB(70, 10, 70, 10),
          color: HexColor("#4897FA"),
          child:
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Restore",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: 'inter-bold'
                ),
              ),
              Container(width: 10,),
              Image.asset("assets/images/restore.png", width: 20, height: 20, color: Colors.white,),
            ],
          ),
        )
      ],
    );
  }

}



