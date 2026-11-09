
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

  String _sortMode = 'default';

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

  String _formatRupiah(double value) {
    final rounded = value.round().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < rounded.length; i++) {
      if (i > 0 && (rounded.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(rounded[i]);
    }

    return 'Rp ${buffer.toString()}';
  }

  List<Destination> _sortDestinations(
    List<Destination> destinations,
  ) {
    final result = List<Destination>.from(destinations);

    switch (_sortMode) {
      case 'cheapest':
        result.sort((a, b) {
          final priceA = a.entranceFee;
          final priceB = b.entranceFee;

          if (priceA == null && priceB == null) return 0;
          if (priceA == null) return 1;
          if (priceB == null) return -1;

          return priceA.compareTo(priceB);
        });
        break;

      case 'expensive':
        result.sort((a, b) {
          final priceA = a.entranceFee;
          final priceB = b.entranceFee;

          if (priceA == null && priceB == null) return 0;
          if (priceA == null) return 1;
          if (priceB == null) return -1;

          return priceB.compareTo(priceA);
        });
        break;

      case 'rating':
        result.sort((a, b) {
          final ratingA = a.rating;
          final ratingB = b.rating;

          if (ratingA == null && ratingB == null) return 0;
          if (ratingA == null) return 1;
          if (ratingB == null) return -1;

          return ratingB.compareTo(ratingA);
        });
        break;

      default:
        break;
    }

    return result;
  }

  String get _sortLabel {
    switch (_sortMode) {
      case 'cheapest':
        return 'Cheapest';
      case 'expensive':
        return 'Most Expensive';
      case 'rating':
        return 'Highest Rated';
      default:
        return 'Default';
    }
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
            final searchedDestinations =
                provider.destinations.where((destination) {
              final query = _searchQuery.toLowerCase();

              return destination.name
                      .toLowerCase()
                      .contains(query) ||
                  destination.location
                      .toLowerCase()
                      .contains(query);
            }).toList();

            final destinations =
                _sortDestinations(searchedDestinations);

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

  // TOOLBAR AND SORTING
  Widget _buildToolbar(int count, bool isWide) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 28 : 20,
        vertical: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$count places found',
              style: const TextStyle(
                color: darkColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),

          // SORT DROPDOWN
          PopupMenuButton<String>(
            tooltip: 'Sort destinations',
            onSelected: (value) {
              setState(() {
                _sortMode = value;
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'default',
                child: Row(
                  children: [
                    Icon(Icons.list, size: 19),
                    SizedBox(width: 10),
                    Text('Default'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'cheapest',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward, size: 19),
                    SizedBox(width: 10),
                    Text('Cheapest'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'expensive',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward, size: 19),
                    SizedBox(width: 10),
                    Text('Most Expensive'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'rating',
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 19,
                      color: Colors.amber,
                    ),
                    SizedBox(width: 10),
                    Text('Highest Rated'),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.black12,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sort,
                    size: 18,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _sortLabel,
                    style: const TextStyle(
                      color: darkColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 17,
                    color: darkColor,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          IconButton(
            tooltip: 'Grid view',
            onPressed: () {
              setState(() {
                _isGridView = true;
              });
            },
            icon: Icon(
              Icons.grid_view_rounded,
              color: _isGridView
                  ? primaryColor
                  : Colors.grey,
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
              color: !_isGridView
                  ? primaryColor
                  : Colors.grey,
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
    if (provider.isLoading &&
        provider.destinations.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      );
    }

    if (provider.hasError &&
        provider.destinations.isEmpty) {
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
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
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
    final isFavorite =
        provider.isFavorite(destination.id);

    final imageSize =
        availableWidth >= 700 ? 145.0 : 115.0;

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
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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

                    const SizedBox(height: 8),

                    _buildPriceAndRating(destination),
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

  // PRICE AND RATING INFORMATION
  Widget _buildPriceAndRating(Destination destination) {
    return Wrap(
      spacing: 12,
      runSpacing: 5,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.confirmation_number_outlined,
              size: 14,
              color: primaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              destination.entranceFee == null
                  ? 'Price unavailable'
                  : _formatRupiah(destination.entranceFee!),
              style: const TextStyle(
                color: primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star,
              size: 14,
              color: Colors.amber,
            ),
            const SizedBox(width: 3),
            Text(
              destination.rating == null
                  ? 'No rating'
                  : destination.rating!.toStringAsFixed(1),
              style: const TextStyle(
                color: darkColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
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
        isFavorite
            ? Icons.favorite
            : Icons.favorite_border,
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
