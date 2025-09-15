import 'package:flutter/material.dart';
import 'package:echosense/services/keyword_service.dart';

class KeywordsScreen extends StatefulWidget {
  const KeywordsScreen({super.key});

  @override
  State<KeywordsScreen> createState() => _KeywordsScreenState();
}

class _KeywordsScreenState extends State<KeywordsScreen> {
  List<String> _keywords = [];
  final TextEditingController _newKeywordController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKeywords();
  }

  Future<void> _loadKeywords() async {
    try {
      final keywords = await KeywordService.getKeywords();
      setState(() {
        _keywords = keywords;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error loading keywords: $e');
    }
  }

  Future<void> _addKeyword() async {
    final newKeyword = _newKeywordController.text.trim().toLowerCase();
    
    if (newKeyword.isEmpty) {
      _showError('Please enter a keyword');
      return;
    }

    if (_keywords.contains(newKeyword)) {
      _showError('Keyword already exists');
      return;
    }

    try {
      await KeywordService.addKeyword(newKeyword);
      setState(() {
        _keywords.add(newKeyword);
        _newKeywordController.clear();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "$newKeyword" to keywords'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Error adding keyword: $e');
    }
  }

  Future<void> _removeKeyword(String keyword) async {
    try {
      await KeywordService.removeKeyword(keyword);
      setState(() {
        _keywords.remove(keyword);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed "$keyword" from keywords'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      _showError('Error removing keyword: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showAddKeywordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Keyword'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newKeywordController,
              decoration: const InputDecoration(
                labelText: 'Keyword',
                hintText: 'Enter a keyword to detect',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.none,
              onSubmitted: (_) => _addKeyword(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _addKeyword();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Keywords'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddKeywordDialog,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline),
                              const SizedBox(width: 8),
                              Text(
                                'Keyword Detection',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add keywords that you want to detect in voice transcripts. Keywords are case-insensitive and will trigger alerts when found.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Keywords (${_keywords.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      if (_keywords.isNotEmpty)
                        TextButton.icon(
                          onPressed: _showClearAllDialog,
                          icon: const Icon(Icons.clear_all, size: 16),
                          label: const Text('Clear All'),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: _keywords.isEmpty
                      ? _buildEmptyState()
                      : _buildKeywordsList(),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Keywords Added',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first keyword',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _keywords.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final keyword = _keywords[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.tag),
            ),
            title: Text(keyword),
            trailing: IconButton(
              onPressed: () => _showRemoveConfirmation(keyword),
              icon: const Icon(Icons.delete_outline),
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        );
      },
    );
  }

  void _showRemoveConfirmation(String keyword) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Keyword'),
        content: Text('Are you sure you want to remove "$keyword"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _removeKeyword(keyword);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Keywords'),
        content: const Text('Are you sure you want to remove all keywords? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await KeywordService.saveKeywords([]);
                setState(() => _keywords.clear());
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All keywords cleared'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                _showError('Error clearing keywords: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _newKeywordController.dispose();
    super.dispose();
  }
}