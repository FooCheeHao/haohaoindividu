import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_detail.dart';

class HomePage extends StatefulWidget {
  final String name;

  HomePage({required this.name});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> users = [];
  List<dynamic> filteredUsers = [];
  bool isLoading = true;
  String selectedGender = 'all'; // Gender filter

  @override
  void initState() {
    super.initState();
    _fetchRandomUsers();
  }

  Future<void> _fetchRandomUsers() async {
    final response = await http.get(Uri.parse('https://randomuser.me/api/?results=20'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        users = data['results'];
        filteredUsers = users;
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch random users')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterByGender(String gender) {
    setState(() {
      if (gender == 'all') {
        filteredUsers = users;
      } else {
        filteredUsers = users.where((user) => user['gender'] == gender).toList();
      }
      selectedGender = gender;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome, ${widget.name}')),
      body: Column(
        children: [
          // Gender Filter Dropdown
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: selectedGender,
              items: [
                DropdownMenuItem(value: 'all', child: Text('All')),
                DropdownMenuItem(value: 'male', child: Text('Male')),
                DropdownMenuItem(value: 'female', child: Text('Female')),
              ],
              onChanged: (value) {
                if (value != null) _filterByGender(value);
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final userName = "${user['name']['first']} ${user['name']['last']}";
                      final userEmail = user['email'];
                      final userPicture = user['picture']['thumbnail'];
                      final gender = user['gender'];
                      final address = "${user['location']['street']['number']} ${user['location']['street']['name']}, ${user['location']['city']}, ${user['location']['country']}";

                      return ListTile(
                        leading: CircleAvatar(
                          child: Image.network(userPicture),
                        ),
                        title: Text(userName),
                        subtitle: Text(userEmail),
                        onTap: () {
                          // Navigate to UserDetail screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserDetail(
                                imageUrl: user['picture']['large'],
                                name: userName,
                                gender: gender,
                                address: address,
                                email: userEmail, // Passing email to UserDetail
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchRandomUsers,
        child: Icon(Icons.refresh),
      ),
    );
  }
}