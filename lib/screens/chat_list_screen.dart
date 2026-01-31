import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Firebase Chat App")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          final users =
              snapshot.data!.docs
                  .where((doc) => doc['email'] != user.email)
                  .toList();
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (_, i) {
              final otherUser = users[i]['email'];
              return ListTile(
                leading: CircleAvatar(child: Text((i + 1).toString())),
                title: Text("Chat ${i + 1}"),
                subtitle: Text("Last message"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ChatScreen(
                            receiverEmail: otherUser,
                            currentUserEmail: user.email!,
                          ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
