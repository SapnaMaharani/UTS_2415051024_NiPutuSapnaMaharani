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
  static const Color backgroundColor = Color(0xFFF5F8F5);

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedFilter = 'All';

  // Mencegah proses hapus ganda.
  final Set<String> _deletingIds = {};

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

  // FORMAT TANGGAL
  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // FORMAT RUPIAH
  String _formatBudget(double budget) {
    return 'Rp ${budget.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
  }

  // SEARCH DAN FILTER
  List<Itinerary> _filterItineraries(List<Itinerary> itineraries) {
    return itineraries.where((itinerary) {
      final matchesSearch = itinerary.spotName.toLowerCase().contains(
        _searchQuery.toLowerCase().trim(),
      );

      final matchesStatus =
          _selectedFilter == 'All' || itinerary.status == _selectedFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // RESET FILTER
  void _resetFilter() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
      _selectedFilter = 'All';
    });
  }

  // NOTIFIKASI
  void _showMessage(String message, {bool success = true}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // EDIT ITINERARY
  Future<void> _editItinerary(Itinerary itinerary) async {
    if (itinerary.id == null) {
      _showMessage('ID itinerary tidak ditemukan.', success: false);
      return;
    }

    final nameController = TextEditingController(text: itinerary.spotName);

    final budgetController = TextEditingController(
      text: itinerary.budget.toStringAsFixed(0),
    );

    final notesController = TextEditingController(text: itinerary.notes);

    final formKey = GlobalKey<FormState>();

    DateTime selectedDate = itinerary.visitDate;
    String selectedStatus = itinerary.status;
    bool saving = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Edit Itinerary',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Budget (Rp)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.account_balance_wallet),
                        ),
                        validator: (value) {
                          final amount = double.tryParse((value ?? '').trim());

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
                      : () {
                          Navigator.pop(dialogContext, false);
                        },
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
                            budget: double.parse(budgetController.text.trim()),
                            status: selectedStatus,
                            notes: notesController.text.trim(),
                          );

                          bool success = false;

                          try {
                            success = await context
                                .read<TravelProvider>()
                                .updateItinerary(itinerary.id!, updated);
                          } catch (_) {
                            success = false;
                          }

                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext, success);
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
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

    if (result) {
      _showMessage('Itinerary berhasil diperbarui!');
    } else {
      final error = context.read<TravelProvider>().itineraryError;

      _showMessage(
        'Gagal memperbarui: ${error ?? 'Terjadi kesalahan'}',
        success: false,
      );
    }
  }

  // KONFIRMASI DELETE ITINERARY
  Future<void> _deleteItinerary(Itinerary itinerary) async {
    if (itinerary.id == null) {
      _showMessage('ID itinerary tidak ditemukan.', success: false);
      return;
    }

    final String itineraryId = itinerary.id.toString();

    // Cegah penghapusan ganda.
    if (_deletingIds.contains(itineraryId)) return;

    // Tampilkan dialog konfirmasi terlebih dahulu.
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: 42,
          ),
          title: const Text(
            'Hapus Itinerary?',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah kamu yakin ingin menghapus rencana perjalanan '
            '"${itinerary.spotName}"?\n\n'
            'Data yang sudah dihapus tidak dapat dikembalikan.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Ya, Hapus'),
            ),
          ],
        );
      },
    );

    // Jika Batal atau dialog ditutup, jangan hapus data.
    if (confirmed != true || !mounted) return;

    setState(() {
      _deletingIds.add(itineraryId);
    });

    bool success = false;

    try {
      success = await context.read<TravelProvider>().deleteItinerary(
        itinerary.id!,
      );
    } catch (_) {
      success = false;
    }

    if (!mounted) return;

    setState(() {
      _deletingIds.remove(itineraryId);
    });

    if (success) {
      _showMessage('Itinerary berhasil dihapus!');
    } else {
      final error = context.read<TravelProvider>().itineraryError;

      _showMessage(
        'Gagal menghapus: ${error ?? 'Terjadi kesalahan'}',
        success: false,
      );
    }
  }

  // STATUS BADGE
  Widget _statusBadge(String status) {
    final color = switch (status) {
      'Completed' => Colors.green,
      'Ongoing' => Colors.orange,
      _ => primaryColor,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: primaryColor),
        const SizedBox(width: 9),
        SizedBox(
          width: 75,
          child: Text(label, style: const TextStyle(color: Colors.grey)),
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
    final String? id = itinerary.id?.toString();
    final bool isDeleting = id != null && _deletingIds.contains(id);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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

                const SizedBox(width: 6),

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
              _infoRow(Icons.notes_rounded, 'Catatan', itinerary.notes),
            ],

            const Divider(height: 26),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: isDeleting
                      ? null
                      : () => _editItinerary(itinerary),
                  icon: const Icon(Icons.edit_outlined, size: 17),
                  label: const Text('Edit'),
                ),

                const SizedBox(width: 8),

                OutlinedButton.icon(
                  onPressed: isDeleting
                      ? null
                      : () => _deleteItinerary(itinerary),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  icon: isDeleting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline, size: 17),
                  label: Text(isDeleting ? 'Menghapus...' : 'Hapus'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // EMPTY STATE
  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: context.read<TravelProvider>().fetchItineraries,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 110),
          Icon(Icons.luggage_outlined, size: 75, color: Colors.grey),
          SizedBox(height: 18),
          Center(
            child: Text(
              'Belum Ada Itinerary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

  // ERROR STATE
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 55, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'Gagal memuat itinerary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                context.read<TravelProvider>().fetchItineraries();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader(int filteredCount, int totalCount) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.map_outlined, color: Colors.white, size: 34),
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
                  '$filteredCount dari $totalCount rencana perjalanan',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SEARCH FIELD
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Cari nama destinasi...',
        prefixIcon: const Icon(Icons.search, color: primaryColor),
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
    );
  }

  // FILTER STATUS
  Widget _buildStatusFilter() {
    const statuses = ['All', 'Planned', 'Ongoing', 'Completed'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses.map((status) {
          final isSelected = _selectedFilter == status;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(status),
              selected: isSelected,
              selectedColor: primaryColor,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) {
                setState(() {
                  _selectedFilter = status;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // NO SEARCH RESULT
  Widget _buildNoResult() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 55),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 55, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'Itinerary Tidak Ditemukan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

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
          // LOADING STATE
          if (provider.isItineraryLoading && provider.itineraries.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          // ERROR STATE
          if (provider.itineraryError != null && provider.itineraries.isEmpty) {
            return _buildErrorState(provider.itineraryError!);
          }

          // EMPTY STATE
          if (provider.itineraries.isEmpty) {
            return _buildEmptyState();
          }

          final filteredItineraries = _filterItineraries(provider.itineraries);

          return RefreshIndicator(
            onRefresh: provider.fetchItineraries,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(
                  filteredItineraries.length,
                  provider.itineraries.length,
                ),

                _buildSearchField(),

                const SizedBox(height: 18),

                const Text(
                  'Filter Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                _buildStatusFilter(),

                const SizedBox(height: 18),

                if (filteredItineraries.isEmpty)
                  _buildNoResult()
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
