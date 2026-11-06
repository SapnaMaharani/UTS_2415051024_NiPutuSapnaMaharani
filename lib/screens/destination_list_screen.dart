
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/travel_provider.dart';

class DestinationListScreen extends StatefulWidget {
  const DestinationListScreen({super.key});

  @override
  State<DestinationListScreen> createState() =>
      _DestinationListScreenState();
}

class _DestinationListScreenState extends State<DestinationListScreen> {
  static const Color primaryColor = Color(0xFF087F8C);
  static const Color backgroundColor = Color(0xFFF5F8F5);
  static const Color darkColor = Color(0xFF173B3D);

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  bool _isGridView = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        foregroundColor: darkColor,
        title: const Text(
          'Explore Destinations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<TravelProvider>(
          builder: (context, provider, child) {
            final destinations = provider.destinations.where((destination) {
              return destination.name
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                  destination.location
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase());
            }).toList();

            return Column(
              children: [
                _buildSearchBar(),
                _buildToolbar(destinations.length),
                Expanded(
                  child: _buildDestinationContent(
                    provider,
                    destinations,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search your favorite destination...',
          prefixIcon: const Icon(
            Icons.search,
            color: primaryColor,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.close),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Text(
            '$count places found',
            style: const TextStyle(
              color: darkColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Grid view',
            onPressed: () {
              setState(() {
                _isGridView = true;
              });
            },
            icon: Icon(
              Icons.grid_view_rounded,
              color: _isGridView ? primaryColor : Colors.grey,
            ),
          ),
          IconButton(
            tooltip: 'List view',
            onPressed: () {
              setState(() {
                _isGridView = false;
              });
            },
            icon: Icon(
              Icons.view_list_rounded,
              color: !_isGridView ? primaryColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationContent(
    TravelProvider provider,
    List destinations,
  ) {
    if (provider.isLoading && provider.destinations.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      );
    }

    if (provider.hasError && provider.destinations.isEmpty) {
      return _buildMessage(
        'Unable to load destinations.',
        Icons.wifi_off,
        onRetry: provider.fetchDestinations,
      );
    }

    if (destinations.isEmpty) {
      return _buildMessage(
        _searchQuery.isEmpty
            ? 'No destinations available yet.'
            : 'No destinations match your search.',
        Icons.location_off,
      );
    }

    if (_isGridView) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount =
              constraints.maxWidth >= 700 ? 3 : 2;

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
            itemCount: destinations.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final destination = destinations[index];

              return _buildGridCard(destination, provider);
            },
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        final destination = destinations[index];

        return _buildListCard(destination, provider);
      },
    );
  }

  Widget _buildGridCard(dynamic destination, TravelProvider provider) {
    final isFavorite = provider.isFavorite(destination.id);

    return GestureDetector(
      onTap: () {
        _showDetailMessage(destination.name);
      },
      child: Card(
        color: Colors.white,
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    destination.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _imagePlaceholder();
                    },
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _favoriteButton(
                      provider,
                      destination.id,
                      isFavorite,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: darkColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: primaryColor,
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          destination.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(dynamic destination, TravelProvider provider) {
    final isFavorite = provider.isFavorite(destination.id);

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _showDetailMessage(destination.name);
        },
        child: Row(
          children: [
            Image.network(
              destination.imageUrl,
              width: 115,
              height: 115,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return SizedBox(
                  width: 115,
                  height: 115,
                  child: _imagePlaceholder(),
                );
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: darkColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      destination.location,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _favoriteButton(
              provider,
              destination.id,
              isFavorite,
            ),
          ],
        ),
      ),
    );
  }

  Widget _favoriteButton(
    TravelProvider provider,
    String id,
    bool isFavorite,
  ) {
    return IconButton(
      onPressed: () {
        provider.toggleFavorite(id);
      },
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: Colors.redAccent,
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFDCEDEA),
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          color: primaryColor,
          size: 35,
        ),
      ),
    );
  }

  Widget _buildMessage(
    String message,
    IconData icon, {
    Future<void> Function()? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 45, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            if (onRetry != null)
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
          ],
        ),
      ),
    );
  }

  void _showDetailMessage(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name selected. Detail page is coming next!'),
        backgroundColor: primaryColor,
      ),
    );
  }
}
