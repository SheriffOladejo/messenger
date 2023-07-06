import 'package:messenger/utils/db_helper.dart';
import 'package:messenger/utils/hex_color.dart';
import 'package:messenger/utils/methods.dart';
import 'package:messenger/views/bottom_nav.dart';
import 'package:messenger/views/get_started.dart';
import 'package:messenger/views/home.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {

  const SplashScreen({Key key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen> {

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor("#9D6FB0"),
        elevation: 0,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: HexColor("#9D6FB0"),
        child: Center(
          child: Image.asset("assets/images/splash_logo.png"),
        ),
      ),
    );
  }

  Future<void> init() async {
    setState(() {
      isLoading = true;
    });
    var db = DbHelper();
    String phone = await db.getPhone();
    if (phone.isNotEmpty) {
      Navigator.of(context).pushReplacement(slideLeft(const BottomNav()));
    }
    else {
      Navigator.of(context).pushReplacement(slideLeft(const GetStartedScreen()));
    }
    setState(() {
      isLoading = false;
    });
  }


  @override
  void initState() {
    super.initState();
    init();
  }

}
