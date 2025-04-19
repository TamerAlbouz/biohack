import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/font.dart';
import 'package:medtalk/styles/sizes.dart';

import '../models/documents_models.dart';
import 'document_viewer_screen.dart';

class DocumentManagementScreen extends StatefulWidget {
  const DocumentManagementScreen({super.key});

  @override
  State<DocumentManagementScreen> createState() =>
      _DocumentManagementScreenState();
}

class _DocumentManagementScreenState extends State<DocumentManagementScreen> {
  final DocumentService _documentService = DocumentService();

  // Documents and folders
  List<DocumentFile> _documents = [];
  List<DocumentFile> _filteredDocuments = [];
  String _currentFolder = "All Documents";

  // Current folder navigation state
  final List<String> _navigationPath = ["All Documents"];

  // Search state
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Sorting and filtering options
  final String _sortBy = "Date (Newest)";

  // Upload progress
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeDocuments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Update the folder list to use the actual folders from DocumentService
  Widget _buildFoldersList() {
    final folderList = _documentService.folders;
    final folderCounts = _documentService.getFolderCounts();

    return ListView.builder(
      itemCount: folderList.length,
      itemBuilder: (context, index) {
        final folder = folderList[index];
        final count = folderCounts[folder.name] ?? 0;

        return _buildFolderItem(
          folder.name,
          count,
          // You might want to add a 'lastUpdated' property to the DocumentFolder model
          // For now, let's just use a placeholder
          "Recent",
        );
      },
    );
  }

// Update the document list to use actual documents from DocumentService
  Widget _buildDocumentsList() {
    if (_filteredDocuments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: MyColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                FontAwesomeIcons.folderOpen,
                size: 50,
                color: MyColors.primary.withValues(alpha: 1),
              ),
            ),
            kGap16,
            Text(
              "No documents in this folder",
              style: TextStyle(
                fontSize: Font.medium,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredDocuments.length,
      itemBuilder: (context, index) {
        final document = _filteredDocuments[index];
        return _buildDocumentItem(
          document.name,
          document.formattedDate,
          document.icon,
          document.id,
        );
      },
    );
  }

// Update the document item to display actual document data
  Widget _buildDocumentItem(
      String name, String date, IconData icon, String id) {
    final document = _filteredDocuments.firstWhere((doc) => doc.id == id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _handleDocumentAction('view', id),
        child: Row(
          children: [
            Container(
              width: 95,
              height: 95,
              decoration: const BoxDecoration(
                  color: MyColors.cardBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  )),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      icon,
                      color: document.color,
                      size: 34,
                    ),
                  ],
                ),
              ),
            ),
            kGap8,
            Expanded(
              child: Container(
                height: 95,
                decoration: const BoxDecoration(
                  color: MyColors.cardBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Last modified: $date",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            document.formattedSize,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () => _handleDocumentAction('download', id),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeDocuments() async {
    try {
      await _documentService.initialize();
      setState(() {
        _documents = _documentService.documents;
        _filteredDocuments = _documents; // Initially show all documents
      });
      // Apply initial sorting
      _sortDocuments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing documents: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Sort documents based on the selected option
  void _sortDocuments() {
    setState(() {
      _filteredDocuments =
          _documentService.sortDocuments(_filteredDocuments, _sortBy);
    });
  }

  // Search documents
  void _searchDocuments(String query) {
    setState(() {
      _filteredDocuments =
          _documentService.searchDocuments(query, folder: _currentFolder);
      // Apply current sorting
      _filteredDocuments =
          _documentService.sortDocuments(_filteredDocuments, _sortBy);
    });
  }

  // Update search functionality
  @override
  void didUpdateWidget(DocumentManagementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If search text changes, filter documents
    if (_isSearching && _searchController.text.isNotEmpty) {
      _searchDocuments(_searchController.text);
    }
  }

  // Pick file and upload
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;

        // Set up progress tracking
        setState(() {
          _isUploading = true;
          _uploadProgress = 0.0;
        });

        // Use StatefulBuilder to show a dialog that can update itself
        StateSetter? dialogState;

        // Show the dialog
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (context, setDialogState) {
                  // Save the dialog's setState function
                  dialogState = setDialogState;

                  return Dialog.fullscreen(
                    backgroundColor: Colors.black.withValues(alpha: 0.3),
                    child: Center(
                      child: Container(
                        width: 200,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              value: _uploadProgress,
                              valueColor: const AlwaysStoppedAnimation(
                                  MyColors.primary),
                            ),
                            kGap16,
                            Text(
                              'Uploading...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            kGap8,
                            Text(
                              '${(_uploadProgress * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        }

        // Simulate upload progress
        for (var i = 0; i < 10; i++) {
          await Future.delayed(const Duration(milliseconds: 300));

          // Update both the main widget state and dialog state
          setState(() {
            _uploadProgress = (i + 1) / 10;
          });

          // Update the dialog's state without rebuilding the entire dialog
          dialogState?.call(() {});
        }

        // Close the dialog when done
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        // The rest of your code remains the same
        await _documentService.addDocument(file, _currentFolder);
        setState(() {
          _documents = _documentService.documents;
          _filteredDocuments =
              _documentService.getDocumentsByFolder(_currentFolder);
          _isUploading = false;
        });
        _sortDocuments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$fileName uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      // Close dialog if there's an error
      if (_isUploading && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      setState(() {
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Handle document actions
  Future<void> _handleDocumentAction(String action, String documentId) async {
    final document = _filteredDocuments.firstWhere(
      (doc) => doc.id == documentId,
      orElse: () => throw Exception('Document not found'),
    );

    switch (action) {
      case 'download':
        _simulateDownload(document.name);
        break;
      case 'view':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DocumentViewerScreen(documentId: document.id),
          ),
        );
        break;
    }
  }

  void _simulateDownload(String fileName) {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _uploadProgress = 0.3;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _uploadProgress = 0.6;
        });

        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _uploadProgress = 1.0;
          });

          Future.delayed(const Duration(milliseconds: 300), () {
            setState(() {
              _isUploading = false;
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$fileName downloaded successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          });
        });
      });
    });
  }

  // Update the navigate method to refresh documents when changing folders
  void _navigateToFolder(String folderName) {
    setState(() {
      _currentFolder = folderName;
      _navigationPath.add(folderName);

      // Get documents for this folder
      _filteredDocuments = _documentService.getDocumentsByFolder(folderName);

      // Apply current sorting
      _sortDocuments();
    });
  }

  void _navigateBack() {
    if (_navigationPath.length > 1) {
      setState(() {
        _navigationPath.removeLast();
        _currentFolder = _navigationPath.last;
        // Refresh the documents for the current folder
        _filteredDocuments =
            _documentService.getDocumentsByFolder(_currentFolder);
        // Apply current sorting
        _sortDocuments();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 50,
        titleSpacing: _navigationPath.length > 1 ? 0 : 20,
        // leadingWidth: 0,
        title: Text(
          _navigationPath.length > 1 ? _currentFolder : "Documents",
          style: const TextStyle(
            color: Colors.black,
            fontSize: Font.medium,
            fontWeight: FontWeight.bold,
          ),
        ),

        leading: _navigationPath.length > 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: _navigateBack,
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search,
                color: Colors.black),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _isSearching
              ? TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: "Search documents...",
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onChanged: _searchDocuments,
                  autofocus: true,
                )
              : const SizedBox(),
          Padding(
            padding: EdgeInsets.only(
                top: _isSearching ? 40 : 6, left: 20, right: 20),
            child: _navigationPath.length == 1
                ? _buildFoldersList()
                : _buildDocumentsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickFile,
        backgroundColor: MyColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload_file),
        label: const Text(
          "Upload",
          style: TextStyle(
            fontSize: Font.medium,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFolderItem(String name, int count, String lastUpdated) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToFolder(name),
        child: Row(
          children: [
            Container(
              width: 95,
              height: 95,
              decoration: const BoxDecoration(
                color: MyColors.cardBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.folder,
                  color: MyColors.primary,
                  size: 40,
                ),
              ),
            ),
            kGap8,
            Expanded(
              child: Container(
                height: 95,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: MyColors.cardBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Last Updated: $lastUpdated",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "$count items",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _handleDocumentAction('view', name),
                      child: Icon(
                        Icons.more_horiz,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
