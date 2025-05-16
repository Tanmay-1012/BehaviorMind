import 'package:flutter/material.dart';
import 'package:behaviormind/models/user_model.dart';
import 'package:behaviormind/theme/colors.dart';
import 'package:behaviormind/utils/date_formatter.dart';

class EditProfileDialog extends StatefulWidget {
  final User user;
  final Function(User) onSave;

  const EditProfileDialog({
    Key? key,
    required this.user,
    required this.onSave,
  }) : super(key: key);

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _bloodTypeController;
  late TextEditingController _dobController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _heightController = TextEditingController(text: widget.user.height.toString());
    _weightController = TextEditingController(text: widget.user.weight.toString());
    _bloodTypeController = TextEditingController(text: widget.user.bloodType);
    _dobController = TextEditingController(text: widget.user.dateOfBirth);
    
    try {
      _selectedDate = DateFormatter.parseFromFullDate(widget.user.dateOfBirth);
    } catch (e) {
      _selectedDate = DateTime.now().subtract(Duration(days: 365 * 30)); // Default to 30 years ago
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bloodTypeController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(Duration(days: 365 * 30)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormatter.formatFullDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit Profile',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 24),
            _buildTextField(
              controller: _nameController,
              label: 'Name',
              icon: Icons.person_outline,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: _buildTextField(
                  controller: _dobController,
                  label: 'Date of Birth',
                  icon: Icons.calendar_today_outlined,
                  suffix: Icon(Icons.arrow_drop_down),
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _heightController,
              label: 'Height (cm)',
              icon: Icons.height_outlined,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _weightController,
              label: 'Weight (kg)',
              icon: Icons.fitness_center_outlined,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _bloodTypeController,
              label: 'Blood Type',
              icon: Icons.bloodtype_outlined,
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _saveChanges,
                  child: Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  void _saveChanges() {
    // Parse numeric values
    int height = int.tryParse(_heightController.text) ?? widget.user.height;
    int weight = int.tryParse(_weightController.text) ?? widget.user.weight;
    
    // Create updated user
    User updatedUser = User(
      id: widget.user.id,
      name: _nameController.text,
      email: _emailController.text,
      profileImage: widget.user.profileImage,
      dateOfBirth: _dobController.text,
      height: height,
      weight: weight,
      bloodType: _bloodTypeController.text,
      age: _selectedDate != null ? DateFormatter.calculateAge(_selectedDate!) : widget.user.age,
      healthGoals: widget.user.healthGoals,
      connectedDevices: widget.user.connectedDevices,
    );
    
    widget.onSave(updatedUser);
    Navigator.pop(context);
  }
}