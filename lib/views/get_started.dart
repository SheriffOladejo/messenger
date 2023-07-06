import 'package:messenger/utils/db_helper.dart';
import 'package:messenger/utils/hex_color.dart';
import 'package:messenger/utils/methods.dart';
import 'package:messenger/views/bottom_nav.dart';
import 'package:messenger/views/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({Key key}) : super(key: key);

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();

}

class _GetStartedScreenState extends State<GetStartedScreen> {

  bool isLoading = false;

  showAlertDialog(BuildContext context) {

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Phone number verification"),
      content: PhoneDialog(),
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading ? loadingPage() : SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          margin: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/images/amico.png",width: 360, height: 360,),
              Container(height: 15,),
              const Text("Effortlessly manage your messages", style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'inter-bold',
                  fontSize: 24,
              ),),
              Container(height: 15,),
              const Text("Send, backup and schedule SMS messages in easy steps", style: TextStyle(
                color: Colors.black,
                fontFamily: 'inter-regular',
                fontSize: 16,
              ),),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        width: MediaQuery.of(context).size.width,
        height: 70,
        margin: const EdgeInsets.only(bottom: 15, right: 50, left: 50),
        alignment: Alignment.center,
        child: ElevatedButton(
          onPressed: () {
            showAlertDialog(context);
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: HexColor("#9D6FB0"),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          ),
          child:
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "Get started",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: 'inter-bold'
                ),
              ),
            ],
          ),
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

class PhoneDialog extends StatefulWidget {

  @override
  State<PhoneDialog> createState() => _PhoneDialogState();

}

class _PhoneDialogState extends State<PhoneDialog> {

  String phoneNumber = "";

  var focusNode = FocusNode();

  bool showInputCode = false;
  String verificationId;
  int forceResendingToken;

  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return isLoading ? loadingPage() : Container(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 45,
              alignment: Alignment.center,
              child: TextFormField(
                focusNode: focusNode,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  else if (value.substring(0, 1) != "+" && !showInputCode) {
                    return 'Please enter country code';
                  }
                  return null;
                },
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
                textAlignVertical: TextAlignVertical.bottom,
                decoration: InputDecoration(
                    labelText: showInputCode ? 'Verification code' : 'Phone Number',
                    hintText: showInputCode ? 'Enter the code sent to you' : 'Enter your phone number',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    )
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: showInputCode ? _verifyCode : _submitPhoneNumber,
              child: Text(showInputCode ? 'Verify code' : 'Send Verification Code'),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _submitPhoneNumber() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      phoneNumber = _phoneNumberController.text.trim();

      try {
        await verifyPhoneNumber(
          phoneNumber,
              (credential) async {
            setState(() {
              isLoading = false;
            });
                await signInWithCredential(credential);
          },
              (message) {
            showToast("Verification failed: $message");
            print("Verification failed: $message");
            Navigator.pop(context);
          },
              (verificationId, forceResendingToken) {
            showToast("A verification code has been sent to you");
            setState(() {
              focusNode.requestFocus();
              _phoneNumberController.text = "";
              showInputCode = true;
              this.verificationId = verificationId;
              this.forceResendingToken = forceResendingToken;
              isLoading = false;
            });
          },
              (verificationId) {
                //showToast("Verification timeout, try again");
                //Navigator.pop(context);
          },
        );
      } catch (e) {
        showToast("An error occurred");
        Navigator.pop(context);
      }
    }
  }

  void _verifyCode() async {
    setState(() {
      isLoading = true;
    });

    if (_formKey.currentState.validate()) {
      try {
        AuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: _phoneNumberController.text.trim());
        await signInWithCredential(credential);
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        showToast('Invalid verification code. Please try again.');
        Navigator.pop(context);
      }
    }
  }

  Future<void> signInWithCredential(AuthCredential credential) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      var db = DbHelper();
      await db.savePhoneNumber(phoneNumber);
      Navigator.of(context).pushReplacement(slideLeft(const BottomNav()));
    } catch (e) {
      showToast("An error occurred");
      Navigator.pop(context);
    }
  }

  Future<void> verifyPhoneNumber(
      String phoneNumber, Function(AuthCredential) verificationCompleted,
      Function(String) verificationFailed, Function(String, int) codeSent, Function(String) codeAutoRetrievalTimeout) async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    void _verificationCompleted(AuthCredential credential) {
      verificationCompleted(credential);
    }

    void _verificationFailed(FirebaseAuthException authException) {
      verificationFailed(authException.message ?? 'Verification failed');
    }

    void _codeSent(String verificationId, int forceResendingToken) {
      codeSent(verificationId, forceResendingToken);
    }

    void _codeAutoRetrievalTimeout(String verificationId) {
      codeAutoRetrievalTimeout(verificationId);
    }

    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: _verificationCompleted,
      verificationFailed: _verificationFailed,
      codeSent: _codeSent,
      codeAutoRetrievalTimeout: _codeAutoRetrievalTimeout,
    );
  }


}

