import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  runApp(LoginApp());
}


class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foo Chee Hao 2350079_Login Demo',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(name: userCredential.user?.email ?? ''),
        ),
      );
    } catch (e) {
      // Handle errors, e.g., show a snackbar or dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Foo Chee Hao 2350079_Login Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

//randomuser api
class HomePage extends StatefulWidget {
  final String name;

  HomePage({required this.name});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> users = [];
  bool isLoading = true;

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
        isLoading = false;
      });
    } else {
      // Handle the error, e.g., show a snackbar or dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch random users')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome, ${widget.name}')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final userName = "${user['name']['first']} ${user['name']['last']}";
                final userEmail = user['email'];
                final userPicture = user['picture']['thumbnail'];

                return ListTile(
                  leading: CircleAvatar(
                    child: Image.network(userPicture),
                  ),
                  title: Text(userName),
                  subtitle: Text(userEmail),
                );
              },
            ),
            floatingActionButton: FloatingActionButton(onPressed:_fetchRandomUsers,
          ),
    );
  }
}