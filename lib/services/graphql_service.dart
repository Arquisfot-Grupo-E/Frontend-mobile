import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  // HTTPS con certificado autofirmado
  static const String _url = 'https://10.0.2.2:8443/graphql'; // Para emulador Android
  // Para dispositivo físico usa: 'https://192.168.x.x:8443/graphql'

  static ValueNotifier<GraphQLClient> client(String? token) {
    // ⚠️ SOLO PARA DESARROLLO: Permitir certificados autofirmados
    HttpOverrides.global = _DevHttpOverrides();

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
      $description: String
    ) {
      register(
        email: $email
        password: $password
        firstName: $firstName
        lastName: $lastName
        description: $description
      ) {
        id
        email
        first_name
        last_name
      }
    }
  ''';

  static const String saveGenresMutation = r'''
    mutation SaveGenres($genres: [String!]!) {
      saveGenres(genres: $genres) {
        user_id
        saved_genres
      }
    }
  ''';

  static const String confirmPreferencesMutation = r'''
    mutation ConfirmPreferences {
      confirmPreferences {
        detail
      }
    }
  ''';
}

// ⚠️ SOLO PARA DESARROLLO: Clase para permitir certificados autofirmados
class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // En producción, NUNCA retornar true aquí
        // Esto acepta CUALQUIER certificado, incluso inválidos
        if (kDebugMode) {
          print('⚠️ WARNING: Accepting self-signed certificate for $host:$port');
        }
        return true; // Aceptar certificados autofirmados
      };
  }
}