import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/sizes.dart';
import 'package:medtalk/styles/styles/text.dart';
import 'package:share_plus/share_plus.dart';

import '../../../common/widgets/base/custom_base.dart';
import '../../../styles/font.dart';

class DocumentManagementScreen extends StatefulWidget {
  const DocumentManagementScreen({super.key});

  @override
  State<DocumentManagementScreen> createState() =>
      _DocumentManagementScreenState();
}

class _DocumentManagementScreenState extends State<DocumentManagementScreen> {
  // View mode (grid or list)
  bool _isGridView = true;

  // Current folder navigation state
  String _currentFolder = "All Documents";
  List<String> _navigationPath = ["All Documents"];

  // Search state
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Sorting options
  String _sortBy = "Date (Newest)";
  final List<String> _sortOptions = [
    "Date (Newest)",
    "Date (Oldest)",
    "Name (A-Z)",
    "Name (Z-A)",
    "Size (Largest)",
    "Size (Smallest)",
  ];

  // Upload progress
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        titleSpacing: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: "Search documents...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: Font.mediumSmall,
                    color: Colors.grey,
                  ),
                ),
                style: const TextStyle(
                  fontSize: Font.mediumSmall,
                  color: Colors.black,
                ),
                autofocus: true,
                onChanged: (value) {
                  // Implement search functionality
                  setState(() {});
                },
              )
            : const Text("Document Management", style: kSectionTitle),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) {
              return _sortOptions.map((option) {
                return PopupMenuItem<String>(
                  value: option,
                  child: Row(
                    children: [
                      Icon(
                        option == _sortBy
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color:
                            option == _sortBy ? MyColors.primary : Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(option),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: kRadius10,
              color: MyColors.cardBackground,
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (int i = 0; i < _navigationPath.length; i++)
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (i < _navigationPath.length - 1) {
                              _navigationPath =
                                  _navigationPath.sublist(0, i + 1);
                              _currentFolder = _navigationPath.last;
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 4),
                          child: Text(
                            _navigationPath[i],
                            style: TextStyle(
                              color: i == _navigationPath.length - 1
                                  ? MyColors.primary
                                  : Colors.grey[600],
                              fontWeight: i == _navigationPath.length - 1
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: Font.mediumSmall,
                            ),
                          ),
                        ),
                      ),
                      if (i < _navigationPath.length - 1)
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: Colors.grey,
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: kPaddT15,
            child: _buildBody(),
          ),
          if (_isUploading) _buildUploadingIndicator(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_currentFolder == "All Documents") {
      return _buildFolderGrid();
    } else {
      return _buildDocumentsList();
    }
  }

  Widget _buildFolderGrid() {
    // Main folders
    final folders = [
      {
        'name': 'Medical Records',
        'icon': FontAwesomeIcons.fileMedical,
        'color': Colors.blue,
        'count': 12,
      },
      {
        'name': 'Lab Reports',
        'icon': FontAwesomeIcons.vial,
        'color': Colors.purple,
        'count': 8,
      },
      {
        'name': 'Prescriptions',
        'icon': FontAwesomeIcons.prescription,
        'color': Colors.green,
        'count': 5,
      },
      {
        'name': 'Insurance',
        'icon': FontAwesomeIcons.shieldHalved,
        'color': Colors.orange,
        'count': 3,
      },
      {
        'name': 'Appointment Notes',
        'icon': FontAwesomeIcons.notesMedical,
        'color': Colors.red,
        'count': 7,
      },
      {
        'name': 'Imaging',
        'icon': FontAwesomeIcons.xRay,
        'color': Colors.teal,
        'count': 4,
      },
      {
        'name': 'Others',
        'icon': FontAwesomeIcons.folderOpen,
        'color': Colors.grey,
        'count': 2,
      },
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent documents section
          const Text(
            "Recent Documents",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          kGap16,
          SizedBox(
            height: 180,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildRecentDocumentCard(
                  "Blood Test Results.pdf",
                  "Lab Reports",
                  "2.4 MB",
                  "Today",
                  Colors.purple,
                  FontAwesomeIcons.filePdf,
                ),
                _buildRecentDocumentCard(
                  "X-Ray Scan.jpg",
                  "Imaging",
                  "5.8 MB",
                  "Yesterday",
                  Colors.teal,
                  FontAwesomeIcons.fileImage,
                ),
                _buildRecentDocumentCard(
                  "Antibiotic Prescription.pdf",
                  "Prescriptions",
                  "1.1 MB",
                  "2 days ago",
                  Colors.green,
                  FontAwesomeIcons.filePdf,
                ),
                _buildRecentDocumentCard(
                  "Annual Physical Report.docx",
                  "Medical Records",
                  "3.2 MB",
                  "1 week ago",
                  Colors.blue,
                  FontAwesomeIcons.fileWord,
                ),
              ],
            ),
          ),

          kGap24,

          // Folders section
          const Text(
            "Folders",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          kGap16,

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
            ),
            itemCount: folders.length,
            itemBuilder: (context, index) {
              return _buildFolderCard(
                folders[index]['name'] as String,
                folders[index]['count'] as int,
                folders[index]['icon'] as IconData,
                folders[index]['color'] as Color,
              );
            },
          ),

          kGap24,
        ],
      ),
    );
  }

  Widget _buildDocumentsList() {
    // Sample documents based on current folder
    final List<Map<String, dynamic>> documents =
        _getDocumentsForFolder(_currentFolder);

    if (documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.folderOpen,
              size: 64,
              color: Colors.grey[300],
            ),
            kGap16,
            Text(
              "No documents in this folder",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            kGap8,
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.add),
              label: const Text("Upload Document"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: MyColors.primary,
              ),
            ),
          ],
        ),
      );
    }

    if (_isGridView) {
      return GridView.builder(
        padding: kPadd16,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: documents.length,
        itemBuilder: (context, index) {
          final doc = documents[index];
          return _buildDocumentGridItem(
            doc['name'] as String,
            doc['size'] as String,
            doc['date'] as String,
            doc['icon'] as IconData,
            doc['color'] as Color,
          );
        },
      );
    } else {
      return ListView.separated(
        padding: kPadd16,
        itemCount: documents.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final doc = documents[index];
          return _buildDocumentListItem(
            doc['name'] as String,
            doc['size'] as String,
            doc['date'] as String,
            doc['icon'] as IconData,
            doc['color'] as Color,
          );
        },
      );
    }
  }

  Widget _buildFolderCard(String name, int count, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        setState(() {
          _currentFolder = name;
          _navigationPath.add(name);
        });
      },
      borderRadius: kRadius16,
      child: CustomBase(
        shadow: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: FaIcon(
                      icon,
                      color: color,
                      size: 18,
                    ),
                  ),
                ),
                kGap8,
                Text(
                  "$count",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            kGap4,
            Text(
              "$count files",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentDocumentCard(String name, String folder, String size,
      String date, Color color, IconData icon) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: MyColors.cardBackground,
        borderRadius: kRadius16,
      ),
      child: InkWell(
        onTap: () => _showDocumentOptions(name, folder),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: FaIcon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  kGap4,
                  Text(
                    "$size • $date",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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

  Widget _buildDocumentGridItem(
      String name, String size, String date, IconData icon, Color color) {
    return InkWell(
      onTap: () => _showDocumentOptions(name, _currentFolder),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: FaIcon(
                  icon,
                  color: color,
                  size: 36,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  kGap4,
                  Text(
                    "$size • $date",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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

  Widget _buildDocumentListItem(
      String name, String size, String date, IconData icon, Color color) {
    return ListTile(
      onTap: () => _showDocumentOptions(name, _currentFolder),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: FaIcon(
            icon,
            color: color,
            size: 20,
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        "$size • $date",
        style: TextStyle(
          color: Colors.grey[600],
        ),
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) => _handleDocumentAction(value, name),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'preview',
            child: Row(
              children: [
                Icon(Icons.visibility, size: 20),
                SizedBox(width: 8),
                Text('Preview'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'download',
            child: Row(
              children: [
                Icon(Icons.download, size: 20),
                SizedBox(width: 8),
                Text('Download'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'share',
            child: Row(
              children: [
                Icon(Icons.share, size: 20),
                SizedBox(width: 8),
                Text('Share'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'rename',
            child: Row(
              children: [
                Icon(Icons.edit, size: 20),
                SizedBox(width: 8),
                Text('Rename'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'move',
            child: Row(
              children: [
                Icon(Icons.drive_file_move, size: 20),
                SizedBox(width: 8),
                Text('Move'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadingIndicator() {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
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
                valueColor:
                    const AlwaysStoppedAnimation<Color>(MyColors.primary),
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
  }

  void _showDocumentOptions(String documentName, String folder) {
    showModalBottomSheet(
      context: context,
      backgroundColor: MyColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: kPadd20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              kGap20,
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getColorForDocument(documentName)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: FaIcon(
                        _getIconForDocument(documentName),
                        color: _getColorForDocument(documentName),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          documentName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "In folder: $folder",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              kGap30,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.visibility,
                    label: 'Preview',
                    onTap: () {
                      Navigator.pop(context);
                      _handleDocumentAction('preview', documentName);
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.download,
                    label: 'Download',
                    onTap: () {
                      Navigator.pop(context);
                      _handleDocumentAction('download', documentName);
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.share,
                    label: 'Share',
                    onTap: () {
                      Navigator.pop(context);
                      _handleDocumentAction('share', documentName);
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.edit,
                    label: 'Rename',
                    onTap: () {
                      Navigator.pop(context);
                      _handleDocumentAction('rename', documentName);
                    },
                  ),
                ],
              ),
              kGap20,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.drive_file_move,
                    label: 'Move',
                    onTap: () {
                      Navigator.pop(context);
                      _handleDocumentAction('move', documentName);
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.star_border,
                    label: 'Favorite',
                    onTap: () {
                      Navigator.pop(context);
                      // Handle favorite
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.info_outline,
                    label: 'Details',
                    onTap: () {
                      Navigator.pop(context);
                      _showDocumentDetails(documentName);
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.delete,
                    label: 'Delete',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _handleDocumentAction('delete', documentName);
                    },
                  ),
                ],
              ),
              kGap20,
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 70,
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: (color ?? MyColors.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color ?? MyColors.primary,
                size: 24,
              ),
            ),
            kGap8,
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color ?? Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showDocumentDetails(String documentName) {
    final fileDetails = {
      'name': documentName,
      'size': '2.4 MB',
      'type': documentName.split('.').last.toUpperCase(),
      'shared': '15 Mar 2023, 10:30 AM',
      'folder': _currentFolder,
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Document Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getColorForDocument(documentName)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: FaIcon(
                        _getIconForDocument(documentName),
                        color: _getColorForDocument(documentName),
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      documentName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Font.small,
                      ),
                    ),
                  ),
                ],
              ),
              kGap20,
              ...fileDetails.entries.map((entry) {
                if (entry.key == 'name') return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          '${entry.key.substring(0, 1).toUpperCase()}${entry.key.substring(1)}:',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: Font.small,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: Font.small,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _handleDocumentAction(String action, String documentName) {
    switch (action) {
      case 'preview':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening $documentName')),
        );
        // Open document preview
        break;
      case 'download':
        _simulateDownload(documentName);
        break;
      case 'share':
        Share.share('Check out this document: $documentName');
        break;
      case 'rename':
        _showRenameDialog(documentName);
        break;
      case 'move':
        _showMoveDialog(documentName);
        break;
      case 'delete':
        _showDeleteConfirmation(documentName);
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

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$fileName downloaded successfully'),
                backgroundColor: Colors.green,
              ),
            );
          });
        });
      });
    });
  }

  void _showRenameDialog(String currentName) {
    final TextEditingController controller =
        TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Document'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'New name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Renamed to ${controller.text}')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  void _showMoveDialog(String documentName) {
    final folders = [
      'Medical Records',
      'Lab Reports',
      'Prescriptions',
      'Insurance',
      'Appointment Notes',
      'Imaging',
      'Others',
    ];

    String selectedFolder = folders[0];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Move Document'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      documentName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    kGap4,
                    Text(
                      'Current folder: $_currentFolder',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    kGap16,
                    const Text('Select destination folder:'),
                    kGap8,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedFolder,
                          items: folders.map((folder) {
                            return DropdownMenuItem<String>(
                              value: folder,
                              child: Text(folder),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedFolder = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Moved to $selectedFolder')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Move'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(String documentName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Document'),
          content: Text('Are you sure you want to delete "$documentName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Document deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        setState(() {
          _isUploading = true;
          _uploadProgress = 0.0;
        });

        // Simulate upload progress
        for (var i = 0; i <= 10; i++) {
          await Future.delayed(const Duration(milliseconds: 300));
          setState(() {
            _uploadProgress = i / 10;
          });
        }

        setState(() {
          _isUploading = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.files.single.name} uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper function to get documents based on folder
  List<Map<String, dynamic>> _getDocumentsForFolder(String folder) {
    switch (folder) {
      case 'Medical Records':
        return [
          {
            'name': 'Annual Physical Report.pdf',
            'size': '3.2 MB',
            'date': 'March 15, 2023',
            'icon': FontAwesomeIcons.filePdf,
            'color': Colors.red,
          },
          {
            'name': 'Medical History Summary.docx',
            'size': '1.8 MB',
            'date': 'February 10, 2023',
            'icon': FontAwesomeIcons.fileWord,
            'color': Colors.blue,
          },
          {
            'name': 'Vaccination Record.pdf',
            'size': '1.5 MB',
            'date': 'January 5, 2023',
            'icon': FontAwesomeIcons.filePdf,
            'color': Colors.red,
          },
        ];
      case 'Lab Reports':
        return [
          {
            'name': 'Blood Test Results.pdf',
            'size': '2.4 MB',
            'date': 'April 1, 2023',
            'icon': FontAwesomeIcons.filePdf,
            'color': Colors.red,
          },
          {
            'name': 'Cholesterol Panel.pdf',
            'size': '1.6 MB',
            'date': 'March 22, 2023',
            'icon': FontAwesomeIcons.filePdf,
            'color': Colors.red,
          },
          {
            'name': 'Thyroid Function Test.xlsx',
            'size': '0.9 MB',
            'date': 'February 15, 2023',
            'icon': FontAwesomeIcons.fileExcel,
            'color': Colors.green,
          },
        ];
      case 'Prescriptions':
        return [
          {
            'name': 'Antibiotic Prescription.pdf',
            'size': '1.1 MB',
            'date': 'April 5, 2023',
            'icon': FontAwesomeIcons.filePdf,
            'color': Colors.red,
          },
          {
            'name': 'Pain Medication.pdf',
            'size': '0.8 MB',
            'date': 'March 18, 2023',
            'icon': FontAwesomeIcons.filePdf,
            'color': Colors.red,
          },
        ];
      case 'Insurance':
        return [
          {
            'name': 'Health Insurance Policy.pdf',
            'size': '4.5 MB',
            'date': 'January 10, 2023',
            'icon': FontAwesomeIcons.filePdf,
            'color': Colors.red,
          },
          {
            'name': 'Insurance Claim Form.pdf',
            'size': '1.2 MB',
            'date': 'March 5, 2023',
            'icon': FontAwesomeIcons.filePdf,
            'color': Colors.red,
          },
        ];
      case 'Appointment Notes':
        return [
          {
            'name': 'Cardiologist Consultation.docx',
            'size': '1.7 MB',
            'date': 'April 10, 2023',
            'icon': FontAwesomeIcons.fileWord,
            'color': Colors.blue,
          },
          {
            'name': 'Dermatology Visit.docx',
            'size': '1.3 MB',
            'date': 'March 25, 2023',
            'icon': FontAwesomeIcons.fileWord,
            'color': Colors.blue,
          },
          {
            'name': 'Orthopedic Follow-up.pdf',
            'size': '2.1 MB',
            'date': 'February 20, 2023',
            'icon': FontAwesomeIcons.filePdf,
            'color': Colors.red,
          },
        ];
      case 'Imaging':
        return [
          {
            'name': 'X-Ray Scan.jpg',
            'size': '5.8 MB',
            'date': 'April 2, 2023',
            'icon': FontAwesomeIcons.fileImage,
            'color': Colors.purple,
          },
          {
            'name': 'MRI Results.jpg',
            'size': '7.2 MB',
            'date': 'March 1, 2023',
            'icon': FontAwesomeIcons.fileImage,
            'color': Colors.purple,
          },
          {
            'name': 'CT Scan Report.pdf',
            'size': '3.5 MB',
            'date': 'February 5, 2023',
            'icon': FontAwesomeIcons.filePdf,
            'color': Colors.red,
          },
        ];
      case 'Others':
        return [
          {
            'name': 'Diet Plan.pdf',
            'size': '1.2 MB',
            'date': 'March 20, 2023',
            'icon': FontAwesomeIcons.filePdf,
            'color': Colors.red,
          },
          {
            'name': 'Exercise Routine.docx',
            'size': '0.9 MB',
            'date': 'February 28, 2023',
            'icon': FontAwesomeIcons.fileWord,
            'color': Colors.blue,
          },
        ];
      default:
        return [];
    }
  }

  IconData _getIconForDocument(String name) {
    final extension = name.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return FontAwesomeIcons.filePdf;
      case 'doc':
      case 'docx':
        return FontAwesomeIcons.fileWord;
      case 'xls':
      case 'xlsx':
        return FontAwesomeIcons.fileExcel;
      case 'ppt':
      case 'pptx':
        return FontAwesomeIcons.filePowerpoint;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return FontAwesomeIcons.fileImage;
      case 'txt':
        return FontAwesomeIcons.fileLines;
      default:
        return FontAwesomeIcons.file;
    }
  }

  Color _getColorForDocument(String name) {
    final extension = name.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.purple;
      case 'txt':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
