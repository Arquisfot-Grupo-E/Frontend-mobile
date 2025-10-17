// Script de prueba para ejecutar las mutaciones GraphQL usando HTTP
// Usage: dart run tool/test_graphql.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

const String graphqlUrl = 'http://10.0.2.2:4000/graphql';

Future<void> main() async {
  print('Starting GraphQL mutation tests...');

  // REGISTER
  final registerMutation = '''
mutation Register(
  {"email": "String!", "password":"String!", "firstName":"String!", "lastName":"String!", "description":"String"}
) {
  register(
    email: "test@example.com"
    password: "password123"
    firstName: "Test"
    lastName: "User"
    description: "Descripción desde test"
  ) {
    id
    email
    first_name
    last_name
  }
}
''';

  // Instead of constructing the full GraphQL text with variables, we'll send a simple request for register
  final body = jsonEncode({
    'query': '''
mutation Register(
  \$email: String!,
  \$password: String!,
  \$firstName: String!,
  \$lastName: String!,
  \$description: String
) {
  register(
    email: \$email,
    password: \$password,
    firstName: \$firstName,
    lastName: \$lastName,
    description: \$description
  ) {
    id
    email
    first_name
    last_name
  }
}
''',
    'variables': {
      'email': 'mobiletest@example.com',
      'password': 'password123',
      'firstName': 'Mobile',
      'lastName': 'Tester',
      'description': 'Descripción desde Dart test',
    }
  });

  final res = await http.post(Uri.parse(graphqlUrl), headers: {
    'Content-Type': 'application/json'
  }, body: body);

  print('REGISTER status: ${res.statusCode}');
  print(res.body);

  // LOGIN
  final loginBody = jsonEncode({
    'query': '''
mutation Login(\$email: String!, \$password: String!) {
  login(email: \$email, password: \$password) { access refresh }
}
''',
    'variables': {
      'email': 'mobiletest@example.com',
      'password': 'password123',
    }
  });

  final resLogin = await http.post(Uri.parse(graphqlUrl), headers: {
    'Content-Type': 'application/json'
  }, body: loginBody);

  print('LOGIN status: ${resLogin.statusCode}');
  print(resLogin.body);

  // If login returned tokens, attempt saveGenres and confirmPreferences
  try {
    final map = jsonDecode(resLogin.body);
    final tokens = map['data']?['login'];
    final access = tokens?['access'];
    if (access != null) {
      final saveBody = jsonEncode({
        'query': '''
mutation SaveGenres(\$genres: [String!]!) {
  saveGenres(genres: \$genres) { user_id saved_genres }
}
''',
        'variables': {
          'genres': ['Fantasía', 'Ciencia ficción', 'Misterio']
        }
      });

      final resSave = await http.post(Uri.parse(graphqlUrl), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $access'
      }, body: saveBody);

      print('SAVE_GENRES status: ${resSave.statusCode}');
      print(resSave.body);

      final confirmBody = jsonEncode({
        'query': '''
mutation ConfirmPreferences { confirmPreferences { detail } }
'''
      });

      final resConfirm = await http.post(Uri.parse(graphqlUrl), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $access'
      }, body: confirmBody);

      print('CONFIRM_PREFERENCES status: ${resConfirm.statusCode}');
      print(resConfirm.body);
    } else {
      print('No access token returned; skipping saveGenres/confirmPreferences');
    }
  } catch (e) {
    print('Error parsing login response: $e');
  }

  print('Done');
}
