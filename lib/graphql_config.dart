import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GraphQLConfig {
  static final HttpLink httpLink = HttpLink(
    'http://34.82.114.135:8080/graphql-divisas/',
  );

  static final AuthLink authLink = AuthLink(
    getToken: () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        return 'JWT $token';
      }
      return '';
    },
  );

  static final Link link = authLink.concat(httpLink);

  static final ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
    ),
  );

  static GraphQLClient getClient() {
    return GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: link,
    );
  }
}



