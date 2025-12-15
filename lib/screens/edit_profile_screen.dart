import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:intl/intl.dart';
import 'package:sikatu/services/auth_service.dart';
import 'package:sikatu/widgets/primary_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  DateTime? _selectedDate;
  Country? _selectedCountry;
  XFile? _selectedImage;
  String? _currentPhotoUrl;
  bool _isLoading = false;
  bool _isUserDataLoaded = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() { super.initState(); _loadUserData(); }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
      _currentPhotoUrl = user.photoURL;
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          if (data.containsKey('dateOfBirth') && data['dateOfBirth'] != null) _selectedDate = (data['dateOfBirth'] as Timestamp).toDate();
          if (data.containsKey('country') && data['country'] != null) _selectedCountry = CountryParser.parseCountryCode(data['country']);
        }
      } catch (e) { print("Error loading user data: $e"); }
    }
    setState(() { _isLoading = false; _isUserDataLoaded = true; });
  }

  @override
  void dispose() { _nameController.dispose(); _emailController.dispose(); _passwordController.dispose(); super.dispose(); }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) setState(() => _selectedImage = image);
    } catch (e) { if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e'))); }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light()), child: child!),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _selectCountry() {
    showCountryPicker(context: context, showPhoneCode: false, onSelect: (Country country) { setState(() => _selectedCountry = country); });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    bool success = true;
    if (_selectedImage != null) {
      String? newPhotoUrl = await AuthService.uploadProfileImage(_selectedImage!);
      if (newPhotoUrl == null) success = false;
    }
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && _nameController.text != currentUser.displayName) {
      bool nameUpdated = await AuthService.updateDisplayName(_nameController.text);
      if (!nameUpdated) success = false;
    }
    bool userDataUpdated = await AuthService.updateUserData(dateOfBirth: _selectedDate, country: _selectedCountry?.countryCode, username: _nameController.text, email: _emailController.text);
    if (!userDataUpdated) success = false;
    setState(() => _isLoading = false);
    if (success && mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Colors.green)); Navigator.pop(context); }
    else if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memperbarui beberapa data.'))); }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final inputFillColor = isDark ? const Color(0xFF374151) : Colors.grey.shade100;

    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final String dobText = _selectedDate == null ? 'Select Date' : formatter.format(_selectedDate!);
    final String countryText = _selectedCountry == null ? 'Select Country' : _selectedCountry!.name;

    ImageProvider displayImage;
    if (_selectedImage != null) displayImage = FileImage(File(_selectedImage!.path));
    else if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) displayImage = NetworkImage(_currentPhotoUrl!);
    else displayImage = const NetworkImage('https://placehold.co/120x120/E0E0E0/grey?text=No+Image');

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
      appBar: AppBar(leading: BackButton(color: textColor), title: Text('Edit Profile', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)), backgroundColor: Colors.transparent, elevation: 0, centerTitle: true),
      body: _isLoading && !_isUserDataLoaded ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(alignment: Alignment.bottomRight, children: [
                CircleAvatar(radius: 60, backgroundImage: displayImage, backgroundColor: Colors.grey.shade200),
                GestureDetector(onTap: _pickImage, child: CircleAvatar(radius: 18, backgroundColor: Colors.grey.shade700, child: const Icon(Icons.camera_alt, color: Colors.white, size: 20))),
              ]),
              const SizedBox(height: 30),
              _buildTextField(_nameController, 'Name', textColor, inputFillColor),
              _buildTextField(_emailController, 'Email', textColor, inputFillColor),
              _buildTextField(_passwordController, 'Password', textColor, inputFillColor, isPassword: true),
              _buildDropdownField('Date of Birth', dobText, textColor, inputFillColor, () => _selectDate(context)),
              _buildDropdownField('Country/Region', countryText, textColor, inputFillColor, _selectCountry),
              const SizedBox(height: 20),
              _isLoading ? const Center(child: CircularProgressIndicator()) : PrimaryButton(text: 'Save changes', onPressed: _saveChanges),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, Color labelColor, Color fillColor, {bool isPassword = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: labelColor)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller, obscureText: isPassword,
        style: TextStyle(color: labelColor),
        decoration: InputDecoration(filled: true, fillColor: fillColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none), suffixIcon: isPassword ? const Icon(Icons.visibility_off_outlined) : null),
        validator: (value) => !isPassword && (value == null || value.isEmpty) ? 'Please enter your $label' : null,
      ),
      const SizedBox(height: 20),
    ]);
  }

  Widget _buildDropdownField(String label, String value, Color labelColor, Color fillColor, VoidCallback onTap) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: labelColor)),
      const SizedBox(height: 8),
      InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15), decoration: BoxDecoration(color: fillColor, borderRadius: BorderRadius.circular(12.0)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(value, style: TextStyle(fontSize: 16, color: labelColor)), Icon(Icons.arrow_drop_down, color: labelColor)]))),
      const SizedBox(height: 20),
    ]);
  }
}