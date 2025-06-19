import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_service.dart';

class RestaurantService {
  static const String getAllRestaurantsQuery = '''
    query GetAllRestaurants(\$limit: Int) {
      getAllRestaurants(limit: \$limit) {
        restoranId
        nama
        alamat
        jenisMasakan
        rating
        jamBuka
        biayaAntar
        isActive
        urlGambar
        telepon
        deskripsi
        totalOrders
        averageRating
        owner {
          namaPengguna
        }
      }
    }
  ''';

  static const String getRestaurantsByTypeQuery = '''
    query GetRestaurantsByType(\$jenisMasakan: String!) {
      getRestaurantsByType(jenisMasakan: \$jenisMasakan) {
        restoranId
        nama
        alamat
        jenisMasakan
        rating
        jamBuka
        biayaAntar
        isActive
        urlGambar
        telepon
        deskripsi
        totalOrders
        averageRating
        owner {
          namaPengguna
        }
      }
    }
  ''';

  static const String getRestaurantByIdQuery = '''
    query GetRestaurantById(\$id: ID!) {
      getRestaurantById(id: \$id) {
        restoranId
        nama
        alamat
        jenisMasakan
        rating
        jamBuka
        biayaAntar
        isActive
        urlGambar
        telepon
        deskripsi
        totalOrders
        averageRating
        createdAt
        updatedAt
        menuItems {
          itemMenuId
          nama
          deskripsi
          harga
          urlGambar
          isAvailable
          kategori
          createdAt
          updatedAt
        }
      }
    }
  ''';

  static Future<List<Map<String, dynamic>>> getAllRestaurants({
    int? limit,
  }) async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.query(
        QueryOptions(
          document: gql(getAllRestaurantsQuery),
          variables: limit != null ? {'limit': limit} : {},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final restaurants = result.data!['getAllRestaurants'] as List;
      return restaurants.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to load restaurants: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getRestaurantsByType(
    String jenisMasakan,
  ) async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.query(
        QueryOptions(
          document: gql(getRestaurantsByTypeQuery),
          variables: {'jenisMasakan': jenisMasakan},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final restaurants = result.data!['getRestaurantsByType'] as List;
      return restaurants.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to load restaurants by type: $e');
    }
  }

  static Future<Map<String, dynamic>> getRestaurantDetails(
    String restoranId,
  ) async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.query(
        QueryOptions(
          document: gql(getRestaurantByIdQuery),
          variables: {'id': restoranId},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data!['getRestaurantById'];
    } catch (e) {
      throw Exception('Failed to load restaurant details: $e');
    }
  }
}
