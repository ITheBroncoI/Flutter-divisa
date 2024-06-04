import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SignupForm extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 10),
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
                  mutation SignupMutation(
                    $email: String!
                    $username: String!
                    $password: String!
                  ) {
                    createUser(
                      email: $email,
                      username: $username,
                      password: $password
                    ) {
                      user {
                        id
                        username
                        email
                      }
                    }
                  }
                '''),
                onCompleted: (dynamic resultData) async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("User created successfully!")),
                  );
                  Navigator.pushReplacementNamed(context, '/login');
                },
                onError: (error) {
                  print("Error: $error");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("An error occurred")),
                  );
                },
              ),
              builder: (RunMutation runMutation, QueryResult? result) {
                return ElevatedButton(
                  onPressed: () {
                    runMutation({
                      'email': emailController.text,
                      'username': usernameController.text,
                      'password': passwordController.text,
                    });
                  },
                  child: Text('Sign Up'),
                );
              },
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}

