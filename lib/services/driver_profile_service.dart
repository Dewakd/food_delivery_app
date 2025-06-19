import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_service.dart';

class DriverProfileService {
  static const String createDriverProfileMutation = '''
    mutation CreateDriverProfile(\$input: CreateDriverProfileInput!) {
      createDriverProfile(input: \$input) {
        pengemudiId
        namaPengemudi
        telepon
        detailKendaraan
        status
        lokasiSaatIni
        rating
        totalDeliveries
        isActive
        createdAt
      }
    }
  ''';

  static const String getMyDriverProfileQuery = '''
    query GetMyDriverProfile {
      getMyDriverProfile {
        pengemudiId
        namaPengemudi
        telepon
        detailKendaraan
        status
        lokasiSaatIni
        rating
        totalDeliveries
        isActive
      }
    }
  ''';

  static Future<Map<String, dynamic>?> createDriverProfile({
    required String namaPengemudi,
    required String telepon,
    required String detailKendaraan,
    required String lokasiSaatIni,
  }) async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.mutate(
        MutationOptions(
          document: gql(createDriverProfileMutation),
          variables: {
            'input': {
              'namaPengemudi': namaPengemudi,
              'telepon': telepon,
              'detailKendaraan': detailKendaraan,
              'lokasiSaatIni': lokasiSaatIni,
            },
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data!['createDriverProfile'];
    } catch (e) {
      throw Exception('Failed to create driver profile: $e');
    }
  }

  static Future<Map<String, dynamic>?> getMyDriverProfile() async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.query(
        QueryOptions(document: gql(getMyDriverProfileQuery)),
      );

      if (result.hasException) {
        // If no driver profile found, return null (this is expected for new drivers)
        if (result.exception.toString().contains('Driver profile not found') ||
            result.exception.toString().contains('No driver profile')) {
          return null;
        }
        throw Exception(result.exception.toString());
      }

      return result.data!['getMyDriverProfile'];
    } catch (e) {
      // If it's a "not found" error, return null instead of throwing
      if (e.toString().contains('Driver profile not found') ||
          e.toString().contains('No driver profile')) {
        return null;
      }
      throw Exception('Failed to load driver profile: $e');
    }
  }
}
