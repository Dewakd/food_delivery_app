import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_service.dart';

class DriverService {
  static const String getAvailableOrdersQuery = '''
    query GetAvailableOrders(\$limit: Int) {
      getAvailableOrders(limit: \$limit) {
        pesananId
        tanggalPesanan
        jumlahTotal
        alamatAntar
        totalBiaya
        restoran {
          nama
          alamat
          telepon
        }
        pengguna {
          namaPengguna
          telepon
        }
      }
    }
  ''';

  static const String getMyDeliveriesQuery = '''
    query GetMyDeliveries(\$limit: Int) {
      getMyDeliveries(limit: \$limit) {
        pesananId
        tanggalPesanan
        jumlahTotal
        status
        alamatAntar
        totalBiaya
        restoran {
          nama
          alamat
          telepon
        }
        pengguna {
          namaPengguna
          telepon
          alamat
        }
      }
    }
  ''';

  static const String acceptDeliveryMutation = '''
    mutation AcceptDelivery(\$orderId: ID!) {
      acceptDelivery(orderId: \$orderId) {
        pesananId
        status
        pengemudi {
          namaPengemudi
          status
        }
      }
    }
  ''';

  static const String completeDeliveryMutation = '''
    mutation CompleteDelivery(\$orderId: ID!) {
      completeDelivery(orderId: \$orderId) {
        pesananId
        status
      }
    }
  ''';

  static const String goOnlineMutation = '''
    mutation GoOnline {
      goOnline {
        pengemudiId
        status
      }
    }
  ''';

  static const String goOfflineMutation = '''
    mutation GoOffline {
      goOffline {
        pengemudiId
        status
      }
    }
  ''';

  static const String updateLocationMutation = '''
    mutation UpdateDriverLocation(\$latitude: Float!, \$longitude: Float!) {
      updateDriverLocation(latitude: \$latitude, longitude: \$longitude) {
        pengemudiId
        latitudeTerkini
        longitudeTerkini
      }
    }
  ''';

  static Future<List<dynamic>> getAvailableOrders({int? limit}) async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.query(
        QueryOptions(
          document: gql(getAvailableOrdersQuery),
          variables: {'limit': limit},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data!['getAvailableOrders'] ?? [];
    } catch (e) {
      throw Exception('Failed to load available orders: $e');
    }
  }

  static Future<List<dynamic>> getMyDeliveries({int? limit}) async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.query(
        QueryOptions(
          document: gql(getMyDeliveriesQuery),
          variables: {'limit': limit},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data!['getMyDeliveries'] ?? [];
    } catch (e) {
      throw Exception('Failed to load my deliveries: $e');
    }
  }

  static Future<Map<String, dynamic>?> acceptDelivery(String orderId) async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.mutate(
        MutationOptions(
          document: gql(acceptDeliveryMutation),
          variables: {'orderId': orderId},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data!['acceptDelivery'];
    } catch (e) {
      throw Exception('Failed to accept delivery: $e');
    }
  }

  static Future<Map<String, dynamic>?> completeDelivery(String orderId) async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.mutate(
        MutationOptions(
          document: gql(completeDeliveryMutation),
          variables: {'orderId': orderId},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data!['completeDelivery'];
    } catch (e) {
      throw Exception('Failed to complete delivery: $e');
    }
  }

  static Future<Map<String, dynamic>?> goOnline() async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.mutate(
        MutationOptions(document: gql(goOnlineMutation)),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data!['goOnline'];
    } catch (e) {
      throw Exception('Failed to go online: $e');
    }
  }

  static Future<Map<String, dynamic>?> goOffline() async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.mutate(
        MutationOptions(document: gql(goOfflineMutation)),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data!['goOffline'];
    } catch (e) {
      throw Exception('Failed to go offline: $e');
    }
  }

  static Future<Map<String, dynamic>?> updateLocation(
    double latitude,
    double longitude,
  ) async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.mutate(
        MutationOptions(
          document: gql(updateLocationMutation),
          variables: {'latitude': latitude, 'longitude': longitude},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data!['updateDriverLocation'];
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
  }
}
