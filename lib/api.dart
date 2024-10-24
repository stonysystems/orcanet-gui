import 'dart:convert';

class Api {
  // Call to get the block count
  Future<Map<String, dynamic>> getBlockCount() async {
    // Simulated response
    return {
      'success': true,
      'data': 123456, // Example block count
    };
  }

  // Call to get the wallet balance
  Future<Map<String, dynamic>> getBalance() async {
    // Simulated response
    return {
      'success': true,
      'data': '101.1439 BTC', // Example balance
    };
  }

  // Loading a wallet with a given wallet name
  Future<Map<String, dynamic>> loadWallet(String walletName) async {
    // Simulated response
    return {
      'success': true,
      'data': 'Wallet loaded: $walletName',
    };
  }

  // Sending to a Bitcoin address
  Future<Map<String, dynamic>> sendToAddress({
    required String address,
    required double amount,
    String? comment,
  }) async {
    // Simulated response
    return {
      'success': true,
      'data': {'tx_id': 'mock-tx-id-123456'}, // Example transaction ID
    };
  }

  // Generating a block (mining)
  Future<Map<String, dynamic>> generateBlock() async {
    // Simulated response
    return {
      'success': true,
      'data': 'Started block generation',
    };
  }

  // Listing transactions with optional start and end offsets
  Future<Map<String, dynamic>> listTransactions({
    required int startOffset,
    required int endOffset,
  }) async {
    // Simulated response
    return {
      'success': true,
      'data': [
        {
          'tx_id': 'mock-tx-id-1',
          'amount': 0.01,
          'confirmations': 6,
        },
        {
          'tx_id': 'mock-tx-id-2',
          'amount': -0.02,
          'confirmations': 3,
        },
      ],
    };
  }

  // Getting transaction info by transaction ID
  Future<Map<String, dynamic>> getTransactionInfo(String txId) async {
    // Simulated response
    return {
      'success': true,
      'data': {
        'tx_id': txId,
        'amount': 0.01,
        'confirmations': 6,
        'details': 'Some details about the transaction',
      },
    };
  }

  // Dialing a peer
  Future<Map<String, dynamic>> dial(String peerId) async {
    // Simulated response
    return {
      'success': true,
      'data': 'Dialed peer $peerId successfully',
    };
  }

  // Getting provided files
  Future<Map<String, dynamic>> getProvidedFiles() async {
    // Simulated response
    return {
      'success': true,
      'data': [
        {'file_id': 'file-id-1', 'file_name': 'file1.txt'},
        {'file_id': 'file-id-2', 'file_name': 'file2.txt'},
      ],
    };
  }

  // Getting downloaded files
  Future<Map<String, dynamic>> getDownloadedFiles() async {
    // Simulated API response for downloaded files
    return {
      'success': true,
      'data': [
        {'file_id': 'file-id-3', 'file_name': 'file3.txt'},
        {'file_id': 'file-id-4', 'file_name': 'file4.txt'},
        {'file_id': 'file-id-5', 'file_name': 'file5.txt'},
      ],
    };
  }

  // Getting information for a specific file by its ID
  Future<Map<String, dynamic>> getFileInfo(String fileId) async {
    // Simulated response
    return {
      'success': true,
      'data': {
        'file_id': fileId,
        'file_name': 'file1.txt',
        'size': 1024,
      },
    };
  }

  // Providing a file
  Future<Map<String, dynamic>> provideFile(String filePath) async {
    // Simulated response
    return {
      'success': true,
      'data': 'Started providing file $filePath',
    };
  }

  // Stopping file sharing
  Future<Map<String, dynamic>> stopProviding(String fileId) async {
    // Simulated response
    return {
      'success': true,
      'data': 'Stopped providing file $fileId',
    };
  }

  // Downloading a file
  Future<Map<String, dynamic>> downloadFile({
    required String fileId,
    required String peerId,
    required String destPath,
  }) async {
    // Simulated response
    return {
      'success': true,
      'data': 'Downloaded file $fileId from peer $peerId to $destPath',
    };
  }

  // Getting file providers
  Future<Map<String, dynamic>> getProviders(String fileId) async {
    // Simulated response
    return {
      'success': true,
      'data': [
        {
          'file_name': 'file1.txt',
          'fee_rate_per_kb': 0.00001,
          'peer_id': 'mock-peer-id-1',
        },
        {
          'file_name': 'file2.txt',
          'fee_rate_per_kb': 0.00002,
          'peer_id': 'mock-peer-id-2',
        },
      ],
    };
  }

  Future<Map<String, dynamic>> checkSystemStatus() async {
    // Simulated response
    return {
      'success': true,
      'status': 'Successful',
    };
  }

  Future<Map<String, dynamic>> checkWalletStatus() async {
    // Simulated response
    return {
      'success': true,
      'status': 'Failed',
    };
  }
}
