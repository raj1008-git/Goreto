import 'package:flutter/material.dart';
import 'package:goreto/core/utils/app_loader.dart';
import 'package:goreto/features/search/widgets/search_result_tile.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/search_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final query = _controller.text.trim();
      Provider.of<SearchProvider>(context, listen: false).search(query);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Search destination",
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _controller.clear();
              searchProvider.clearResults();
            },
          ),
        ],
      ),
      body: searchProvider.isLoading
          ? const AppLoader()
          : ListView.builder(
              itemCount: searchProvider.results.length,
              itemBuilder: (_, index) {
                final place = searchProvider.results[index];
                return SearchResultTile(place: place);
              },
            ),
    );
  }
}
