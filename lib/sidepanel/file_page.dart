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

class _HomePageState extends State<FilePage> with TickerProviderStateMixin {
  File? _selectedFile;
  String? _downloadFileId;
  String? _fileName;
  String? _fileSize;
  TabController? _tabController;
  late AnimationController _iconcontroller;

  List<Map<String, dynamic>> providers = [];
  List<Map<String, dynamic>> providedList = [];
  List<Map<String, dynamic>> downloadedList = [];

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
    // refreshApiCalls();
    _tabController = TabController(length: 1, vsync: this);
    providedFilteredList = List.from(providedList); // Initialize filtered list
    downloadedFilteredList = List.from(downloadedList);
    _searchController.addListener(_onSearchChanged);
    _downloadSearchController.addListener(_onSearchChanged);
    _iconcontroller = AnimationController(
      duration: Duration(seconds: 1), // Animation duration
      vsync: this, // Using TickerProviderStateMixin
    );
  }

  void _refreshData() {
    getProvidedFiles();
    getDownloadedFiles();
    _iconcontroller.reset(); // Reset the animation
    _iconcontroller.forward(); // Start the animation
  }

  //search function

  @override
  void dispose() {
    _searchController.dispose();
    // _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      if (mounted && _tabController?.index == 0) {
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
  void _showStopProvidingDialog(int index, String fileId, String fileName) {
    print(index);
    print(fileId);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete File'),
          content: Text('Are you sure you want to delete $fileName?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black, // Change this to your desired color
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                stopProviding(fileId, true);
                setState(() {
                  providedList.removeAt(index); // Remove file from the list
                  providedFilteredList.removeAt(index);
                });
                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('File deleted $fileName')),
                );
              },
              child: const Text(
                'Yes',
                style: TextStyle(
                  color: Colors.black, // Change this to your desired color
                ),
              ),
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
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black, // Change this to your desired color
                ),
              ),
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
              child: const Text(
                'Yes',
                style: TextStyle(
                  color: Colors.black, // Change this to your desired color
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  bool isAscending = false;

  void showTableDialog(
      BuildContext context, List<Map<String, dynamic>> providers) {
    final colorScheme = Theme.of(context).colorScheme;
    String fileId = _controller.text;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void sortProvidersByFeeRate() {
              setState(() {
                isAscending = !isAscending;
                providers.sort((a, b) {
                  final feeA =
                      a['file_metadata']['fee_rate_per_kb'] as num? ?? 0;
                  final feeB =
                      b['file_metadata']['fee_rate_per_kb'] as num? ?? 0;
                  return isAscending
                      ? feeA.compareTo(feeB)
                      : feeB.compareTo(feeA);
                });
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
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Providers for id $fileId',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('File Name',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimary)),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: sortProvidersByFeeRate,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Fee Rate per KB',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onPrimary),
                                  ),
                                  Icon(
                                    isAscending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    color: colorScheme.surface,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text('Peer Id',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimary)),
                          ),
                          Expanded(
                            child: Text('Action',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimary)),
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
                                              child: Text(entry['file_metadata']
                                                      ?['file_name'] ??
                                                  '')),
                                          Expanded(
                                              child: Text(entry['file_metadata']
                                                          ?['fee_rate_per_kb']
                                                      ?.toString() ??
                                                  '')),
                                          Expanded(
                                              // child:
                                              //     Text(entry['peer_id'] ?? '').substring(0, 10) + '...'),
                                              child: Text(
                                            (entry['peer_id'] ?? '')
                                                    .substring(0, 10) +
                                                '...',
                                            style: TextStyle(
                                              color: colorScheme.onPrimary,
                                            ),
                                          )),
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 120,
                                                  height: 30,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      downloadFile(
                                                        entry['file_metadata']
                                                            ['file_name']!,
                                                        entry['peer_id']!,
                                                      );
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 8.0,
                                                        vertical: 4.0,
                                                      ),
                                                      textStyle:
                                                          const TextStyle(
                                                              fontSize: 12),
                                                      foregroundColor: Theme.of(
                                                              context)
                                                          .colorScheme
                                                          .onPrimary, // Text color
                                                    ),
                                                    child:
                                                        const Text('Download'),
                                                  ),
                                                ),
                                              ],
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
                        child: Text('Close',
                            style: TextStyle(color: colorScheme.error)),
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

  bool _isFilePickerOpen = false;
  Future<void> _pickFile() async {
    if (_isFilePickerOpen) return; // Prevent multiple clicks
    setState(() {
      _isFilePickerOpen =
          true; // Disable the button while the file picker is open
    });
    final result = await FilePicker.platform.pickFiles();
    setState(() {
      _isFilePickerOpen =
          false; // Re-enable the button once the file picker is closed
    });
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
      print(_selectedFile!.path.toString());
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
    // showTableDialog(context, providers);
  }

  void refreshApiCalls() {}

  // Api calls starts--->
  Future<void> _getProviders(fileId) async {
    try {
      final response = await Api.getProviders(fileId);
      if (response['success']) {
        // if(!mounted) return;
        setState(() {
          providers = List<Map<String, dynamic>>.from(response['data']);
        });
        print("providers $providers");
        showTableDialog(context, providers);
        setState(() {
          _downloadFileId = fileId;
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
        provideFile(destPath!.toString());
        Utils.showSuccessSnackBar(context, "File downloaded successfully");
      } else {
        Utils.showErrorSnackBar(context, "Download failed $response['error']");
      }
    } catch (e) {
      Utils.showErrorSnackBar(context, "Download failed");
      print('Error downloading: $e');
    }
    Navigator.of(context).pop();
  }

  Future<void> provideFile(filePath) async {
    try {
      final response = await Api.provideFile(filePath.toString());

      if (response['success']) {
        Utils.showSuccessSnackBar(context, "provided successfully");
        _refreshData();
      } else {
        Utils.showErrorSnackBar(
            context, "Failed to provide $response['error']");
        print(response['error']);
      }
    } catch (e) {
      Utils.showErrorSnackBar(context, "Failed to provide");
      print('Error providing: $e');
    }
  }

  Future<void> getProvidedFiles() async {
    try {
      final response = await Api.getProvidedFiles();
      if (mounted && response['success']) {
        // print(response['data']);
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
      // print(response);
      if (mounted && response['success']) {
        setState(() {
          downloadedList = List<Map<String, dynamic>>.from(response['data']);
          downloadedFilteredList =
              List<Map<String, dynamic>>.from(response['data']);
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
      print(fileId);
      print(permanent);
      final response = await Api.stopProviding(fileId, permanent: permanent);
      if (response['success']) {
        _refreshData();
        print(response);
      } else {
        print('Failed to stop providing.');
      }
    } catch (e) {
      print('Error while stopping provider: $e');
    }
  }

  Future<void> resumeProviding(String fileId) async {
    try {
      final response = await Api.resumeProviding(fileId);
      if (response['success']) {
        print(response);
        _refreshData();
      } else {
        print('Failed to resume providing.');
      }
    } catch (e) {
      print('Error while resuming provider: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 1, // Two tabs: Provide and Download
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          title: Text(
            'Files',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                ),
          ),
          backgroundColor: colorScheme.surface,
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
                  Container(
                    //padding: const EdgeInsets.all(8), // Space inside the border
                    child: Card(
                      // color: colorScheme.primary, // background color
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: colorScheme
                              .onBackground, // Set the border color (e.g., `onBackground` for a contrasting color)
                          width: 0.5, // Set the border width
                        ),
                        borderRadius: BorderRadius.circular(
                            12.0), // Set the border radius (optional for rounded corners)
                      ),
                      //shadowColor: const Color.fromARGB(255, 102, 70, 70), // Elevation for the shadow effect
                      child: Padding(
                        padding:
                            const EdgeInsets.all(30), // Padding inside the Card
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Download Files',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(color: colorScheme.onPrimary),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _controller,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: colorScheme
                                              .onPrimary, // Focused border color
                                          width:
                                              0.3, // Set the border width to 0.3
                                        ),
                                      ),
                                      labelText: 'Enter Hash of the File',
                                      labelStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary, // Label text color
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: colorScheme
                                              .onPrimary, // Focused border color
                                          width:
                                              0.3, // Set the border width to 0.3
                                        ),
                                      ),
                                      fillColor: Theme.of(context)
                                          .colorScheme
                                          .primary, // Background color
                                      filled:
                                          true, // Ensures the background color is applied
                                    ),
                                    cursorColor: colorScheme
                                        .onPrimary, // Set the cursor color explicitly
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton.icon(
                                  onPressed: _searchProviders,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme
                                        .onPrimary, // Set the background color
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 19.0,
                                        horizontal:
                                            16.0), // Increase vertical padding to make button taller
                                  ),
                                  icon: Icon(
                                    Icons.person_search,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary, // Set icon color
                                  ),
                                  label: Text(
                                    'Search',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary, // Set label text color
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: Card(
                      color: colorScheme.primary,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: colorScheme
                              .onBackground, // Set the border color (e.g., `onBackground` for a contrasting color)
                          width: 0.5, // Set the border width
                        ),
                        borderRadius: BorderRadius.circular(
                            12.0), // Set the border radius (optional for rounded corners)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Provided Files',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(color: colorScheme.onPrimary),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 2),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary, // Set the input text color to onSecondary
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Search Files',
                                      fillColor: Theme.of(context)
                                          .colorScheme
                                          .primary, // Background color
                                      filled: true,
                                      labelStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary, // Set label text color
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: colorScheme.onPrimary),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary, // Set icon color to onSecondary
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    cursorColor: colorScheme.onPrimary,
                                  ),
                                ),
                                const SizedBox(width: 40),

                                // Browse Button
                                ElevatedButton(
                                  onPressed: _pickFile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.onPrimary,
                                    padding: const EdgeInsets.all(20.0),
                                  ),
                                  child: Text(
                                    'Provide File',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary, // Set label text color to onPrimary
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                RotationTransition(
                                  turns: _iconcontroller,
                                  child: IconButton(
                                    icon: Icon(Icons.refresh,
                                        size: 30, color: colorScheme.onPrimary),
                                    onPressed: _refreshData,
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Sticky Header Row
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: colorScheme.onSecondary, width: 1),
                                  borderRadius: BorderRadius.circular(
                                      8), // Optional rounded corners
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey
                                                  .shade500), // Divider between rows
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                        color: const Color.fromARGB(
                                            255, 195, 219, 238),
                                      ),
                                      padding: const EdgeInsets.all(10.0),
                                      //color: const Color.fromARGB(255, 56, 118, 168), // Background color for header
                                      child: const Row(
                                        children: [
                                          Expanded(
                                              child: Text('File Name',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromARGB(
                                                          146, 0, 0, 0)))),
                                          Expanded(
                                              child: Text('File ID',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromARGB(
                                                          146, 0, 0, 0)))),
                                          Expanded(
                                              child: Text('Download Count',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromARGB(
                                                          146, 0, 0, 0)))),
                                          Expanded(
                                              child: Text('Action',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromARGB(
                                                          146, 0, 0, 0)))),
                                          Expanded(
                                              child: Text('Status',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromARGB(
                                                          146, 0, 0, 0)))),
                                        ],
                                      ),
                                    ),
                                    // Scrollable Data Rows
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children:
                                              providedFilteredList.isNotEmpty
                                                  ? providedFilteredList
                                                      .map(
                                                        (entry) => Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 8.0,
                                                                  horizontal:
                                                                      8.0),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300), // Divider between rows
                                                            ),
                                                          ),
                                                          // color: const Color.fromARGB(255, 56, 118, 168),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                  child: Text(
                                                                      entry['file_name'] ??
                                                                          '')),
                                                              Expanded(
                                                                child:
                                                                    MouseRegion(
                                                                  cursor:
                                                                      SystemMouseCursors
                                                                          .click,
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      Clipboard.setData(ClipboardData(
                                                                          text: entry['file_id'] ??
                                                                              ''));
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        const SnackBar(
                                                                            content:
                                                                                Text("File ID copied to clipboard")),
                                                                      );
                                                                    },
                                                                    child: Text(
                                                                      (entry['file_id'] ?? '').substring(
                                                                              0,
                                                                              10) +
                                                                          '...',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .onPrimary,
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
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    SizedBox(
                                                                      width:
                                                                          150, // Adjusted width to accommodate icons
                                                                      height:
                                                                          30,
                                                                      child:
                                                                          StatefulBuilder(
                                                                        builder:
                                                                            (context,
                                                                                setState) {
                                                                          bool
                                                                              isProviding =
                                                                              entry['is_providing'] ?? true; // Assuming initial state
                                                                          return Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: [
                                                                              IconButton(
                                                                                icon: Icon(
                                                                                  Icons.play_arrow,
                                                                                  size: 18,
                                                                                  color: entry['status'] == 1 ? Colors.green : Colors.grey,
                                                                                ),
                                                                                onPressed: () {
                                                                                  // ? null
                                                                                  // : () {
                                                                                  resumeProviding(entry['file_id']);
                                                                                  setState(() {
                                                                                    isProviding = true;
                                                                                    entry['is_providing'] = true;
                                                                                  });
                                                                                  // },
                                                                                },
                                                                                tooltip: 'Resume Providing',
                                                                              ),
                                                                              IconButton(
                                                                                icon: Icon(
                                                                                  Icons.pause,
                                                                                  size: 18,
                                                                                  color: entry['status'] == 0 ? Colors.red : Colors.grey,
                                                                                ),
                                                                                onPressed:
                                                                                    // !isProviding
                                                                                    //     ? null
                                                                                    // :
                                                                                    () {
                                                                                  stopProviding(entry['file_id'], false);
                                                                                  setState(() {
                                                                                    isProviding = false;
                                                                                    entry['is_providing'] = false;
                                                                                  });
                                                                                },
                                                                                tooltip: 'Stop Providing',
                                                                              ),
                                                                              IconButton(
                                                                                icon: const Icon(
                                                                                  Icons.delete,
                                                                                  size: 18,
                                                                                  color: Colors.black,
                                                                                ),
                                                                                onPressed: () {
                                                                                  _showStopProvidingDialog(providedFilteredList.indexOf(entry), entry['file_id']!, entry['file_name']);
                                                                                  print('Delete clicked for ${entry}');
                                                                                },
                                                                                tooltip: 'Delete',
                                                                              ),
                                                                            ],
                                                                          );
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      entry['status'] ==
                                                                              1
                                                                          ? 'Active'
                                                                          : 'Inactive',
                                                                      style:
                                                                          TextStyle(
                                                                        color: entry['status'] ==
                                                                                1
                                                                            ? Colors.green
                                                                            : Colors.red,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                      .toList()
                                                  : [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16.0),
                                                        alignment:
                                                            Alignment.center,
                                                        child: const Text(
                                                            'No files provided'),
                                                      ),
                                                    ],
                                        ),
                                      ),
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
          ],
        ),
      ),
    );
  }
}
