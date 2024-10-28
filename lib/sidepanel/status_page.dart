import 'package:flutter/material.dart';
import 'dart:io';
import './../api.dart';
import 'package:file_picker/file_picker.dart'; // Add file_picker dependency in pubspec.yaml

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _HomePageState();
}

class _HomePageState extends State<StatusPage>
    with SingleTickerProviderStateMixin {
  File? _selectedFile;
  String? _downloadFileId;
  String? _fileName;
  String? _fileSize;
  TabController? _tabController;

  List<Map<String, dynamic>> providers = [];

  final List<Map<String, String>> _downloadableFiles = [
    {'name': 'Document123.pdf', 'size': '500 KB', 'hash': 'abcd1234'},
    {'name': 'Image2.png', 'size': '1.2 MB', 'hash': 'efgh5678'},
    {'name': 'Presentation.ppt', 'size': '2 MB', 'hash': 'ijkl9101'},
  ];

  final List<Map<String, String>> _providedFiles = [
    {'name': 'Document123.pdf', 'size': '500 KB', 'hash': 'abcd1234'},
    {'name': 'Image2.png', 'size': '1.2 MB', 'hash': 'efgh5678'},
    {'name': 'Presentation.ppt', 'size': '2 MB', 'hash': 'ijkl9101'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
                setState(() {
                  _providedFiles.removeAt(index); // Remove file from the list
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

  void downloadFile(int index, String filename, String peerId) async {
    try {
      String? destinationPath = await FilePicker.platform.saveFile(
        dialogTitle: "Save file from ${_downloadFileId!.substring(0, 16)}",
        fileName: filename,
      );
      if (destinationPath != null) {
        debugPrint("Selected destination path: $destinationPath");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Selected download location: $destinationPath')),
        );
        startDownload(_downloadFileId, providers[index]['peer_id'], destinationPath);
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
    setState(() {
      _downloadFileId = fileId;
    });
    print('Downloading file for: $fileId');
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
      } else {
        print('Failed to start download.');
      }
    } catch (e) {
      print('Error downloadin: $e');
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
                  Text(
                    'Provide File',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Colors.blue[800]),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 4,
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 209, 241, 255),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            onPressed: _pickFile,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16.0),
                            ),
                            child: const Text('Browse File'),
                          ),
                          const SizedBox(height: 8),
                          if (_fileName != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'File: $_fileName ($_fileSize)',
                                  style: TextStyle(color: Colors.blue[900]),
                                ),
                                ElevatedButton(
                                  onPressed: _uploadFile,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(16.0),
                                  ),
                                  child: const Text('Upload'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Text(
                    'Provided Files',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Colors.blue[800]),
                  ),
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
                        child: SingleChildScrollView(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('File Name')),
                              DataColumn(label: Text('Size')),
                              DataColumn(label: Text('Hash')),
                              DataColumn(label: Text('Action')),
                            ],
                            rows: _providedFiles.isNotEmpty
                                ? _providedFiles
                                    .asMap()
                                    .entries
                                    .map(
                                      (entry) => DataRow(
                                        cells: [
                                          DataCell(Text(entry.value['name']!)),
                                          DataCell(Text(entry.value['size']!)),
                                          DataCell(Text(entry.value['hash']!)),
                                          DataCell(
                                            ElevatedButton(
                                              onPressed: () {
                                                _showStopProvidingDialog(
                                                    entry.key,
                                                    entry.value['name']!);
                                              },
                                              child:
                                                  const Text('Stop Providing'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    .toList()
                                : const [
                                    DataRow(cells: [
                                      DataCell(Text('No files provided')),
                                      DataCell(Text('')),
                                      DataCell(Text('')),
                                      DataCell(Text(''))
                                    ]),
                                  ],
                          ),
                        ),
                      ),
                    ),
                  ),
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
                        icon: const Icon(Icons.download),
                        label: const Text('Search'),
                      ),
                      // IconButton(
                      //   icon: const Icon(Icons.download),
                      //   onPressed: _onDownloadPressed,
                      //   tooltip: 'Download',
                      // ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Providers',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Colors.blue[800]),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Card(
                      elevation: 4,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 209, 241, 255),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: SingleChildScrollView(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('File Name')),
                              DataColumn(label: Text('Fee Rate per KB')),
                              DataColumn(label: Text('Peer Id')),
                              DataColumn(label: Text('Action')),
                            ],
                            rows: providers.isNotEmpty
                                ? providers
                                    .asMap()
                                    .entries
                                    .map(
                                      (entry) => DataRow(
                                        cells: [
                                          DataCell(
                                              Text(entry.value['file_name']!)),
                                          DataCell(Text(entry
                                              .value['fee_rate_per_kb']!
                                              .toString())),
                                          DataCell(
                                              Text(entry.value['peer_id']!)),
                                          DataCell(
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                downloadFile(
                                                    entry.key,
                                                    entry.value['file_name']!,
                                                    entry.value['peer_id']!
                                                );
                                              },
                                              icon: const Icon(Icons.download),
                                              label: const Text('Download'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    .toList()
                                : const [
                                    DataRow(cells: [
                                      DataCell(Text('No Providers Found')),
                                      DataCell(Text('')),
                                      DataCell(Text('')),
                                      DataCell(Text(''))
                                    ]),
                                  ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Downloaded Files',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Colors.blue[800]),
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
                        child: SingleChildScrollView(
                          child: Container(
                            width: double.infinity,
                            // Makes the table take up all available width
                            padding: const EdgeInsets.all(8.0),
                            // Optional padding
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('File Name')),
                                DataColumn(label: Text('Size')),
                                DataColumn(label: Text('Hash')),
                              ],
                              rows: _downloadableFiles
                                  .map(
                                    (file) => DataRow(
                                      cells: [
                                        DataCell(Text(file['name']!)),
                                        DataCell(Text(file['size']!)),
                                        DataCell(Text(file['hash']!)),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
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

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: StatusPage(),
  ));
}
