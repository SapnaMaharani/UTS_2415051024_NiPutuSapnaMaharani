
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/travel_provider.dart';
import 'destination_list_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onExplore;

  const HomeScreen({
    super.key,
    this.onExplore,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color primaryColor = Color(0xFF087F8C);
  static const Color backgroundColor = Color(0xFFF5F8F5);
  static const Color darkColor = Color(0xFF173B3D);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final provider = context.read<TravelProvider>();

      provider.fetchDestinations();
      provider.fetchItineraries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Consumer<TravelProvider>(
          builder: (context, provider, child) {
            return RefreshIndicator(
              color: primaryColor,
              onRefresh: () async {
                await provider.refreshDestinations();
                await provider.fetchItineraries();
              },
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),

                  _buildBanner(),
                  const SizedBox(height: 28),

                  _buildSectionTitle(
                    'Popular Destinations',
                    'View all',
                    onTap: () {
                      _openDestinationList(context);
                    },
                  ),
                  const SizedBox(height: 15),

                  _buildDestinations(provider),
                  const SizedBox(height: 25),

                  _buildSectionTitle(
                    'My Travel Plans',
                    'View your trips',
                  ),
                  const SizedBox(height: 14),

                  _buildItinerarySummary(provider),
                  const SizedBox(height: 25),

                  _buildFavoriteSummary(provider),
                  const SizedBox(height: 25),

                  _buildFooter(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HELLO, TRAVELER!',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Explore Nusa Penida',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: darkColor,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Discover beautiful places and create memories.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 26,
          backgroundColor: primaryColor.withValues(alpha: 0.12),
          child: IconButton(
            tooltip: 'Explore destinations',
            onPressed: () {
              _openDestinationList(context);
            },
            icon: const Icon(
              Icons.travel_explore,
              color: primaryColor,
              size: 29,
            ),
          ),
        ),
      ],
    );
  }

  // OPEN DESTINATION LIST
  void _openDestinationList(BuildContext context) {
    if (widget.onExplore != null) {
      widget.onExplore!();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DestinationListScreen(),
      ),
    );
  }

  // BANNER
  Widget _buildBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1533105079780-92b9be482077',
            height: 195,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 195,
                color: primaryColor,
                child: const Center(
                  child: Icon(
                    Icons.beach_access,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          Container(
            height: 195,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: const Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discover Paradise',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Your journey begins in Nusa Penida',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SECTION TITLE
  Widget _buildSectionTitle(
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: darkColor,
          ),
        ),
        if (onTap != null)
          TextButton(
            onPressed: onTap,
            child: Text(
              subtitle,
              style: const TextStyle(
                color: primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Text(
            subtitle,
            style: const TextStyle(
              color: primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  // POPULAR DESTINATIONS
  Widget _buildDestinations(TravelProvider provider) {
    if (provider.isLoading && provider.destinations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(35),
        child: Center(
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        ),
      );
    }

    if (provider.hasError && provider.destinations.isEmpty) {
      return _buildEmptyMessage(
        'Unable to load destinations. Please try again.',
        Icons.wifi_off,
        onRetry: provider.fetchDestinations,
      );
    }

    if (provider.destinations.isEmpty) {
      return _buildEmptyMessage(
        'No destinations available yet.',
        Icons.location_off,
        onRetry: provider.fetchDestinations,
      );
    }

    return Column(
      children: provider.destinations.take(5).map((destination) {
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          elevation: 1,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              _openDestinationList(context);
            },
            child: Row(
              children: [
                Image.network(
                  destination.imageUrl,
                  width: 115,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 115,
                      height: 120,
                      color: const Color(0xFFDCEDEA),
                      child: const Icon(
                        Icons.image_not_supported,
                        color: primaryColor,
                      ),
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
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: darkColor,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          destination.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: primaryColor,
                            ),
                            SizedBox(width: 3),
                            Text(
                              'Nusa Penida, Bali',
                              style: TextStyle(
                                fontSize: 11,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    provider.toggleFavorite(destination.id);
                  },
                  icon: Icon(
                    provider.isFavorite(destination.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // MY TRAVEL PLANS
  Widget _buildItinerarySummary(TravelProvider provider) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.calendar_month,
              size: 32,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saved Itineraries',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: darkColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  provider.isItineraryLoading
                      ? 'Loading travel plans...'
                      : '${provider.itineraries.length} travel plans saved',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                if (provider.itineraryError != null)
                  const Text(
                    'Unable to load itinerary.',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: primaryColor,
          ),
        ],
      ),
    );
  }

  // FAVORITE SUMMARY
  Widget _buildFavoriteSummary(TravelProvider provider) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE2F1EC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.favorite,
            color: Colors.redAccent,
            size: 30,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Favorite Places',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: darkColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${provider.favoriteIds.length} destinations saved',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // EMPTY STATE
  Widget _buildEmptyMessage(
    String message,
    IconData icon, {
    Future<void> Function()? onRetry,
  }) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 38,
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
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ],
      ),
    );
  }

  // FOOTER
  Widget _buildFooter() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 15),
        child: Text(
          'Made with love for your Nusa Penida adventure',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
