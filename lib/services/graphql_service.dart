import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  static const String _url = 'http://10.0.2.2:4000/graphql'; // Para emulador Android
  // Para dispositivo físico usa tu IP local: 'http://192.168.x.x:4000/graphql'

  static ValueNotifier<GraphQLClient> client(String? token) {
    final HttpLink httpLink = HttpLink(_url);

    final AuthLink authLink = AuthLink(
      getToken: () => token != null ? 'Bearer $token' : null,
    );

    final Link link = authLink.concat(httpLink);

    return ValueNotifier(
      GraphQLClient(
        link: link,
        cache: GraphQLCache(store: HiveStore()),
      ),
    );
  }

  // Queries
  static const String searchBooksQuery = r'''
    query SearchBooks($query: String!) {
      searchBooks(query: $query) {
        id
        title
        authors
        description
        thumbnail
        categories
      }
    }
  ''';

  static const String reviewsForBookQuery = r'''
    query ReviewsForBook($bookId: String!) {
      reviewsForBook(bookId: $bookId) {
        id
        user_id
        content
        rating
        karma_score
        created_at
      }
    }
  ''';

  // Mutations
  static const String loginMutation = r'''
    mutation Login($email: String!, $password: String!) {
      login(email: $email, password: $password) {
        access
        refresh
      }
    }
  ''';

  static const String registerMutation = r'''
    mutation Register(
      $email: String!
      $password: String!
      $firstName: String!
      $lastName: String!
    ) {
      register(
        email: $email
        password: $password
        firstName: $firstName
        lastName: $lastName
      ) {
        id
        email
        first_name
        last_name
      }
    }
  ''';
}
