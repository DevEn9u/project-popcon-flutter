import 'package:flutter/material.dart';
import 'package:project_popcon_flutter/widgets/custom_drawer.dart';

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
        // Drawer 아이콘의 색상 변경
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF121212),
        title: Image.asset(
          'assets/images/logo.png',
          height: 30,
        ),
      ),
      endDrawer: const CustomDrawer(),
      body: Container(
        color: Color(0xFF121212),
        child: Center(
            child: Text('팝업게시판 화면', style: TextStyle(color: Colors.white))),
      ),
    );
  }
}
