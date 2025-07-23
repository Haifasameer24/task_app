import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/Notification.dart';

class NotificationBottomSheet extends StatelessWidget{
  final List<NotificationItem> notification;
  const NotificationBottomSheet({Key? key, required this.notification}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height: 350,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            "Notifications",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
          itemCount: notification.length,
          itemBuilder: (context,index){
            final notif=notification[index];
            return ListTile(
              leading: Icon(notif.icon,color: notif.iconColor,),
              title: Text(notif.title),
              subtitle: Text(notif.subtitle),
            );
    },
            ),
          ),
        ],
      ),
    );
  }
}