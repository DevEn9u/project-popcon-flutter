import 'package:flutter/material.dart';
import 'package:project_popcon_flutter/screens/free_board_list.dart';
import 'package:project_popcon_flutter/screens/popup_board_list.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        width: 500, // 드로어의 너비를 설정
        child: Container(
          color: const Color(0xFF121212),
          child: ListView(
            children: [
              Container(
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 30,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white),
              ListTile(
                leading: const Icon(
                  Icons.home,
                  color: Colors.white,
                ),
                title: const Text(
                  '홈',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.my_library_books,
                  color: Colors.white,
                ),
                title:
                    const Text('팝업게시판', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context); // 드로어 닫기
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PopupBoardList()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.my_library_books,
                  color: Colors.white,
                ),
                title:
                    const Text('자유게시판', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context); // 드로어 닫기
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FreeBoardList()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
