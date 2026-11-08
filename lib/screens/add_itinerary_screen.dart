
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/destination_model.dart';
import '../models/itinerary_model.dart';
import '../providers/travel_provider.dart';

class AddItineraryScreen extends StatefulWidget {
  final Destination destination;

  const AddItineraryScreen({
    super.key,
    required this.destination,
  });

  @override
  State<AddItineraryScreen> createState() =>
      _AddItineraryScreenState();
}

class _AddItineraryScreenState extends State<AddItineraryScreen> {
  static const Color primaryColor = Color(0xFF087F8C);
  static const Color darkColor = Color(0xFF173B3D);

  final _formKey = GlobalKey<FormState>();
  final _budgetController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _budgetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveItinerary() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final provider = context.read<TravelProvider>();

    final budget = double.parse(
      _budgetController.text.trim(),
    );

    final itinerary = Itinerary(
      spotName: widget.destination.name,
      visitDate: _selectedDate,
      budget: budget,
      status: 'Planned',
      notes: _notesController.text.trim(),
    );

    final success = await provider.addItinerary(itinerary);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Itinerary berhasil ditambahkan!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan itinerary: '
            '${provider.itineraryError ?? 'Terjadi kesalahan'}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F5),
      appBar: AppBar(
        title: const Text(
          'Add Itinerary',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 70 : 20,
                vertical: 22,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 650,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Plan Your Trip',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: darkColor,
                          ),
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'Create your travel plan and get ready '
                          'for your next adventure.',
                          style: TextStyle(
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // DESTINATION
                        _sectionLabel('Destination'),
                        const SizedBox(height: 9),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: primaryColor,
                                size: 25,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.destination.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: darkColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.destination.location,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),

                        // VISIT DATE
                        _sectionLabel('Visit Date'),
                        const SizedBox(height: 9),
                        InkWell(
                          onTap: _isSaving ? null : _selectDate,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.calendar_month,
                                color: primaryColor,
                              ),
                              suffixIcon: const Icon(
                                Icons.arrow_drop_down,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            child: Text(
                              _formatDate(_selectedDate),
                              style: const TextStyle(
                                color: darkColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // BUDGET
                        _sectionLabel('Budget (Rp)'),
                        const SizedBox(height: 9),
                        TextFormField(
                          controller: _budgetController,
                          enabled: !_isSaving,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            hintText: 'Contoh: 500000',
                            prefixText: 'Rp ',
                            prefixIcon: const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: primaryColor,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Budget wajib diisi';
                            }

                            final amount = double.tryParse(
                              value.trim(),
                            );

                            if (amount == null || amount < 0) {
                              return 'Masukkan budget yang valid';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 22),

                        // NOTES
                        _sectionLabel('Notes (Optional)'),
                        const SizedBox(height: 9),
                        TextFormField(
                          controller: _notesController,
                          enabled: !_isSaving,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Write your travel notes...',
                            alignLabelWithHint: true,
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(bottom: 55),
                              child: Icon(
                                Icons.notes,
                                color: primaryColor,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // SAVE BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton.icon(
                            onPressed:
                                _isSaving ? null : _saveItinerary,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 19,
                                    height: 19,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined),
                            label: Text(
                              _isSaving
                                  ? 'Saving...'
                                  : 'Save Itinerary',
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
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sectionLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: darkColor,
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    );
  }
}
