
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/itinerary_model.dart';
import '../providers/travel_provider.dart';

class EditItineraryScreen extends StatefulWidget {
  final Itinerary itinerary;

  const EditItineraryScreen({
    super.key,
    required this.itinerary,
  });

  @override
  State<EditItineraryScreen> createState() =>
      _EditItineraryScreenState();
}

class _EditItineraryScreenState extends State<EditItineraryScreen> {
  static const Color primaryColor = Color(0xFF087F8C);
  static const Color darkColor = Color(0xFF173B3D);

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _budgetController;
  late final TextEditingController _notesController;

  late DateTime _selectedDate;
  late String _selectedStatus;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.itinerary.spotName,
    );

    _budgetController = TextEditingController(
      text: widget.itinerary.budget.toStringAsFixed(0),
    );

    _notesController = TextEditingController(
      text: widget.itinerary.notes,
    );

    _selectedDate = widget.itinerary.visitDate;
    _selectedStatus = widget.itinerary.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
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
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _updateItinerary() async {
    if (!_formKey.currentState!.validate()) return;

    final id = widget.itinerary.id;

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID itinerary tidak ditemukan.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final updated = widget.itinerary.copyWith(
      spotName: _nameController.text.trim(),
      visitDate: _selectedDate,
      budget: double.parse(_budgetController.text.trim()),
      status: _selectedStatus,
      notes: _notesController.text.trim(),
    );

    final provider = context.read<TravelProvider>();

    final success = await provider.updateItinerary(
      id,
      updated,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Itinerary berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memperbarui itinerary: '
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
          'Edit Itinerary',
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
                          'Update Your Travel Plan',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: darkColor,
                          ),
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'Make changes to your itinerary details.',
                          style: TextStyle(
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // DESTINATION NAME
                        _sectionLabel('Destination Name'),
                        const SizedBox(height: 9),
                        TextFormField(
                          controller: _nameController,
                          enabled: !_isSaving,
                          decoration: _inputDecoration(
                            'Destination name',
                            Icons.location_on_outlined,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Nama destinasi wajib diisi';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 22),

                        // VISIT DATE
                        _sectionLabel('Visit Date'),
                        const SizedBox(height: 9),
                        InkWell(
                          onTap: _isSaving ? null : _selectDate,
                          child: InputDecorator(
                            decoration: _inputDecoration(
                              'Visit date',
                              Icons.calendar_month,
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
                          decoration: _inputDecoration(
                            'Budget',
                            Icons.account_balance_wallet_outlined,
                          ).copyWith(prefixText: 'Rp '),
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

                        // STATUS
                        _sectionLabel('Status'),
                        const SizedBox(height: 9),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedStatus,
                          decoration: _inputDecoration(
                            'Status',
                            Icons.flag_outlined,
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
                          onChanged: _isSaving
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedStatus = value;
                                    });
                                  }
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
                          decoration: _inputDecoration(
                            'Write your travel notes...',
                            Icons.notes,
                          ).copyWith(
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // UPDATE BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton.icon(
                            onPressed: _isSaving
                                ? null
                                : _updateItinerary,
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
                                  ? 'Updating...'
                                  : 'Update Itinerary',
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

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: primaryColor,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
