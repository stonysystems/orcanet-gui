import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer';

class ApiEndpoints {
  static const BASE_URL = "http://127.0.0.1:8000/api";
  static const HEALTH_CHECK_ENDPOINT = 'health';

  // Wallet endpoints
  static const WALLET_ENDPOINT = 'wallet';
  static const BLOCKS_COUNT = '${WALLET_ENDPOINT}/blocks-count';
  static const BALANCE = '${WALLET_ENDPOINT}/balance';
  static const LOAD_WALLET = '${WALLET_ENDPOINT}/load-wallet';
  static const SEND_TO_ADDRESS = '${WALLET_ENDPOINT}/send-to-address';
  static const GENERATE_BLOCK = '${WALLET_ENDPOINT}/generate-block';
  static const LIST_TRANSACTIONS = '${WALLET_ENDPOINT}/list-transactions';
  static const GET_TRANSACTION_INFO = '${WALLET_ENDPOINT}/get-transaction-info';

  // File sharing endpoints
  static const FILE_ENDPOINT = 'file';
  static const DIAL = '${FILE_ENDPOINT}/dial';
  static const GET_PROVIDED_FILES = '${FILE_ENDPOINT}/get-provided-files';
  static const GET_DOWNLOADED_FILES = '${FILE_ENDPOINT}/get-downloaded-files';
  static const GET_FILE_INFO = '${FILE_ENDPOINT}/get-file-info';
  static const PROVIDE_FILE = '${FILE_ENDPOINT}/provide-file';
  static const STOP_PROVIDING = '${FILE_ENDPOINT}/stop-providing';
  static const RESUME_PROVIDING = '${FILE_ENDPOINT}/resume-providing';
  static const DOWNLOAD_FILE = '${FILE_ENDPOINT}/download-file';
  static const GET_PROVIDERS = '${FILE_ENDPOINT}/get-providers';

  // Proxy endpoints
  static const PROXY_ENDPOINT = 'proxy';
  static const GET_PROXY_PROVIDERS = '${PROXY_ENDPOINT}/get-providers';
  static const STOP_PROXY = '${PROXY_ENDPOINT}/stop';
  static const CONNECT_TO_PROXY = '${PROXY_ENDPOINT}/connect';
  static const START_PROVIDING = '${PROXY_ENDPOINT}/start-providing';
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
  static Future<Map<String, dynamic>> listTransactions(
      int startOffset, int endOffset) async {
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
  static Future<Map<String, dynamic>> stopProviding(String fileId,
      {bool permanent = false}) async {
    return Api.post(
      '${ApiEndpoints.STOP_PROVIDING}/$fileId?permanent=$permanent',

      //body: {'permanent': permanent},
    );
  }

  static Future<Map<String, dynamic>> resumeProviding(
    String fileId,
  ) async {
    return Api.post('${ApiEndpoints.RESUME_PROVIDING}/$fileId');
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

  // Get Transanction List
  static Future<List<Map<String, dynamic>>> getTransactionList() async {
    // Simulate a network request with a delay
    await Future.delayed(const Duration(seconds: 2));

    return [
      {
        'txid': '1A2B3C4D5E6F7G8H9I0J',
        'amount': 0.03567890,
        'confirmations': 4,
        'category': 'Deposit',
        'time': DateTime.now()
                .subtract(Duration(hours: 1))
                .millisecondsSinceEpoch ~/
            1000,
      },
      {
        'txid': '2B3C4D5E6F7G8H9I0J1K',
        'amount': -0.01234567,
        'confirmations': 1,
        'category': 'Withdrawal',
        'time':
            DateTime.now().subtract(Duration(days: 1)).millisecondsSinceEpoch ~/
                1000,
      },
      {
        'txid': '3C4D5E6F7G8H9I0J1K2L',
        'amount': 0.10000000,
        'confirmations': 5,
        'category': 'Deposit',
        'time':
            DateTime.now().subtract(Duration(days: 2)).millisecondsSinceEpoch ~/
                1000,
      },
      {
        'txid': '4D5E6F7G8H9I0J1K2L3M',
        'amount': -0.02567890,
        'confirmations': 0,
        'category': 'Withdrawal',
        'time': DateTime.now()
                .subtract(Duration(hours: 12))
                .millisecondsSinceEpoch ~/
            1000,
      },
      {
        'txid': '5E6F7G8H9I0J1K2L3M4N',
        'amount': 0.25000000,
        'confirmations': 3,
        'category': 'Deposit',
        'time':
            DateTime.now().subtract(Duration(days: 3)).millisecondsSinceEpoch ~/
                1000,
      },
      {
        'txid': '6F7G8H9I0J1K2L3M4N5O',
        'amount': -0.00567890,
        'confirmations': 2,
        'category': 'Withdrawal',
        'time': DateTime.now()
                .subtract(Duration(hours: 5))
                .millisecondsSinceEpoch ~/
            1000,
      },
    ];
  }

  static Future<Map<String, dynamic>> getProxyProviders() async {
    return Api.get(ApiEndpoints.GET_PROXY_PROVIDERS);
  }

  static Future<Map<String, dynamic>> startProviding() async {
    return Api.post(ApiEndpoints.START_PROVIDING);
  }

  static Future<Map<String, dynamic>> stopProxy() async {
    return Api.post(ApiEndpoints.STOP_PROXY);
  }

  static Future<Map<String, dynamic>> connectToProxy(String peerId) async {
    return Api.post(ApiEndpoints.STOP_PROXY, body: {'peer_id': peerId});
  }

  static Future<Map<String, dynamic>> healthCheck() async {
    return Api.get(ApiEndpoints.HEALTH_CHECK_ENDPOINT);
  }

  static Future<String> getIPLocation(String ip) async {
    final response = await http.get(
      Uri.parse('https://ipinfo.io/$ip/json'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if(response.statusCode == 200) {
      Map<String, dynamic> body = jsonDecode(response.body);
      return "${body['city']}, ${body['region']}, ${body['country']}";
    } else {
      return 'Unknown';
    }
  }
}
