import 'package:flutter/material.dart';

class SearchWidget extends StatefulWidget {

  bool isForward;
  Function callback;
  FocusNode focusNode;

  SearchWidget({
    this.isForward,
    this.callback,
    this.focusNode,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();

}

class _SearchWidgetState extends State<SearchWidget> with
    SingleTickerProviderStateMixin {

  Animation<double> animation;
  AnimationController animController;

  var search_controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: animation.value,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  bottomLeft: Radius.circular(50),
                )
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 2),
              child: TextField(
                autofocus: true,
                focusNode: widget.focusNode,
                controller: search_controller,
                onSubmitted: (value) {
                  widget.isForward = true;
                  widget.callback(value);
                },
                textInputAction: TextInputAction.search,
                cursorColor: Colors.black,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'sono-regular',
                  fontSize: 18,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: animation.value > 1 ? const BorderRadius.only(
                  topLeft: Radius.circular(0),
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(50),
                  topRight: Radius.circular(50),
                ) : BorderRadius.circular(50)
            ),
            child: IconButton(
              onPressed: () {
                if (!widget.isForward) {
                  animController.forward();
                  widget.isForward = true;
                }
                else {
                  animController.reverse();
                  widget.isForward = false;
                  search_controller.text = "";
                  widget.callback("");
                }
              },
              icon: widget.isForward ? const Icon(Icons.close) : const Icon(Icons.search),
              color: Colors.black,
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    final curvedAnimation = CurvedAnimation(parent: animController, curve: Curves.easeOutExpo);
    animation = Tween<double>(begin: 0, end: 150).animate(curvedAnimation)
    ..addListener(() {
      setState(() {

      });
    });
    widget.focusNode.requestFocus();
  }

}
