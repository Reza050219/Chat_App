import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String receiverEmail;
  final String currentUserEmail;

  ChatScreen({required this.receiverEmail, required this.currentUserEmail});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();

  String getChatRoomId() {
    return widget.currentUserEmail.hashCode <= widget.receiverEmail.hashCode
        ? '${widget.currentUserEmail}_${widget.receiverEmail}'
        : '${widget.receiverEmail}_${widget.currentUserEmail}';
  }

  void sendMessage() {
    final message = messageController.text.trim();
    if (message.isEmpty) return;
    FirebaseFirestore.instance
        .collection('chats')
        .doc(getChatRoomId())
        .collection('messages')
        .add({
          'sender': widget.currentUserEmail,
          'text': message,
          'timestamp': FieldValue.serverTimestamp(),
        });
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomId = getChatRoomId();
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverEmail.split('@')[0])),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('chats')
                      .doc(chatRoomId)
                      .collection('messages')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                final messages = snapshot.data!.docs;
                return ListView(
                  children:
                      messages.map((doc) {
                        bool isMe = doc['sender'] == widget.currentUserEmail;
                        return Align(
                          alignment:
                              isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              doc['text'],
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(icon: Icon(Icons.send), onPressed: sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
