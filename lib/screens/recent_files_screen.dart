import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rtf_view/constants/colors.dart';
import 'package:rtf_view/models/rtf_file.dart';
import 'package:rtf_view/screens/document_viewer_screen.dart';
import 'package:rtf_view/services/rtf_provider.dart';

class RecentFilesScreen extends StatefulWidget {
  const RecentFilesScreen({super.key});

  @override
  State<RecentFilesScreen> createState() => _RecentFilesScreenState();
}

class _RecentFilesScreenState extends State<RecentFilesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load recent files when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RtfProvider>(context, listen: false).loadRecentFiles();
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Files'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search File Name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          
          // File list
          Expanded(
            child: Consumer<RtfProvider>(
              builder: (context, rtfProvider, child) {
                if (rtfProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (rtfProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading recent files',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(rtfProvider.error!),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => rtfProvider.loadRecentFiles(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredFiles = rtfProvider.recentFiles
                    .where((file) => file.name.toLowerCase().contains(_searchQuery))
                    .toList();

                if (filteredFiles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.folder_open,
                          color: Colors.grey,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No recent files'
                              : 'No files match "$_searchQuery"',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredFiles.length,
                  itemBuilder: (context, index) {
                    final file = filteredFiles[index];
                    return _buildFileItem(context, file);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(BuildContext context, RtfFile file) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.rtfIconBackground,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Text(
              'RTF',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        title: Text(
          file.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(file.formattedSize),
        trailing: IconButton(
          icon: const Icon(Icons.share, color: Colors.grey),
          onPressed: () {
            // Implement share functionality
          },
        ),
        onTap: () => _openFile(context, file),
      ),
    );
  }

  Future<void> _openFile(BuildContext context, RtfFile file) async {
    try {
      final rtfProvider = Provider.of<RtfProvider>(context, listen: false);
      await rtfProvider.openRtfFile(file.path);
      
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DocumentViewerScreen(),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
    }
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh'),
            onTap: () {
              Navigator.pop(context);
              Provider.of<RtfProvider>(context, listen: false).loadRecentFiles();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear Recent Files'),
            onTap: () {
              Navigator.pop(context);
              // Implement clear functionality
              // This would require adding a clearRecentFiles method to RtfProvider
            },
          ),
        ],
      ),
    );
  }
}