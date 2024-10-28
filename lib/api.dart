import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer';

class ApiEndpoints {
  static const BASE_URL = "http://127.0.0.1:8000";

  // Wallet endpoints
  static const BLOCKS_COUNT = 'blocks-count';
  static const BALANCE = 'balance';
  static const LOAD_WALLET = 'load-wallet';
  static const SEND_TO_ADDRESS = 'send-to-address';
  static const GENERATE_BLOCK = 'generate-block';
  static const LIST_TRANSACTIONS = 'list-transactions';
  static const GET_TRANSACTION_INFO = 'get-transaction-info';

  // File sharing endpoints
  static const DIAL = 'dial';
  static const GET_PROVIDED_FILES = 'get-provided-files';
  static const GET_DOWNLOADED_FILES = 'get-downloaded-files';
  static const GET_FILE_INFO = 'get-file-info';
  static const PROVIDE_FILE = 'provide-file';
  static const STOP_PROVIDING = 'stop-providing';
  static const DOWNLOAD_FILE = 'download-file';
  static const GET_PROVIDERS = 'get-providers';
}

class Api {
  static Future<Map<String, dynamic>> get(String endpoint,
      {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.BASE_URL}/$endpoint')
          .replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      log("Got response for $endpoint - ${response.statusCode}: "); // ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> post(String endpoint,
      {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.BASE_URL}/$endpoint');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body != null ? json.encode(body) : null,
      );

      log("Got response $endpoint - - ${response.statusCode}"); //: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to post data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Call to get the block count
  static Future<Map<String, dynamic>> getBlockCount() async {
    return Api.get(ApiEndpoints.BLOCKS_COUNT);
  }

  // Call to get the wallet balance
  static Future<Map<String, dynamic>> getBalance() async {
    return Api.get(ApiEndpoints.BALANCE);
  }

  // Loading a wallet with a given wallet name
  static Future<Map<String, dynamic>> loadWallet(String walletName) async {
    return Api.get('${ApiEndpoints.LOAD_WALLET}/$walletName}');
  }

  // Sending to a Bitcoin address
  static Future<Map<String, dynamic>> sendToAddress({
    required String address,
    required double amount,
    String? comment,
  }) async {
    return Api.post(ApiEndpoints.SEND_TO_ADDRESS,
        body: {"address": address, "amount": amount, "comment": comment});
  }

  // Generating a block (mining)
  static Future<Map<String, dynamic>> generateBlock() async {
    return Api.post(ApiEndpoints.GENERATE_BLOCK);
  }

  // List transactions with pagination
  static Future<Map<String, dynamic>> listTransactions(int startOffset, int endOffset) async {
    return Api.get(
      ApiEndpoints.LIST_TRANSACTIONS,
      queryParams: {
        'start_offset': startOffset.toString(),
        'end_offset': endOffset.toString(),
      },
    );
  }

  // Get transaction information by ID
  static Future<Map<String, dynamic>> getTransactionInfo(String txId) async {
    return Api.get('${ApiEndpoints.GET_TRANSACTION_INFO}/$txId');
  }

  // File sharing methods

  // Dial to a peer
  static Future<Map<String, dynamic>> dial(String peerId) async {
    return Api.post('${ApiEndpoints.DIAL}/$peerId');
  }

  // Get list of provided files
  static Future<Map<String, dynamic>> getProvidedFiles() async {
    return Api.get(ApiEndpoints.GET_PROVIDED_FILES);
  }

  // Get list of downloaded files
  static Future<Map<String, dynamic>> getDownloadedFiles() async {
    return Api.get(ApiEndpoints.GET_DOWNLOADED_FILES);
  }

  // Get file information by ID
  static Future<Map<String, dynamic>> getFileInfo(String fileId) async {
    return Api.get('${ApiEndpoints.GET_FILE_INFO}/$fileId');
  }

  // Provide a file to the network
  static Future<Map<String, dynamic>> provideFile(String filePath) async {
    return Api.post(
      ApiEndpoints.PROVIDE_FILE,
      body: {'file_path': filePath},
    );
  }

  // Stop providing a file
  static Future<Map<String, dynamic>> stopProviding(String fileId, {bool permanent = false}) async {
    return Api.post(
      '${ApiEndpoints.STOP_PROVIDING}/$fileId',
      body: {'permanent': permanent},
    );
  }

  // Download a file from a peer
  static Future<Map<String, dynamic>> downloadFile({
    required String fileId,
    required String peerId,
    required String destPath,
  }) async {
    return Api.post(
      ApiEndpoints.DOWNLOAD_FILE,
      body: {
        'file_id': fileId,
        'peer_id': peerId,
        'dest_path': destPath,
      },
    );
  }

  // Get providers for a file
  static Future<Map<String, dynamic>> getProviders(String fileId) async {
    return Api.get('${ApiEndpoints.GET_PROVIDERS}/$fileId');
  }

  static Future<Map<String, dynamic>> checkSystemStatus() async {
    // Simulated response
    return {
      'success': true,
      'status': 'Successful',
    };
  }

  static Future<Map<String, dynamic>> checkWalletStatus() async {
    // Simulated response
    return {
      'success': true,
      'status': 'Failed',
    };
  }
}
