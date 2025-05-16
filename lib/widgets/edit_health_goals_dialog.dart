import 'package:flutter/material.dart';
import 'package:behaviormind/models/user_model.dart';
import 'package:behaviormind/theme/colors.dart';

class EditHealthGoalsDialog extends StatefulWidget {
  final User user;
  final Function(Map<String, dynamic>) onSave;

  const EditHealthGoalsDialog({
    Key? key,
    required this.user,
    required this.onSave,
  }) : super(key: key);

  @override
  _EditHealthGoalsDialogState createState() => _EditHealthGoalsDialogState();
}

class _EditHealthGoalsDialogState extends State<EditHealthGoalsDialog> {
  late TextEditingController _stepsController;
  late TextEditingController _sleepController;
  late TextEditingController _waterController;
  late TextEditingController _meditationController;
  late TextEditingController _caloriesController;

  @override
  void initState() {
    super.initState();
    _stepsController = TextEditingController(
      text: widget.user.healthGoals['steps']?.toString() ?? '10000'
    );
    _sleepController = TextEditingController(
      text: widget.user.healthGoals['sleep']?.toString() ?? '8'
    );
    _waterController = TextEditingController(
      text: widget.user.healthGoals['water']?.toString() ?? '8'
    );
    _meditationController = TextEditingController(
      text: widget.user.healthGoals['meditation']?.toString() ?? '15'
    );
    _caloriesController = TextEditingController(
      text: widget.user.healthGoals['calories']?.toString() ?? '2000'
    );
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _sleepController.dispose();
    _waterController.dispose();
    _meditationController.dispose();
    _caloriesController.dispose();
    super.dispose();
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
              'Edit Health Goals',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 24),
            _buildGoalInput(
              controller: _stepsController,
              label: 'Daily Steps',
              icon: Icons.directions_walk_outlined,
              color: AppColors.primary,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            _buildGoalInput(
              controller: _sleepController,
              label: 'Sleep (hours)',
              icon: Icons.nightlight_round,
              color: AppColors.secondary,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            _buildGoalInput(
              controller: _waterController,
              label: 'Water (glasses)',
              icon: Icons.water_drop_outlined,
              color: Colors.blue,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            _buildGoalInput(
              controller: _meditationController,
              label: 'Meditation (minutes)',
              icon: Icons.self_improvement_outlined,
              color: Colors.purple,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            _buildGoalInput(
              controller: _caloriesController,
              label: 'Calories (kcal)',
              icon: Icons.local_fire_department_outlined,
              color: Colors.red,
              keyboardType: TextInputType.number,
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

  Widget _buildGoalInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  void _saveChanges() {
    // Parse values and create updated health goals map
    Map<String, dynamic> updatedHealthGoals = {
      'steps': int.tryParse(_stepsController.text) ?? 10000,
      'sleep': int.tryParse(_sleepController.text) ?? 8,
      'water': int.tryParse(_waterController.text) ?? 8,
      'meditation': int.tryParse(_meditationController.text) ?? 15,
      'calories': int.tryParse(_caloriesController.text) ?? 2000,
    };
    
    widget.onSave(updatedHealthGoals);
    Navigator.pop(context);
  }
}