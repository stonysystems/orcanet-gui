import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart'; // Add file_picker dependency in pubspec.yaml

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _HomePageState();
}

class _HomePageState extends State<StatusPage> {
  File? _selectedFile;
  String? _fileName;
  String? _fileSize;

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

   // Function to show confirmation dialog
  void _showStopProvidingDialog(int index,String filename) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Stop Providing File'),
          content: const Text('Are you sure you want to stop providing this file?'),
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
    }
  }

  // Function to upload and append file details to _providedFiles
  void _uploadFile() {
    if (_selectedFile != null && _fileName != null && _fileSize != null) {
      // Create a map with file details (you can add hash logic as per your need)
      final newFile = {
        'name': _fileName!, // File name
        'size': _fileSize!, // File size
        'hash': 'hash_placeholder', // Placeholder for file hash
      };

      // Update the state to add the file to the provided list
      setState(() {
        _providedFiles.add(newFile); // Append new file to the list
        _fileName = null;
        _fileSize = null;
        _selectedFile =null;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File uploaded and added successfully!')),
      );
    }
  }

  final TextEditingController _controller = TextEditingController();

  void _onDownloadPressed() {
    // Handle the download action here
    String enteredText = _controller.text;
    print('Downloading file for: $enteredText');
    // Add your download functionality here.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        // color: Colors.lightBlue[50], // Light blue background
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 36),

            // Upload Section

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
                        // backgroundColor: Colors.lightBlue[700],
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
                              // backgroundColor: Colors.lightBlue[700],
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

            //Provided files table

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items to the edges
              children: [
                Text(
                  'Provided Files',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.blue[800]),
                ),
                Row(
                  children: [
                     // Check if _providedFiles is null or empty
                    (_fileName == null) 
                    ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 40, 42, 42),
                      ),
                       onPressed:  _pickFile,
                      child: Text(
                        '+ Import',
                        style: const TextStyle(color: Colors.white), // Set the text color to white
                      ),
                    ):
                    Row(
                      children: [
                        Text(
                          'File: $_fileName ($_fileSize)',
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 40, 42, 42),
                          ),
                          onPressed: _uploadFile,
                          child: Text(
                            'Provide',
                            style: const TextStyle(color: Colors.white), // Set the text color to white
                          ),
                        ),
                      ],
                    )
                  ],
                )
              
              ],
            ),
            const SizedBox(height: 8),
            
          Expanded(
            child: Card(
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 209, 241, 255),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          children: [
                            DataTable(
                              columnSpacing: 0,
                              columns: [
                                DataColumn(
                                  label: SizedBox(
                                    width: constraints.maxWidth * 0.25,
                                    child: Text('File Name', style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: constraints.maxWidth * 0.25,
                                    child: Text('Size', style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: constraints.maxWidth * 0.25,
                                    child: Text('Hash', style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: constraints.maxWidth * 0.25,
                                    child: Text('Action', style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                              ],
                              rows: _providedFiles.isNotEmpty
                                  ? _providedFiles
                                      .asMap()
                                      .entries
                                      .map(
                                        (entry) => DataRow(
                                          cells: [
                                            DataCell(
                                              ConstrainedBox(
                                                constraints: BoxConstraints(minHeight: 30),
                                                child: SizedBox(
                                                  width: constraints.maxWidth * 0.25,
                                                  child: Text(entry.value['name']!),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              ConstrainedBox(
                                                constraints: BoxConstraints(minHeight: 30),
                                                child: SizedBox(
                                                  width: constraints.maxWidth * 0.25,
                                                  child: Text(entry.value['size']!),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              ConstrainedBox(
                                                constraints: BoxConstraints(minHeight: 30),
                                                child: SizedBox(
                                                  width: constraints.maxWidth * 0.25,
                                                  child: Text(entry.value['hash']!),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              ConstrainedBox(
                                                constraints: BoxConstraints(minHeight: 30),
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    _showStopProvidingDialog(entry.key, entry.value['name']!);
                                                  },
                                                  style: ElevatedButton.styleFrom(),
                                                  child: const Text('Stop Providing'),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                      .toList()
                                  : [
                                      DataRow(
                                        cells: [
                                          DataCell(Text('')),
                                          DataCell(Text('')),
                                          DataCell(Text('')),
                                          DataCell(Text('')),
                                        ],
                                      ),
                                    ],
                            ),
                            if (_providedFiles.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'No files provided.',
                                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

            SizedBox(height: 30),

            // Download button and input bar
            Row(
              children: [
                // Text input field
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter Hash of the File',
                    ),
                  ),
                ),
                SizedBox(width: 30),
                // Download button
                IconButton(
                  icon: Icon(Icons.download),
                  onPressed: _onDownloadPressed,
                  tooltip: 'Download',
                ),
                SizedBox(width: 470),
              ],
            ),

            SizedBox(height: 30),
            
            //Download Files table
            Text(
              'Downloadable Files',
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
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 209, 241, 255),
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
                              label: Text(
                                'File Name',
                                style: TextStyle(fontSize: 16), // Increase font size
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Size',
                                style: TextStyle(fontSize: 16), // Increase font size
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Hash',
                                style: TextStyle(fontSize: 16), // Increase font size
                              ),
                            ),
                           
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
                      ],
                    ),
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