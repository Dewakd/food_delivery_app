import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GraphQLService {
  static GraphQLClient? _client;

  static Future<GraphQLClient> getClient() async {
    if (_client == null) {
      final HttpLink httpLink = HttpLink('http://10.0.2.2:4000/graphql');

      final AuthLink authLink = AuthLink(
        getToken: () async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          return token != null ? 'Bearer $token' : null;
        },
      );

      final Link link = authLink.concat(httpLink);

      _client = GraphQLClient(
        link: link,
        cache: GraphQLCache(store: InMemoryStore()),
      );
    }

    return _client!;
  }

  static void resetClient() {
    _client = null;
  }
}
