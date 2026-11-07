
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/itinerary_model.dart';
import '../providers/travel_provider.dart';

class MyItineraryScreen extends StatefulWidget {
  const MyItineraryScreen({super.key});

  @override
  State<MyItineraryScreen> createState() => _MyItineraryScreenState();
}

class _MyItineraryScreenState extends State<MyItineraryScreen> {
  static const Color primaryColor = Color(0xFF087F8C);

  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TravelProvider>().fetchItineraries();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatBudget(double budget) {
    return 'Rp ${budget.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    )}';
  }

  // SEARCH DAN FILTER ITINERARY
  List<Itinerary> _filterItineraries(
    List<Itinerary> itineraries,
  ) {
    return itineraries.where((itinerary) {
      final matchesSearch = itinerary.spotName
          .toLowerCase()
          .contains(_searchQuery.toLowerCase().trim());

      final matchesStatus = _selectedFilter == 'All' ||
          itinerary.status == _selectedFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // RESET SEARCH DAN FILTER
  void _resetFilter() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
      _selectedFilter = 'All';
    });
  }

  // EDIT ITINERARY
  Future<void> _editItinerary(Itinerary itinerary) async {
    if (itinerary.id == null) return;

    final nameController = TextEditingController(
      text: itinerary.spotName,
    );

    final budgetController = TextEditingController(
      text: itinerary.budget.toStringAsFixed(0),
    );

    final notesController = TextEditingController(
      text: itinerary.notes,
    );

    DateTime selectedDate = itinerary.visitDate;
    String selectedStatus = itinerary.status;
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Itinerary'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama destinasi',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.place_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama destinasi wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        onTap: saving
                            ? null
                            : () async {
                                final picked = await showDatePicker(
                                  context: dialogContext,
                                  initialDate: selectedDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );

                                if (picked != null) {
                                  setDialogState(() {
                                    selectedDate = picked;
                                  });
                                }
                              },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Tanggal kunjungan',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_month),
                          ),
                          child: Text(_formatDate(selectedDate)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: budgetController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Budget (Rp)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.account_balance_wallet,
                          ),
                        ),
                        validator: (value) {
                          final amount = double.tryParse(
                            (value ?? '').trim(),
                          );

                          if (amount == null || amount < 0) {
                            return 'Masukkan budget yang valid';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.flag_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Planned',
                            child: Text('Planned'),
                          ),
                          DropdownMenuItem(
                            value: 'Ongoing',
                            child: Text('Ongoing'),
                          ),
                          DropdownMenuItem(
                            value: 'Completed',
                            child: Text('Completed'),
                          ),
                        ],
                        onChanged: saving
                            ? null
                            : (value) {
                                if (value != null) {
                                  setDialogState(() {
                                    selectedStatus = value;
                                  });
                                }
                              },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Catatan',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.notes),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.pop(dialogContext, false),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          setDialogState(() {
                            saving = true;
                          });

                          final updated = itinerary.copyWith(
                            spotName: nameController.text.trim(),
                            visitDate: selectedDate,
                            budget: double.parse(
                              budgetController.text.trim(),
                            ),
                            status: selectedStatus,
                            notes: notesController.text.trim(),
                          );

                          final success = await context
                              .read<TravelProvider>()
                              .updateItinerary(itinerary.id!, updated);

                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext, success);
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    budgetController.dispose();
    notesController.dispose();

    if (!mounted || result == null) return;

    final provider = context.read<TravelProvider>();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result
              ? 'Itinerary berhasil diperbarui!'
              : 'Gagal memperbarui: ${provider.itineraryError ?? 'Terjadi kesalahan'}',
        ),
        backgroundColor: result ? Colors.green : Colors.red,
      ),
    );
  }

  // DELETE ITINERARY
  Future<void> _deleteItinerary(Itinerary itinerary) async {
    if (itinerary.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Itinerary?'),
          content: Text(
            'Apakah kamu yakin ingin menghapus rencana ${itinerary.spotName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<TravelProvider>();
    final success = await provider.deleteItinerary(itinerary.id!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Itinerary berhasil dihapus!'
              : 'Gagal menghapus: ${provider.itineraryError ?? 'Terjadi kesalahan'}',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  // STATUS BADGE
  Widget _statusBadge(String status) {
    final color = switch (status) {
      'Completed' => Colors.green,
      'Ongoing' => Colors.orange,
      _ => primaryColor,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // INFORMASI ITINERARY
  Widget _infoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: primaryColor),
        const SizedBox(width: 9),
        SizedBox(
          width: 75,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // CARD ITINERARY
  Widget _buildItineraryCard(Itinerary itinerary) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.beach_access_rounded,
                    color: primaryColor,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    itinerary.spotName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _statusBadge(itinerary.status),
              ],
            ),
            const SizedBox(height: 16),
            _infoRow(
              Icons.calendar_today_outlined,
              'Tanggal',
              _formatDate(itinerary.visitDate),
            ),
            const SizedBox(height: 9),
            _infoRow(
              Icons.account_balance_wallet_outlined,
              'Budget',
              _formatBudget(itinerary.budget),
            ),
            if (itinerary.notes.trim().isNotEmpty) ...[
              const SizedBox(height: 9),
              _infoRow(
                Icons.notes_rounded,
                'Catatan',
                itinerary.notes,
              ),
            ],
            const Divider(height: 26),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _editItinerary(itinerary),
                  icon: const Icon(Icons.edit_outlined, size: 17),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _deleteItinerary(itinerary),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 17),
                  label: const Text('Hapus'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F5),
      appBar: AppBar(
        title: const Text(
          'My Itinerary',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              context.read<TravelProvider>().fetchItineraries();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<TravelProvider>(
        builder: (context, provider, child) {
          if (provider.isItineraryLoading &&
              provider.itineraries.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          if (provider.itineraryError != null &&
              provider.itineraries.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_outlined,
                      size: 55,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Gagal memuat itinerary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.itineraryError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => provider.fetchItineraries(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.itineraries.isEmpty) {
            return RefreshIndicator(
              onRefresh: provider.fetchItineraries,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 110),
                  Icon(
                    Icons.luggage_outlined,
                    size: 75,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 18),
                  Center(
                    child: Text(
                      'Belum Ada Itinerary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Tambahkan destinasi ke rencana perjalananmu '
                        'untuk melihatnya di halaman ini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final filteredItineraries =
              _filterItineraries(provider.itineraries);

          return RefreshIndicator(
            onRefresh: provider.fetchItineraries,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // HEADER
                Container(
                  padding: const EdgeInsets.all(18),
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.map_outlined,
                        color: Colors.white,
                        size: 34,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Travel Plans',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${filteredItineraries.length} dari '
                              '${provider.itineraries.length} rencana perjalanan',
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // SEARCH
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari nama destinasi...',
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // FILTER STATUS
                const Text(
                  'Filter Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'All',
                      'Planned',
                      'Ongoing',
                      'Completed',
                    ].map((status) {
                      final isSelected = _selectedFilter == status;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          selectedColor: primaryColor,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = status;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 18),

                // HASIL PENCARIAN DAN FILTER
                if (filteredItineraries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 55),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 55,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Itinerary Tidak Ditemukan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Coba ubah kata pencarian atau filter status.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: _resetFilter,
                          child: const Text('Reset Filter'),
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredItineraries.map(_buildItineraryCard),
              ],
            ),
          );
        },
      ),
    );
  }
}
