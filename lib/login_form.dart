import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            Mutation(
              options: MutationOptions(
                document: gql(r'''
                  mutation LoginMutation(
                    $username: String!,
                    $password: String!
                  ) {
                    tokenAuth(username: $username, password: $password) {
                      token
                    }
                  }
                '''),
                onCompleted: (dynamic resultData) async {
                  final token = resultData['tokenAuth'] != null ? resultData['tokenAuth']['token'] : null;
                  if (token != null) {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setString('auth_token', token);
                    print('Token saved: $token');
                    Navigator.pushReplacementNamed(context, '/home');
                  } else {
                    _showSnackBar(context, "Invalid credentials");
                  }
                },
                onError: (error) {
                  print("Error: $error");
                  _showSnackBar(context, "An error occurred");
                },
              ),
              builder: (RunMutation runMutation, QueryResult? result) {
                return ElevatedButton(
                  onPressed: () {
                    runMutation({
                      'username': usernameController.text,
                      'password': passwordController.text,
                    });
                  },
                  child: Text('Login'),
                );
              },
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/signup');
                _showSnackBar(context, "Cuenta creada con éxito");
              },
              child: Text('No tienes una cuenta? Creala!'),
            ),
          ],
        ),
      ),
    );
  }
}


