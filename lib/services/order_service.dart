import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_service.dart';

class OrderService {
  static const String createOrderMutation = '''
    mutation CreateOrder(\$input: CreateOrderInput!) {
      createOrder(input: \$input) {
        pesananId
        tanggalPesanan
        jumlahTotal
        status
        alamatAntar
        metodePembayaran
        totalBiaya
        restoran {
          nama
          alamat
        }
      }
    }
  ''';

  static const String getMyOrdersQuery = '''
    query GetMyOrders {
      getMyOrders(limit: 10) {
        pesananId
        tanggalPesanan
        jumlahTotal
        status
        alamatAntar
        metodePembayaran
        estimasiWaktu
        totalBiaya
        penggunaId
        restoranId
        pengemudiId
        restoran {
          nama
          alamat
        }
        pengemudi {
          namaPengemudi
          telepon
        }
        totalItems
      }
    }
  ''';

  static Future<Map<String, dynamic>?> createOrder({
    required String restoranId,
    required List<Map<String, dynamic>> items,
    required String alamatAntar,
    required String metodePembayaran,
    String? catatan,
  }) async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.mutate(
        MutationOptions(
          document: gql(createOrderMutation),
          variables: {
            'input': {
              'restoranId': restoranId,
              'items': items,
              'alamatAntar': alamatAntar,
              'metodePembayaran': metodePembayaran,
              'catatan': catatan,
            },
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data!['createOrder'];
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  static Future<List<dynamic>> getMyOrders() async {
    try {
      final client = await GraphQLService.getClient();

      final result = await client.query(
        QueryOptions(document: gql(getMyOrdersQuery)),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data!['getMyOrders'] ?? [];
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }
}
