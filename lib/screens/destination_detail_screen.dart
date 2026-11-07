
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/destination_model.dart';
import '../models/itinerary_model.dart';
import '../providers/travel_provider.dart';

class DestinationDetailScreen extends StatefulWidget {
  final Destination destination;

  const DestinationDetailScreen({
    super.key,
    required this.destination,
  });

  @override
  State<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState
    extends State<DestinationDetailScreen> {
  static const Color primaryColor = Color(0xFF087F8C);
  static const Color darkColor = Color(0xFF173B3D);

  // ==========================================
  // ADD TO ITINERARY
  // ==========================================

  Future<void> _addToItinerary() async {
    // Pilih tanggal kunjungan.
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null || !mounted) return;

    // Ambil Provider sebelum dialog dibuka.
    final provider = context.read<TravelProvider>();

    final budgetController = TextEditingController();
    final notesController = TextEditingController();

    bool? saveResult;

    try {
      // Dialog tetap terbuka selama proses penyimpanan.
      saveResult = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          // Status penyimpanan dialog.
          bool isSaving = false;

          return StatefulBuilder(
            builder: (context, setDialogState) {
              return PopScope(
                canPop: !isSaving,
                child: AlertDialog(
                  title: const Text('Add to Itinerary'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Plan your visit to '
                          '${widget.destination.name}',
                          style: const TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Budget
                        TextField(
                          controller: budgetController,
                          keyboardType: TextInputType.number,
                          enabled: !isSaving,
                          decoration: const InputDecoration(
                            labelText: 'Budget (Rp)',
                            prefixText: 'Rp ',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Notes
                        TextField(
                          controller: notesController,
                          maxLines: 3,
                          enabled: !isSaving,
                          decoration: const InputDecoration(
                            labelText: 'Notes (optional)',
                            hintText: 'Write your travel notes...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    // Cancel button
                    TextButton(
                      onPressed: isSaving
                          ? null
                          : () {
                              Navigator.pop(
                                dialogContext,
                                false,
                              );
                            },
                      child: const Text('Cancel'),
                    ),

                    // Save button
                    FilledButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              // Tampilkan loading.
                              setDialogState(() {
                                isSaving = true;
                              });

                              // Ambil nilai Budget.
                              final budgetText = budgetController
                                  .text
                                  .trim()
                                  .replaceAll('.', '')
                                  .replaceAll(',', '');

                              final budget =
                                  double.tryParse(budgetText) ?? 0;

                              // Ambil nilai Notes.
                              final notes =
                                  notesController.text.trim();

                              // Buat objek itinerary.
                              final itinerary = Itinerary(
                                spotName: widget.destination.name,
                                visitDate: selectedDate,
                                budget: budget,
                                status: 'Planned',
                                notes: notes,
                              );

                              // Simpan melalui Provider ke Supabase.
                              final result =
                                  await provider.addItinerary(
                                itinerary,
                              );

                              // Pastikan dialog masih aktif.
                              if (!dialogContext.mounted) return;

                              // Tutup dialog setelah proses selesai.
                              Navigator.pop(
                                dialogContext,
                                result,
                              );
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryColor,
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save Plan'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } finally {
      // Hapus controller setelah dialog ditutup.
      budgetController.dispose();
      notesController.dispose();
    }

    if (!mounted || saveResult == null) return;

    // Ambil pesan error asli dari Provider.
    final errorMessage = provider.itineraryError;

    // Tampilkan hasil penyimpanan.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saveResult
              ? '${widget.destination.name} added to your itinerary!'
              : 'Gagal menyimpan itinerary:\n'
                  '${errorMessage ?? "Unknown error"}',
        ),
        backgroundColor:
            saveResult ? primaryColor : Colors.red,
        duration: const Duration(seconds: 10),
      ),
    );
  }

  // ==========================================
  // BUILD SCREEN
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final destination = widget.destination;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F5),
      body: CustomScrollView(
        slivers: [
          // Destination image and favorite button.
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: destination.imageUrl.isNotEmpty
                  ? Image.network(
                      destination.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _imagePlaceholder();
                      },
                    )
                  : _imagePlaceholder(),
            ),
            actions: [
              Consumer<TravelProvider>(
                builder: (context, provider, child) {
                  final isFavorite =
                      provider.isFavorite(destination.id);

                  return IconButton(
                    tooltip: 'Favorite',
                    onPressed: () {
                      provider.toggleFavorite(destination.id);
                    },
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: isFavorite
                          ? Colors.redAccent
                          : Colors.white,
                    ),
                  );
                },
              ),
            ],
          ),

          // Destination information.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Destination name.
                  Text(
                    destination.name,
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: darkColor,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Destination location.
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: primaryColor,
                        size: 19,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          destination.location,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Description title.
                  const Text(
                    'About this destination',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: darkColor,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Destination description.
                  Text(
                    destination.description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.7,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Travel tip.
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: primaryColor,
                          size: 26,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Remember to bring drinking water, '
                            'sunscreen, and comfortable footwear '
                            'for your trip.',
                            style: TextStyle(
                              color: darkColor,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Add to Itinerary button.
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            16,
          ),
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _addToItinerary,
              icon: const Icon(Icons.add_road),
              label: const Text(
                'Add to Itinerary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // IMAGE PLACEHOLDER
  // ==========================================

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFDDEBE8),
      child: const Center(
        child: Icon(
          Icons.beach_access,
          size: 70,
          color: primaryColor,
        ),
      ),
    );
  }
}
