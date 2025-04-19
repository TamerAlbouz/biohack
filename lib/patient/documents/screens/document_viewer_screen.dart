import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/font.dart';
import 'package:medtalk/styles/sizes.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/documents_models.dart';

class DocumentViewerScreen extends StatefulWidget {
  final String documentId;

  const DocumentViewerScreen({
    super.key,
    required this.documentId,
  });

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  final DocumentService _documentService = DocumentService();
  late DocumentFile _document;
  bool _isLoading = true;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    try {
      await _documentService.initialize();
      final document = _documentService.documents.firstWhere(
        (doc) => doc.id == widget.documentId,
        orElse: () => throw Exception('Document not found'),
      );

      setState(() {
        _document = document;
        _isLoading = false;
      });
    } catch (e) {
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

  Future<void> _handleDownload() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    // Show progress dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
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
                          value: _downloadProgress,
                          valueColor:
                              const AlwaysStoppedAnimation(MyColors.primary),
                        ),
                        kGap16,
                        Text(
                          'Downloading...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        kGap8,
                        Text(
                          '${(_downloadProgress * 100).toInt()}%',
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

    // Simulate download progress
    for (var i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _downloadProgress = (i + 1) / 10;
      });
    }

    // Close the dialog when done
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();

      setState(() {
        _isDownloading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_document.name} downloaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleShare() async {
    try {
      // Simulate creating a temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${_document.name}');

      // Share the file
      final xFile = XFile(file.path);
      await Share.shareXFiles([xFile], text: 'Sharing ${_document.name}');
    } catch (e) {
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

  Future<void> _handleDelete() async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete ${_document.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await _documentService.deleteDocument(_document.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_document.name} deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
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
  }

  Widget _buildDocumentContent() {
    // Determine document type and display appropriate viewer
    if (_document.name.endsWith('.pdf')) {
      return _buildPdfViewer();
    } else if (_document.name.endsWith('.jpg') ||
        _document.name.endsWith('.jpeg') ||
        _document.name.endsWith('.png') ||
        _document.name.endsWith('.gif')) {
      return _buildImageViewer();
    } else if (_document.name.endsWith('.txt') ||
        _document.name.endsWith('.md') ||
        _document.name.endsWith('.json') ||
        _document.name.endsWith('.csv')) {
      return _buildTextViewer();
    } else if (_document.name.endsWith('.html') ||
        _document.name.endsWith('.htm')) {
      return _buildHtmlViewer();
    } else {
      return _buildGenericViewer();
    }
  }

  Widget _buildHtmlViewer() {
    final filePath = '/tmp/${_document.id}.html';
    final file = File(filePath);

    // In a real app, you would load the HTML from your storage service
    return FutureBuilder<bool>(
      // This would be an actual file check in a real app
      future: Future.value(false), // Simulate file not yet ready
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(MyColors.primary),
            ),
          );
        }

        // If we have the HTML file (in a real app)
        if (snapshot.hasData && snapshot.data == true && file.existsSync()) {
          final controller = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..loadFile(filePath);

          return WebViewWidget(controller: controller);
        }

        // Fallback UI when the HTML file isn't available yet
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                FontAwesomeIcons.fileCode,
                color: Colors.orange,
                size: 100,
              ),
              kGap16,
              Text(
                'HTML Document',
                style: TextStyle(
                  fontSize: Font.large,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              kGap8,
              Text(
                'Viewing ${_document.name}',
                style: TextStyle(
                  fontSize: Font.medium,
                  color: Colors.grey[600],
                ),
              ),
              kGap24,
              ElevatedButton.icon(
                onPressed: _handleDownload,
                icon: const Icon(Icons.download),
                label: const Text('Download to view'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPdfViewer() {
    // Create a temporary file path for the PDF
    final filePath =
        '/tmp/${_document.id}.pdf'; // This would be the actual path in a real app

    // In a real app, you would load the PDF from your storage service
    // For this example, we'll show both the placeholder and the PDF viewer UI

    return FutureBuilder<bool>(
      // This would be an actual file check in a real app
      future: Future.value(false), // Simulate file not yet ready
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(MyColors.primary),
            ),
          );
        }

        // If we have the file path (in a real app)
        if (snapshot.hasData && snapshot.data == true) {
          return Column(
            children: [
              Expanded(
                child: PDFView(
                  filePath: filePath,
                  enableSwipe: true,
                  swipeHorizontal: true,
                  autoSpacing: false,
                  pageFling: false,
                  pageSnap: true,
                  defaultPage: 0,
                  fitPolicy: FitPolicy.BOTH,
                  preventLinkNavigation: false,
                  onRender: (int? _pages) {
                    setState(() {
                      // Update page count or other UI elements if needed
                    });
                  },
                  onError: (error) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error loading PDF: $error'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  onPageError: (page, error) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error on page $page: $error'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  onViewCreated: (PDFViewController pdfViewController) {
                    // You could store the controller for later use
                  },
                ),
              ),
            ],
          );
        }

        // Fallback UI when the file isn't available yet
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                FontAwesomeIcons.filePdf,
                color: Colors.red,
                size: 100,
              ),
              kGap16,
              Text(
                'PDF Document',
                style: TextStyle(
                  fontSize: Font.large,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              kGap8,
              Text(
                'Viewing ${_document.name}',
                style: TextStyle(
                  fontSize: Font.medium,
                  color: Colors.grey[600],
                ),
              ),
              kGap24,
              ElevatedButton.icon(
                onPressed: _handleDownload,
                icon: const Icon(Icons.download),
                label: const Text('Download to view'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageViewer() {
    // Create a file reference for the image
    final filePath =
        '/tmp/${_document.id}${_document.name.substring(_document.name.lastIndexOf('.'))}';
    final file = File(filePath);

    // In a real app, you would load the image from your storage service
    return FutureBuilder<bool>(
      // This would be an actual file check in a real app
      future: Future.value(false), // Simulate file not yet ready
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(MyColors.primary),
            ),
          );
        }

        // If we have the image file (in a real app)
        if (snapshot.hasData && snapshot.data == true && file.existsSync()) {
          return Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width,
                maxHeight: MediaQuery.of(context).size.height,
              ),
              child: PhotoView(
                imageProvider: FileImage(file),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                backgroundDecoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                loadingBuilder: (context, event) => Center(
                  child: CircularProgressIndicator(
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded /
                            (event.expectedTotalBytes ?? 1),
                    valueColor: const AlwaysStoppedAnimation(MyColors.primary),
                  ),
                ),
              ),
            ),
          );
        }

        // Fallback UI when the image isn't available yet
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  FontAwesomeIcons.image,
                  color: Colors.blue,
                  size: 100,
                ),
              ),
              kGap16,
              Text(
                'Image Viewer',
                style: TextStyle(
                  fontSize: Font.large,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              kGap8,
              Text(
                'Viewing ${_document.name}',
                style: TextStyle(
                  fontSize: Font.medium,
                  color: Colors.grey[600],
                ),
              ),
              kGap24,
              ElevatedButton.icon(
                onPressed: _handleDownload,
                icon: const Icon(Icons.download),
                label: const Text('Download to view'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextViewer() {
    final filePath =
        '/tmp/${_document.id}${_document.name.substring(_document.name.lastIndexOf('.'))}';
    final file = File(filePath);

    // In a real app, you would load the text from your storage service
    return FutureBuilder<bool>(
      // This would be an actual file check in a real app
      future: Future.value(false), // Simulate file not yet ready
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(MyColors.primary),
            ),
          );
        }

        // If we have the text file (in a real app)
        if (snapshot.hasData && snapshot.data == true && file.existsSync()) {
          final content = file.readAsStringSync();

          if (_document.name.endsWith('.md')) {
            // For Markdown files
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Markdown Document: ${_document.name}',
                    style: TextStyle(
                      fontSize: Font.large,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  kGap16,
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Markdown(
                        data: content,
                        styleSheet: MarkdownStyleSheet(
                          h1: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800]),
                          h2: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800]),
                          h3: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800]),
                          p: TextStyle(
                              fontSize: Font.medium,
                              color: Colors.grey[800],
                              height: 1.5),
                          code: TextStyle(
                              fontFamily: 'monospace',
                              backgroundColor: Colors.grey[200]),
                        ),
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // For plain text files
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Text Document: ${_document.name}',
                    style: TextStyle(
                      fontSize: Font.large,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  kGap16,
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: Text(
                          content,
                          style: TextStyle(
                            fontSize: Font.medium,
                            color: Colors.grey[800],
                            height: 1.5,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        }

        // Fallback UI when the text isn't available yet
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Text Document: ${_document.name}',
                style: TextStyle(
                  fontSize: Font.large,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              kGap16,
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Text(
                      'This is a sample text content. In a real application, the actual content of ${_document.name} would be displayed here. The document was last modified on ${_document.formattedDate} and has a size of ${_document.formattedSize}.',
                      style: TextStyle(
                        fontSize: Font.medium,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                    kGap24,
                    ElevatedButton.icon(
                      onPressed: _handleDownload,
                      icon: const Icon(Icons.download),
                      label: const Text('Download to view'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGenericViewer() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _document.icon,
              color: _document.color,
              size: 60,
            ),
          ),
          kGap16,
          Text(
            _document.name,
            style: TextStyle(
              fontSize: Font.large,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          kGap8,
          Text(
            'Last modified: ${_document.formattedDate}',
            style: TextStyle(
              fontSize: Font.medium,
              color: Colors.grey[600],
            ),
          ),
          Text(
            'Size: ${_document.formattedSize}',
            style: TextStyle(
              fontSize: Font.medium,
              color: Colors.grey[600],
            ),
          ),
          kGap24,
          Text(
            'This file type cannot be previewed directly.',
            style: TextStyle(
              fontSize: Font.medium,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          kGap16,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _handleDownload,
                icon: const Icon(Icons.download),
                label: const Text('Download'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              kGap16,
              ElevatedButton.icon(
                onPressed: () => _openWithNativeApp(),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open With'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openWithNativeApp() async {
    try {
      // In a real app, you'd first ensure the file is downloaded
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0.0;
      });

      // Simulate download
      for (var i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {
          _downloadProgress = (i + 1) / 10;
        });
      }

      // Get temp directory and create a local file
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${_document.name}';

      // In a real app, here you would write the document content to the file

      // Open the file with the default app
      final result = await OpenFile.open(filePath);

      setState(() {
        _isDownloading = false;
      });

      if (result.type != ResultType.done) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open file: ${result.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: _isLoading
            ? const Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: Font.medium,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Text(
                _document.name,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: Font.medium,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
        actions: [
          if (!_isLoading) ...[
            IconButton(
              icon: const Icon(Icons.download, color: Colors.black),
              onPressed: _handleDownload,
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.black),
              onPressed: _handleShare,
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onSelected: (value) {
                if (value == 'delete') {
                  _handleDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(MyColors.primary),
              ),
            )
          : _buildDocumentContent(),
    );
  }
}
