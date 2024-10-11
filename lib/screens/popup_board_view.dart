import 'package:flutter/material.dart';

class PopupBoardView extends StatefulWidget {
  const PopupBoardView({super.key});

  @override
  State<PopupBoardView> createState() => _PopupBoardViewState();
}

class _PopupBoardViewState extends State<PopupBoardView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF121212),
        title: const Text("팝업게시판"),
      ),
      body: Container(
        color: Color(0xFF121212),
        child: Center(
            child: Text('팝업게시판 화면', style: TextStyle(color: Colors.white))),
      ),
    );
  }
}
