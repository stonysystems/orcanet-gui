import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart'; // Add file_picker dependency in pubspec.yaml

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _selectedFile;
  String? _fileName;
  String? _fileSize;

  final List<Map<String, String>> _downloadableFiles = [
    {'name': 'Document1.pdf', 'size': '500 KB', 'hash': 'abcd1234'},
    {'name': 'Image2.png', 'size': '1.2 MB', 'hash': 'efgh5678'},
    {'name': 'Presentation.ppt', 'size': '2 MB', 'hash': 'ijkl9101'},
  ];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
        _fileSize =
            '${(result.files.single.size / 1024).toStringAsFixed(2)} KB';
      });
    }
  }

  void _uploadFile() {
    if (_selectedFile != null) {
      // Implement your upload logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File uploaded successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.lightBlue[800],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.lightBlue[50], // Light blue background
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard Header
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'Welcome to the Dashboard',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(color: Colors.blue[900]),
              ),
            ),
            const SizedBox(height: 16),

            // Upload Section
            Text(
              'Upload Document',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Colors.blue[800]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: _pickFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue[700],
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
                            backgroundColor: Colors.lightBlue[700],
                            padding: const EdgeInsets.all(16.0),
                          ),
                          child: const Text('Upload'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Download Section
            Text(
              'Downloadable Files',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Colors.blue[800]),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.lightBlue[100],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: ListView(
                    padding: const EdgeInsets.all(12.0),
                    children: [
                      DataTable(
                        columns: const [
                          DataColumn(
                            label: Text('File Name'),
                          ),
                          DataColumn(
                            label: Text('Size'),
                          ),
                          DataColumn(
                            label: Text('Hash'),
                          ),
                          DataColumn(
                            label: Text('Action'),
                          ),
                        ],
                        rows: _downloadableFiles
                            .map(
                              (file) => DataRow(
                                cells: [
                                  DataCell(Text(file['name']!)),
                                  DataCell(Text(file['size']!)),
                                  DataCell(Text(file['hash']!)),
                                  DataCell(
                                    ElevatedButton(
                                      onPressed: () {
                                        // Implement download logic here
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.lightBlue[700],
                                      ),
                                      child: const Text('Download'),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
