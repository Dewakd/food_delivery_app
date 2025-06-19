import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_service.dart';

class RestaurantOwnerService {
  static const String createRestaurantMutation = '''
    mutation CreateRestaurant(\$input: CreateRestaurantInput!) {
      createRestaurant(input: \$input) {
        restoranId
        nama
        alamat
        jenisMasakan
        jamBuka
        biayaAntar
        isActive
        createdAt
        owner {
          penggunaId
          namaPengguna
          email
        }
      }
    }
  ''';

  static const String getMyRestaurantQuery = '''
    query GetMyRestaurant {
      getMyRestaurant {
        restoranId
        nama
        alamat
        jenisMasakan
        jamBuka
        biayaAntar
        isActive
        telepon
        deskripsi
        urlGambar
      }
    }
  ''';

  static Future<Map<String, dynamic>?> createRestaurant({
    required String nama,
    required String alamat,
    required String jenisMasakan,
    required String jamBuka,
    required double biayaAntar,
    required String telepon,
    String? deskripsi,
    String? urlGambar,
  }) async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.mutate(
        MutationOptions(
          document: gql(createRestaurantMutation),
          variables: {
            'input': {
              'nama': nama,
              'alamat': alamat,
              'jenisMasakan': jenisMasakan,
              'jamBuka': jamBuka,
              'biayaAntar': biayaAntar,
              'telepon': telepon,
              'deskripsi': deskripsi,
              'urlGambar':
                  urlGambar ??
                  'https://via.placeholder.com/300x200?text=Restaurant',
            },
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data!['createRestaurant'];
    } catch (e) {
      throw Exception('Failed to create restaurant: $e');
    }
  }

  static Future<Map<String, dynamic>?> getMyRestaurant() async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.query(
        QueryOptions(document: gql(getMyRestaurantQuery)),
      );

      if (result.hasException) {
        // If no restaurant found, return null (this is expected for new owners)
        if (result.exception.toString().contains('Restaurant not found') ||
            result.exception.toString().contains('No restaurant')) {
          return null;
        }
        throw Exception(result.exception.toString());
      }

      return result.data!['getMyRestaurant'];
    } catch (e) {
      // If it's a "not found" error, return null instead of throwing
      if (e.toString().contains('Restaurant not found') ||
          e.toString().contains('No restaurant')) {
        return null;
      }
      throw Exception('Failed to load restaurant: $e');
    }
  }
}
