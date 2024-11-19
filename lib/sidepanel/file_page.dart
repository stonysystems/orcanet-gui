import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../utils.dart';
import './../api.dart';
import 'package:file_picker/file_picker.dart'; // Add file_picker dependency in pubspec.yaml

class FilePage extends StatefulWidget {
  const FilePage({super.key});

  @override
  State<FilePage> createState() => _HomePageState();
}

class _HomePageState extends State<FilePage>
    with SingleTickerProviderStateMixin {
  File? _selectedFile;
  String? _downloadFileId;
  String? _fileName;
  String? _fileSize;
  TabController? _tabController;

  List<Map<String, dynamic>> providers = [];
  List<Map<String, dynamic>> providedList = [];
  List<Map<String, dynamic>> downloadedList = [];

  final List<Map<String, String>> _providedFiles = [];

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _downloadSearchController =
      TextEditingController();
  List<Map<String, dynamic>> providedFilteredList = [];
  List<Map<String, dynamic>> downloadedFilteredList = [];

  @override
  void initState() {
    super.initState();
    getProvidedFiles();
    getDownloadedFiles();
    refreshApiCalls();
    _tabController = TabController(length: 2, vsync: this);
    providedFilteredList = List.from(providedList); // Initialize filtered list
    downloadedFilteredList = List.from(downloadedList);
    _searchController.addListener(_onSearchChanged);
    _downloadSearchController.addListener(_onSearchChanged);
  }

  //search function

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      if (_tabController?.index == 0) {
        providedFilteredList = providedList
            .where((file) =>
                file['file_name']
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()) ||
                file['file_id']
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()))
            .toList();
      } else {
        downloadedFilteredList = downloadedList
            .where((file) =>
                file['file_name']
                    .toLowerCase()
                    .contains(_downloadSearchController.text.toLowerCase()) ||
                file['file_id']
                    .toLowerCase()
                    .contains(_downloadSearchController.text.toLowerCase()))
            .toList();
      }
    });
  }

  // Function to show confirmation dialog
  void _showStopProvidingDialog(int index, String filename) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Stop Providing File'),
          content:
              const Text('Are you sure you want to stop providing this file?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                stopProviding(filename, true);
                setState(() {
                  _providedFiles.removeAt(index); // Remove file from the list
                  providedFilteredList.removeAt(index);
                });
                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Providing stopped $filename')),
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmUploadDialog(int index, String filename) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Start Providing File'),
          content: Text('Are you sure you want to provide this file $filename'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _uploadFile();
                // setState(() {
                //   _providedFiles.removeAt(index); // Remove file from the list
                // });
                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Providing File $filename')),
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void showTableDialog(
      BuildContext context, List<Map<String, dynamic>> providers) {
    String fileId = _controller.text;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isAscending = true;

            void sortProvidersByFeeRate() {
              setState(() {
                providers.sort((a, b) {
                  final feeA = a['fee_rate_per_kb'] as num? ?? 0;
                  final feeB = b['fee_rate_per_kb'] as num? ?? 0;
                  return isAscending
                      ? feeA.compareTo(feeB)
                      : feeB.compareTo(feeA);
                });
                isAscending = !isAscending;
              });
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Container(
                width: 1000, // Set a smaller width
                height: 500, // Set a smaller height
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 209, 241, 255),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Providers for id $fileId',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.blue,
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text('File Name',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: sortProvidersByFeeRate,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Fee Rate per KB',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Icon(
                                    isAscending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Text('Peer Id',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                          const Expanded(
                            child: Text('Action',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: providers.isNotEmpty
                              ? providers
                                  .map(
                                    (entry) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 8.0),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                                  entry['file_name'] ?? '')),
                                          Expanded(
                                              child: Text(
                                                  entry['fee_rate_per_kb']
                                                          ?.toString() ??
                                                      '')),
                                          Expanded(
                                              child:
                                                  Text(entry['peer_id'] ?? '')),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                downloadFile(
                                                  entry['file_name']!,
                                                  entry['peer_id']!,
                                                );
                                              },
                                              icon: const Icon(Icons.download),
                                              label: const Text('Download'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList()
                              : [
                                  Container(
                                    padding: const EdgeInsets.all(16.0),
                                    alignment: Alignment.center,
                                    child: const Text('No Providers Found'),
                                  ),
                                ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
        _fileSize =
            '${(result.files.single.size / 1024).toStringAsFixed(2)} KB';
      });
      print(_selectedFile);
      _showConfirmUploadDialog(0, result.files.single.name);
    }
  }

  // Function to upload and append file details to _providedFiles
  void _uploadFile() {
    if (_selectedFile != null && _fileName != null && _fileSize != null) {
      provideFile(_selectedFile!.path.toString());
      final newFile = {
        'name': _fileName!, // File name
        'size': _fileSize!, // File size
        'hash': 'hash_placeholder', // Placeholder for file hash
      };

      setState(() {
        _providedFiles.add(newFile); // Append new file to the list
        _fileName = null;
        _fileSize = null;
        _selectedFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File uploaded and added successfully!')),
      );
    }
  }

  final TextEditingController _controller = TextEditingController();

  void downloadFile(String filename, String peerId) async {
    try {
      String? destinationPath = await FilePicker.platform.saveFile(
        dialogTitle: "Save file from ${_downloadFileId!.substring(0, 16)}",
        fileName: filename,
      );
      if (destinationPath != null) {
        debugPrint("Selected destination path: $destinationPath");
        startDownload(_downloadFileId, peerId, destinationPath);
      } else {
        debugPrint("User canceled directory selection");
      }
    } catch (e) {
      debugPrint("Error selecting directory: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to select directory: $e')),
      );
    }
  }

  void _searchProviders() async {
    String fileId = _controller.text;
    _getProviders(fileId);
    showTableDialog(context, providers);
    setState(() {
      _downloadFileId = fileId;
    });
    print('Downloading file for: $fileId');
  }

  void refreshApiCalls() {
    Timer.periodic(Duration(seconds: 30), (Timer timer) {
      getProvidedFiles();
      getDownloadedFiles();
    });
  }

  // Api calls starts--->
  Future<void> _getProviders(fileId) async {
    try {
      final response = await Api.getProviders(fileId);
      if (response['success']) {
        print(response['data']);
        setState(() {
          providers = List<Map<String, dynamic>>.from(response['data']);
        });
      } else {
        print('Failed to retrieve providers.');
      }
    } catch (e) {
      print('Error fetching providers: $e');
    }
  }

  Future<void> startDownload(fileId, peerId, destPath) async {
    try {
      final response = await Api.downloadFile(
        fileId: fileId,
        peerId: peerId,
        destPath: destPath,
      );
      if (response['success']) {
        print("download successful");
        Utils.showSuccessSnackBar(context, "File downloaded successfully");
      } else {
        Utils.showSuccessSnackBar(context, "Download failed");
        print('Failed to start download.');
      }
    } catch (e) {
      Utils.showSuccessSnackBar(context, "Download failed");
      print('Error downloading: $e');
    }
  }

  Future<void> provideFile(filePath) async {
    try {
      final response = await Api.provideFile(filePath.toString());

      print(response);

      if (response['success']) {
        print("provided successfully");
      } else {
        print('Failed to provide.');
      }
    } catch (e) {
      print('Error providing: $e');
    }
  }

  Future<void> getProvidedFiles() async {
    try {
      final response = await Api.getProvidedFiles();
      if (response['success']) {
        print(response['data']);
        setState(() {
          providedList = List<Map<String, dynamic>>.from(response['data']);
          providedFilteredList = List<Map<String, dynamic>>.from(providedList);
        });
      } else {
        print('Failed to retrieve provided list.');
      }
    } catch (e) {
      print('Error fetching provided list: $e');
    }
  }

  Future<void> getDownloadedFiles() async {
    try {
      final response = await Api.getDownloadedFiles();
      if (response['success']) {
        print(response['data']);
        setState(() {
          downloadedList = List<Map<String, dynamic>>.from(response['data']);
          downloadedFilteredList = List<Map<String, dynamic>>.from(response['data']);
        });
      } else {
        print('Failed to retrieve downloaded list.');
      }
    } catch (e) {
      print('Error fetching downloaded list: $e');
    }
  }

  Future<void> stopProviding(String fileId, bool permanent) async {
    try {
      final response = await Api.stopProviding(fileId, permanent: permanent);
      if (response['success']) {
      } else {
        print('Failed to stop providing.');
      }
    } catch (e) {
      print('Error while stopping provider: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Provide and Download
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          title: null,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.upload_file),
                // Add an icon for the 'Provide File' tab
                text: 'Provide File',
              ),
              Tab(
                icon: Icon(Icons.download),
                // Add an icon for the 'Download File' tab
                text: 'Download File',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Provide Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   'Provide File',
                  //   style: Theme.of(context)
                  //       .textTheme
                  //       .titleLarge!
                  //       .copyWith(color: Colors.blue[800]),
                  // ),
                  // const SizedBox(height: 8),
                  // Card(
                  //   elevation: 4,
                  //   child: Container(
                  //     padding: const EdgeInsets.all(12.0),
                  //     decoration: BoxDecoration(
                  //       color: const Color.fromARGB(255, 209, 241, 255),
                  //       borderRadius: BorderRadius.circular(8.0),
                  //     ),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         ElevatedButton(
                  //           onPressed: _pickFile,
                  //           style: ElevatedButton.styleFrom(
                  //             padding: const EdgeInsets.all(16.0),
                  //           ),
                  //           child: const Text('Browse File'),
                  //         ),
                  //         const SizedBox(height: 8),
                  //         if (_fileName != null)
                  //           Row(
                  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //             children: [
                  //               Text(
                  //                 'File: $_fileName ($_fileSize)',
                  //                 style: TextStyle(color: Colors.blue[900]),
                  //               ),
                  //               ElevatedButton(
                  //                 onPressed: _uploadFile,
                  //                 style: ElevatedButton.styleFrom(
                  //                   padding: const EdgeInsets.all(16.0),
                  //                 ),
                  //                 child: const Text('Upload'),
                  //               ),
                  //             ],
                  //           ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 36),
                  Text(
                    'Provided Files',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Colors.blue[800]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Search Files',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 80),

                      // Browse Button
                      ElevatedButton(
                        onPressed: _pickFile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16.0),
                        ),
                        child: const Text('Provide File'),
                      ),
                      const SizedBox(width: 30),
                    ],
                  ),
                  // TextField(
                  //   controller: _searchController,
                  //   decoration: InputDecoration(
                  //     labelText: 'Search Files',
                  //     prefixIcon: Icon(Icons.search),
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(8.0),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Card(
                      elevation: 4,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 209, 241, 255),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          children: [
                            // Sticky Header Row
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              color: const Color.fromARGB(255, 56, 118,
                                  168), // Background color for header
                              child: Row(
                                children: const [
                                  Expanded(
                                      child: Text('File Name',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white))),
                                  Expanded(
                                      child: Text('File ID',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white))),
                                  Expanded(
                                      child: Text('Download Count',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white))),
                                  Expanded(
                                      child: Text('Action',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white))),
                                  Expanded(
                                      child: Text('Status',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white))),
                                ],
                              ),
                            ),
                            // Scrollable Data Rows
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: providedFilteredList.isNotEmpty
                                      ? providedFilteredList
                                          .map(
                                            (entry) => Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                      horizontal: 8.0),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey
                                                          .shade300), // Divider between rows
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      child: Text(
                                                          entry['file_name'] ??
                                                              '')),
                                                  Expanded(
                                                    child: MouseRegion(
                                                      cursor: SystemMouseCursors
                                                          .click,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Clipboard.setData(
                                                              ClipboardData(
                                                                  text: entry[
                                                                          'file_id'] ??
                                                                      ''));
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    "File ID copied to clipboard")),
                                                          );
                                                        },
                                                        child: Text(
                                                          (entry['file_id'] ??
                                                                      '')
                                                                  .substring(
                                                                      0, 10) +
                                                              '...',
                                                          style: TextStyle(
                                                            color: Colors.blue,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                      child: Text(
                                                          entry['downloads_count']
                                                                  ?.toString() ??
                                                              '')),
                                                  Expanded(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          width: 120,
                                                          height: 30,
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              _showStopProvidingDialog(
                                                                providedFilteredList
                                                                    .indexOf(
                                                                        entry),
                                                                entry[
                                                                    'file_id']!,
                                                              );
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8.0,
                                                                      vertical:
                                                                          4.0),
                                                              textStyle:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          12),
                                                            ),
                                                            child: const Text(
                                                                'Stop Providing'),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Toggle Button for Status
                                                  Expanded(
                                                      child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                        width: 120,
                                                        height: 30,
                                                        child: StatefulBuilder(
                                                          builder: (context,
                                                              setState) {
                                                            bool isProviding = entry[
                                                                    'is_providing'] ??
                                                                true; // Assuming initial state
                                                            return Row(
                                                              children: [
                                                                Switch(
                                                                  value:
                                                                      isProviding,
                                                                  onChanged:
                                                                      (value) {
                                                                    setState(
                                                                        () {
                                                                      isProviding =
                                                                          value;
                                                                      entry['is_providing'] =
                                                                          isProviding;
                                                                    });
                                                                  },
                                                                  activeColor:
                                                                      Colors
                                                                          .green,
                                                                  inactiveThumbColor:
                                                                      Colors
                                                                          .red,
                                                                  inactiveTrackColor: Colors
                                                                      .red
                                                                      .withOpacity(
                                                                          0.3),
                                                                ),
                                                                Text(
                                                                    isProviding
                                                                        ? 'Resume'
                                                                        : 'Stop',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: isProviding
                                                                            ? Colors.green
                                                                            : Colors.red)),
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList()
                                      : [
                                          Container(
                                            padding: const EdgeInsets.all(16.0),
                                            alignment: Alignment.center,
                                            child:
                                                const Text('No files provided'),
                                          ),
                                        ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            // Download Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Download Files',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Colors.blue[800]),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter Hash of the File',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _searchProviders,
                        icon: const Icon(Icons.person_search),
                        label: const Text('Search'),
                      ),
                      // IconButton(
                      //   icon: const Icon(Icons.download),
                      //   onPressed: _onDownloadPressed,
                      //   tooltip: 'Download',
                      // ),
                    ],
                  ),
                  // const SizedBox(height: 20),
                  // Text(
                  //   'Providers',
                  //   style: Theme.of(context)
                  //       .textTheme
                  //       .titleLarge!
                  //       .copyWith(color: Colors.blue[800]),
                  // ),
                  // const SizedBox(height: 10),
                  // Expanded(
                  //   child: Card(
                  //     elevation: 4,
                  //     child: Container(
                  //       width: double.infinity,
                  //       decoration: BoxDecoration(
                  //         color: const Color.fromARGB(255, 209, 241, 255),
                  //         borderRadius: BorderRadius.circular(8.0),
                  //       ),
                  //       child: Column(
                  //         children: [
                  //           // Sticky Header Row
                  //           Container(
                  //             padding: const EdgeInsets.all(8.0),
                  //             color: const Color.fromARGB(255, 56, 118, 168), // Background color for header
                  //             child: Row(
                  //               children: const [
                  //                 Expanded(child: Text('File Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                  //                 Expanded(child: Text('Fee Rate per KB', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                  //                 Expanded(child: Text('Peer Id', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                  //                 Expanded(child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                  //               ],
                  //             ),
                  //           ),
                  //           // Scrollable Data Rows
                  //           Expanded(
                  //             child: SingleChildScrollView(
                  //               child: Column(
                  //                 children: providers.isNotEmpty
                  //                     ? providers.asMap().entries.map(
                  //                         (entry) => Container(
                  //                           padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  //                           decoration: BoxDecoration(
                  //                             border: Border(
                  //                               bottom: BorderSide(color: Colors.grey.shade300), // Divider between rows
                  //                             ),
                  //                           ),
                  //                           child: Row(
                  //                             children: [
                  //                               Expanded(child: Text(entry.value['file_name'] ?? '')),
                  //                               Expanded(child: Text(entry.value['fee_rate_per_kb']?.toString() ?? '')),
                  //                               Expanded(child: Text(entry.value['peer_id'] ?? '')),
                  //                               Expanded(
                  //                                 child: ElevatedButton.icon(
                  //                                   onPressed: () {
                  //                                     downloadFile(
                  //                                       entry.value['file_name']!,
                  //                                       entry.value['peer_id']!,
                  //                                     );
                  //                                   },
                  //                                   icon: const Icon(Icons.download),
                  //                                   label: const Text('Download'),
                  //                                 ),
                  //                               ),
                  //                             ],
                  //                           ),
                  //                         ),
                  //                       ).toList()
                  //                     : [
                  //                         Container(
                  //                           padding: const EdgeInsets.all(16.0),
                  //                           alignment: Alignment.center,
                  //                           child: const Text('No Providers Found'),
                  //                         ),
                  //                       ],
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  const SizedBox(height: 80),
                  Text(
                    'Downloaded Files',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Colors.blue[800]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _downloadSearchController,
                          decoration: InputDecoration(
                            labelText: 'Search Files',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Card(
                      elevation: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 209, 241, 255),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          children: [
                            // Sticky Header Row
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              color: const Color.fromARGB(255, 56, 118,
                                  168), // Background color for header
                              child: Row(
                                children: const [
                                  Expanded(
                                      child: Text('File Name',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white))),
                                  Expanded(
                                      child: Text('File Id',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white))),
                                  Expanded(
                                      child: Text('Size(KB)',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white))),
                                  Expanded(
                                      child: Text('Price',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white))),
                                ],
                              ),
                            ),
                            // Scrollable Data Rows
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: downloadedFilteredList.isNotEmpty
                                      ? downloadedFilteredList
                                          .map(
                                            (entry) => Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                      horizontal: 8.0),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey
                                                          .shade300), // Divider between rows
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      child: Text(
                                                          entry['file_name'] ??
                                                              '')),
                                                  Expanded(
                                                    child: MouseRegion(
                                                      cursor: SystemMouseCursors
                                                          .click,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Clipboard.setData(
                                                              ClipboardData(
                                                                  text: entry[
                                                                          'file_id'] ??
                                                                      ''));
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    "File ID copied to clipboard")),
                                                          );
                                                        },
                                                        child: Text(
                                                          (entry['file_id'] ??
                                                                      '')
                                                                  .substring(
                                                                      0, 10) +
                                                              '...',
                                                          style: TextStyle(
                                                            color: Colors.blue,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                      child: Text(
                                                          entry['file_size_kb']
                                                                  ?.toString() ??
                                                              '')),
                                                  Expanded(
                                                      child: Text(entry['price']
                                                              ?.toString() ??
                                                          '')),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList()
                                      : [
                                          Container(
                                            padding: const EdgeInsets.all(16.0),
                                            alignment: Alignment.center,
                                            child: const Text(
                                                'No Downloads Found'),
                                          ),
                                        ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
