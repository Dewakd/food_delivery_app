import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_service.dart';

class CartService {
  // Get or create cart for restaurant (auto-deletes other restaurant carts)
  static const String createOrGetCartMutation = '''
    mutation CreateOrGetCart(\$restaurantId: ID!, \$address: String, \$paymentMethod: String, \$notes: String) {
      createOrGetCart(input: {
        restoranId: \$restaurantId
        alamatAntar: \$address
        metodePembayaran: \$paymentMethod
        catatanPesanan: \$notes
      }) {
        cartId
        penggunaId
        restoranId
        alamatAntar
        metodePembayaran
        catatanPesanan
        createdAt
        updatedAt
        restoran {
          restoranId
          nama
          alamat
          biayaAntar
        }
        itemCount
        subtotal
        deliveryFee
        serviceFee
        totalAmount
      }
    }
  ''';

  // Add item to cart (creates cart if doesn't exist, auto-handles restaurant switching)
  static const String addToCartMutation = '''
    mutation AddToCart(\$restaurantId: ID!, \$menuItemId: ID!, \$quantity: Int!, \$instructions: String) {
      addToCart(input: {
        restoranId: \$restaurantId
        itemMenuId: \$menuItemId
        quantity: \$quantity
        instruksiKhusus: \$instructions
      }) {
        cartItemId
        cartId
        itemMenuId
        quantity
        instruksiKhusus
        createdAt
        updatedAt
        menuItem {
          itemMenuId
          nama
          deskripsi
          harga
          urlGambar
          isAvailable
        }
        unitPrice
        totalPrice
        cart {
          cartId
          itemCount
          subtotal
          totalAmount
          restoran {
            restoranId
            nama
            alamat
            biayaAntar
          }
        }
      }
    }
  ''';

  // Update cart item quantity
  static const String updateCartItemMutation = '''
    mutation UpdateCartItem(\$cartItemId: ID!, \$quantity: Int, \$instructions: String) {
      updateCartItem(cartItemId: \$cartItemId, input: {
        quantity: \$quantity
        instruksiKhusus: \$instructions
      }) {
        cartItemId
        quantity
        instruksiKhusus
        updatedAt
        unitPrice
        totalPrice
        cart {
          cartId
          itemCount
          subtotal
          totalAmount
        }
      }
    }
  ''';

  // Remove item from cart
  static const String removeFromCartMutation = '''
    mutation RemoveFromCart(\$cartItemId: ID!) {
      removeFromCart(cartItemId: \$cartItemId)
    }
  ''';

  // Get user's cart (with full details)
  static const String getMyCartQuery = '''
    query GetMyCart(\$restaurantId: ID) {
      getMyCart(restoranId: \$restaurantId) {
        cartId
        penggunaId
        restoranId
        alamatAntar
        metodePembayaran
        catatanPesanan
        createdAt
        updatedAt
                  restoran {
            restoranId
            nama
            alamat
            urlGambar
            biayaAntar
            jamBuka
          }
        items {
          cartItemId
          itemMenuId
          quantity
          instruksiKhusus
          createdAt
          updatedAt
          menuItem {
            itemMenuId
            nama
            deskripsi
            harga
            kategori
            urlGambar
            isAvailable
          }
          unitPrice
          totalPrice
        }
        itemCount
        subtotal
        deliveryFee
        serviceFee
        totalAmount
      }
    }
  ''';

  // Get all user's carts
  static const String getAllMyCartsQuery = '''
    query GetAllMyCarts {
      getMyCarts {
        cartId
        restoranId
        alamatAntar
        metodePembayaran
        createdAt
        updatedAt
        restoran {
          restoranId
          nama
          alamat
          urlGambar
        }
        items {
          cartItemId
          quantity
          menuItem {
            itemMenuId
            nama
            harga
            urlGambar
          }
          totalPrice
        }
        itemCount
        subtotal
        totalAmount
      }
    }
  ''';

  // Update cart info (address, payment, notes)
  static const String updateCartMutation = '''
    mutation UpdateCart(\$cartId: ID!, \$address: String, \$paymentMethod: String, \$notes: String) {
      updateCart(cartId: \$cartId, input: {
        alamatAntar: \$address
        metodePembayaran: \$paymentMethod
        catatanPesanan: \$notes
      }) {
        cartId
        alamatAntar
        metodePembayaran
        catatanPesanan
        updatedAt
        itemCount
        totalAmount
      }
    }
  ''';

  // Clear cart
  static const String clearCartMutation = '''
    mutation ClearCart(\$cartId: ID!) {
      clearCart(cartId: \$cartId)
    }
  ''';

  // Checkout cart (converts to order)
  static const String checkoutCartMutation = '''
    mutation CheckoutCart(\$cartId: ID!) {
      checkoutCart(cartId: \$cartId) {
        pesananId
        status
        alamatAntar
        metodePembayaran
        catatanPesanan
        jumlahTotal
        biayaOngkir
        biayaLayanan
        totalBiaya
        createdAt
        restoran {
          nama
          alamat
          noTelepon
        }
        items {
          itemPesananId
          quantity
          instruksiKhusus
          hargaSatuan
          totalHarga
          menuItem {
            nama
            deskripsi
            urlGambar
          }
        }
      }
    }
  ''';

  // Get or create cart for restaurant
  static Future<Map<String, dynamic>?> createOrGetCart({
    required String restaurantId,
    String? address,
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.mutate(
        MutationOptions(
          document: gql(createOrGetCartMutation),
          variables: {
            'restaurantId': restaurantId,
            'address': address,
            'paymentMethod': paymentMethod,
            'notes': notes,
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data!['createOrGetCart'];
    } catch (e) {
      throw Exception('Failed to create or get cart: $e');
    }
  }

  // Add item to cart (auto-handles restaurant switching)
  static Future<Map<String, dynamic>?> addToCart({
    required String restaurantId,
    required String menuItemId,
    required int quantity,
    String? instructions,
  }) async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.mutate(
        MutationOptions(
          document: gql(addToCartMutation),
          variables: {
            'restaurantId': restaurantId,
            'menuItemId': menuItemId,
            'quantity': quantity,
            'instructions': instructions,
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data!['addToCart'];
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  // Update cart item
  static Future<Map<String, dynamic>?> updateCartItem({
    required String cartItemId,
    int? quantity,
    String? instructions,
  }) async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.mutate(
        MutationOptions(
          document: gql(updateCartItemMutation),
          variables: {
            'cartItemId':
                cartItemId, // Backend expects string, will convert to int
            'quantity': quantity,
            'instructions': instructions,
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data!['updateCartItem'];
    } catch (e) {
      throw Exception('Failed to update cart item: $e');
    }
  }

  // Remove item from cart
  static Future<bool> removeFromCart(String cartItemId) async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.mutate(
        MutationOptions(
          document: gql(removeFromCartMutation),
          variables: {
            'cartItemId':
                cartItemId, // Backend expects string, will convert to int
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data!['removeFromCart'] == true;
    } catch (e) {
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  // Get user's cart for specific restaurant or any cart
  static Future<Map<String, dynamic>?> getMyCart({String? restaurantId}) async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.query(
        QueryOptions(
          document: gql(getMyCartQuery),
          variables: {'restaurantId': restaurantId},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data!['getMyCart'];
    } catch (e) {
      throw Exception('Failed to get cart: $e');
    }
  }

  // Get all user's carts
  static Future<List<Map<String, dynamic>>> getAllMyCarts() async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.query(
        QueryOptions(document: gql(getAllMyCartsQuery)),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final carts = result.data!['getMyCarts'] as List?;
      return carts?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      throw Exception('Failed to get all carts: $e');
    }
  }

  // Update cart info
  static Future<Map<String, dynamic>?> updateCart({
    required String cartId,
    String? address,
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.mutate(
        MutationOptions(
          document: gql(updateCartMutation),
          variables: {
            'cartId': cartId,
            'address': address,
            'paymentMethod': paymentMethod,
            'notes': notes,
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data!['updateCart'];
    } catch (e) {
      throw Exception('Failed to update cart: $e');
    }
  }

  // Clear cart
  static Future<bool> clearCart(String cartId) async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.mutate(
        MutationOptions(
          document: gql(clearCartMutation),
          variables: {'cartId': cartId},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return true;
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  // Checkout cart
  static Future<Map<String, dynamic>?> checkoutCart(String cartId) async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.mutate(
        MutationOptions(
          document: gql(checkoutCartMutation),
          variables: {'cartId': cartId},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data!['checkoutCart'];
    } catch (e) {
      throw Exception('Failed to checkout cart: $e');
    }
  }

  // Check if user has any active carts
  static Future<bool> hasActiveCarts() async {
    try {
      final carts = await getAllMyCarts();
      return carts.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
