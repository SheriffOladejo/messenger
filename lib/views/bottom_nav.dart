import 'package:messenger/views/backup.dart';
import 'package:messenger/views/home.dart';
import 'package:messenger/views/new_message.dart';
import 'package:messenger/views/schedule_message.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:messenger/utils/hex_color.dart';

class BottomNav extends StatefulWidget {

  const BottomNav({Key key}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();

}

class _BottomNavState extends State<BottomNav> {

  PersistentTabController _controller;

  List<Widget> _buildScreens() {
    return [
      HomeScreen(),
      NewMessage(),
      ScheduleMessage(),
      Backup(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: false, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      stateManagement: true,
      hideNavigationBarWhenKeyboardShows: true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: ItemAnimationProperties(
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: ScreenTransitionAnimation(
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle: NavBarStyle.style1,
    );
  }

  Future<void> init () async {
    _controller = PersistentTabController(initialIndex: 0);
    setState(() {

    });
  }

  @override
  void initState () {
    super.initState();
    init();
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        textStyle: TextStyle(
          fontSize: 16,
          fontFamily: 'inter-medium',
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        icon: ImageIcon(
          AssetImage("assets/images/nav_home.png"),
        ),
        title: ("Home"),
        activeColorPrimary: HexColor("#9D6FB0"),
        inactiveColorPrimary: HexColor("#AAAAAA"),
      ),
      PersistentBottomNavBarItem(
        textStyle: TextStyle(
          fontSize: 16,
          fontFamily: 'inter-medium',
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        icon: ImageIcon(
          AssetImage("assets/images/nav_message.png"),
        ),
        title: ("Send SMS"),
        activeColorPrimary: HexColor("#9D6FB0"),
        inactiveColorPrimary: HexColor("#AAAAAA"),
      ),
      PersistentBottomNavBarItem(
        textStyle: TextStyle(
          fontSize: 16,
          fontFamily: 'inter-medium',
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        icon: ImageIcon(
          AssetImage("assets/images/nav_schedule.png"),
        ),
        title: ("Schedule"),
        activeColorPrimary: HexColor("#9D6FB0"),
        inactiveColorPrimary: HexColor("#AAAAAA"),
      ),
      PersistentBottomNavBarItem(
        textStyle: TextStyle(
          fontSize: 16,
          fontFamily: 'inter-medium',
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        icon: ImageIcon(
          AssetImage("assets/images/nav_backup.png"),
        ),
        title: ("Backup"),
        activeColorPrimary: HexColor("#9D6FB0"),
        inactiveColorPrimary: HexColor("#AAAAAA"),
      ),
    ];
  }

}
