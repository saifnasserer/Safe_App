import 'package:flutter/material.dart';
import 'package:safe/Constants.dart';

class ManageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ManageAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: Constants.getPrimaryColor(context),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'معاملة جديدة',
        style: TextStyle(
          color: Constants.getPrimaryColor(context),
          fontFamily: Constants.defaultFontFamily,
          fontSize: Constants.responsiveFontSize(context, 24),
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
