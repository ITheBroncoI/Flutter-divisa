import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class IncrementVotesMutation extends StatelessWidget {
  final String divisaId;
  final VoidCallback onCompleted;

  const IncrementVotesMutation({super.key, required this.divisaId, required this.onCompleted});

  @override
  Widget build(BuildContext context) {
    return Mutation(
      options: MutationOptions(
        document: gql(r'''
          mutation VoteMutation($divisaId: Int!) {
            createVote(divisaId: $divisaId) {
              divisa {
                id
                nombre
                pais
                acronimo
                precio
                votes {
                  id
                  user {
                    id
                  }
                }
              }
              user {
                id
              }
            }
          }
        '''),
        onCompleted: (dynamic resultData) {
          onCompleted();
        },
        onError: (error) {
          print("Error: $error");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("An error occurred")),
          );
        },
      ),
      builder: (RunMutation runMutation, QueryResult? result) {
        return IconButton(
          icon: Icon(Icons.thumb_up),
          onPressed: () {
            runMutation({'divisaId': int.parse(divisaId)});
          },
        );
      },
    );
  }
}


