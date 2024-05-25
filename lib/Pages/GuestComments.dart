import 'dart:io';
import 'package:cosmetics_project/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GuestComments extends StatefulWidget {
  const GuestComments({
    Key? key,
    required this.title,
    required this.postName,
    required this.username,
  });
  final String username;
  final String title;
  final String postName;
  @override
  State<GuestComments> createState() => CommentsState();
}

class CommentsState extends State<GuestComments> {
  List<Map<String, dynamic>> commentData = [];
  String experience = '';
  File? _image;
  int rating = 1;

  void initState() {
    super.initState();
    fetchcomments(); // Fetch posts when the page is initialized
  }

  Future<void> fetchcomments() async {
    try {
      final response = await http.get(Uri.parse(
          'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/Products/${widget.postName}/ProductComments.json'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Clear existing comment data
        commentData.clear();

        jsonData.forEach((key, value) {
          final Map<String, dynamic> comment = {
            'id': key,
            'Experience': value['Experience'],
            '_image': value['_image'],
            'Rating': value['Rating'],
            'UserName': value['UserName'],
          };

          commentData.add(comment);
        });

        setState(() {});
      } else {
        print('Failed to fetch COMMENTS: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching COMMENTS: $error');
    }
  }

  //
  Future<void> sendNotificationToUser() async {
    try {
      final response = await http.get(
          Uri.parse('https://your-firebase-project.firebaseio.com/users.json'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        jsonData.forEach((key, value) async {
          // Replace `postOwnerId` with the ID of the user who posted the commented post
          if (key == widget.postName) {
            final String fcmToken = value['fcmToken'];

            final message = {
              'notification': {
                'title': 'New Comment',
                'body': 'Someone commented on your post.',
              },
              'token': fcmToken,
            };

            final response = await http.post(
              Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'key=YOUR_SERVER_KEY',
              },
              body: json.encode(message),
            );

            if (response.statusCode == 200) {
              print('Notification sent successfully.');
            } else {
              print('Failed to send notification: ${response.statusCode}');
            }
          }
        });
      } else {
        print('Failed to fetch users: ${response.statusCode}');
      }
    } catch (error) {
      print('Error sending notification: $error');
    }
  }

//
  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
      }
    });
  }

  void _removeImage() {
    setState(() {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFEDE8E8),
        title: Text(widget.title),
      ),
      backgroundColor: Color(0xFFFFCCC1), // Set background color here

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: commentData.length,
              itemBuilder: (context, index) {
                final post = commentData[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(
                      color: Color.fromARGB(255, 153, 153, 153),
                      width: 1,
                    ),
                  ),
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text(
                          ' ${post['UserName']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Comment: ${post['Experience']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        if (post['_image'] != null && post['_image'] != '')
                          Container(
                            height: 200,
                            width: double.infinity,
                            child: Image.memory(
                              base64Decode(post['_image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Color.fromARGB(255, 218, 200, 46),
                              size: 22,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Rating: ${post['Rating']} out of 5',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
