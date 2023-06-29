import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? onTap;

  MyListTile({
    super.key, 
    required this.icon, 
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
      onTap: onTap,
      title: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
