import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/destination_model.dart';
import '../providers/travel_provider.dart';
import '../widgets/destination_card.dart';
import 'destination_detail_screen.dart';

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

  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';
  bool _isGridView = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(Destination destination) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DestinationDetailScreen(
          destination: destination,
        ),
      ),
    );
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
            final destinations =
                provider.destinations.where((destination) {
              final query = _searchQuery.toLowerCase();

              return destination.name
                      .toLowerCase()
                      .contains(query) ||
                  destination.location
                      .toLowerCase()
                      .contains(query);
            }).toList();

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 700;

                return Column(
                  children: [
                    _buildSearchBar(isWide),
                    _buildToolbar(
                      destinations.length,
                      isWide,
                    ),
                    Expanded(
                      child: _buildDestinationContent(
                        provider,
                        destinations,
                        constraints.maxWidth,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // SEARCH BAR
  Widget _buildSearchBar(bool isWide) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isWide ? 28 : 20,
        12,
        isWide ? 28 : 20,
        10,
      ),
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
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // TOOLBAR
  Widget _buildToolbar(int count, bool isWide) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 28 : 20,
        vertical: 10,
      ),
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

  // DESTINATION CONTENT
  Widget _buildDestinationContent(
    TravelProvider provider,
    List<Destination> destinations,
    double availableWidth,
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
      return _buildResponsiveGrid(
        destinations,
        provider,
        availableWidth,
      );
    }

    return _buildResponsiveList(
      destinations,
      provider,
      availableWidth,
    );
  }

  // RESPONSIVE GRID
  Widget _buildResponsiveGrid(
    List<Destination> destinations,
    TravelProvider provider,
    double availableWidth,
  ) {
    final int crossAxisCount;

    if (availableWidth >= 1100) {
      crossAxisCount = 5;
    } else if (availableWidth >= 850) {
      crossAxisCount = 4;
    } else if (availableWidth >= 550) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    final horizontalPadding =
        availableWidth >= 700 ? 28.0 : 20.0;

    const spacing = 14.0;

    // Kartu dibuat lebih tinggi agar teks dan gambar tidak overflow.
    final childAspectRatio =
        availableWidth >= 700 ? 0.82 : 0.72;

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        5,
        horizontalPadding,
        20,
      ),
      itemCount: destinations.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        final destination = destinations[index];

        return _buildDestinationCard(
          destination,
          provider,
        );
      },
    );
  }

  // RESPONSIVE LIST
  Widget _buildResponsiveList(
    List<Destination> destinations,
    TravelProvider provider,
    double availableWidth,
  ) {
    final horizontalPadding =
        availableWidth >= 700 ? 28.0 : 20.0;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        5,
        horizontalPadding,
        20,
      ),
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        final destination = destinations[index];

        return _buildListCard(
          destination,
          provider,
          availableWidth,
        );
      },
    );
  }

  // REUSABLE DESTINATION CARD
  Widget _buildDestinationCard(
    Destination destination,
    TravelProvider provider,
  ) {
    return DestinationCard(
      destination: destination,
      isFavorite: provider.isFavorite(destination.id),
      onTap: () => _openDetail(destination),
      onFavoriteTap: () {
        provider.toggleFavorite(destination.id);
      },
    );
  }

  // LIST CARD
  Widget _buildListCard(
    Destination destination,
    TravelProvider provider,
    double availableWidth,
  ) {
    final isFavorite = provider.isFavorite(destination.id);

    final imageSize = availableWidth >= 700 ? 145.0 : 115.0;

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openDetail(destination),
        child: Row(
          children: [
            Image.network(
              destination.imageUrl,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return SizedBox(
                  width: imageSize,
                  height: imageSize,
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

  // FAVORITE BUTTON
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

  // IMAGE PLACEHOLDER
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

  // EMPTY / ERROR MESSAGE
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
            Icon(
              icon,
              size: 45,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
              ),
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
}