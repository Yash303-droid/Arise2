import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:arise2/view_models/game_viewmodel.dart';

class AddHabitForm extends StatefulWidget {
  const AddHabitForm({
    super.key,
    required this.onAddHabit,
  });

  // xp is optional; nature is selectable
  final Future<void> Function(String title, int? xp, bool isGood, String nature) onAddHabit;

  @override
  State<AddHabitForm> createState() => _AddHabitFormState();
}

class _AddHabitFormState extends State<AddHabitForm> {
  final _formKey = GlobalKey<FormState>();
  var _title = '';
  int? _xp = 10;
  var _isGoodHabit = true;
  var _nature = 'mental';
  var _isProcessing = false;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isProcessing = true;
      });
      try {
        await widget.onAddHabit(_title, _xp, _isGoodHabit, _nature);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) setState(() => _isProcessing = false);
        // Error handling is usually done in ViewModel or via SnackBar in parent, but we stop spinner here.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Habit Title',
              labelStyle: TextStyle(color: Colors.white70),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a title.';
              }
              final gameVM = Provider.of<GameViewModel>(context, listen: false);
              final exists = gameVM.habits.any(
                (h) => h.name.toLowerCase() == value.trim().toLowerCase(),
              );
              if (exists) {
                return 'Habit already exists.';
              }
              return null;
            },
            onSaved: (value) {
              _title = value!;
            },
          ),
          TextFormField(
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'XP Reward (optional)',
              labelStyle: TextStyle(color: Colors.white70),
            ),
            initialValue: '10',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number.';
              }
              return null;
            },
            onSaved: (value) {
              if (value == null || value.trim().isEmpty) {
                _xp = null;
              } else {
                _xp = int.parse(value);
              }
            },
          ),
          const SizedBox(height: 8),
          // Nature selector
          DropdownButtonFormField<String>(
            value: _nature,
            decoration: const InputDecoration(
              labelText: 'Nature',
              labelStyle: TextStyle(color: Colors.white70),
            ),
            items: const [
              DropdownMenuItem(value: 'mental', child: Text('Mental')),
              DropdownMenuItem(value: 'physical', child: Text('Physical')),
              DropdownMenuItem(value: 'social', child: Text('Social')),
            ],
            onChanged: (v) => setState(() { _nature = v ?? 'mental'; }),
          ),
          const SizedBox(height: 8),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_isGoodHabit ? 'Good Habit' : 'Bad Habit', style: const TextStyle(color: Colors.white)),
              Switch(
                value: _isGoodHabit,
                onChanged: (value) {
                  setState(() {
                    _isGoodHabit = value;
                  });
                },
                activeColor: Colors.lightBlueAccent,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isProcessing ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent,
              foregroundColor: Colors.black,
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Add Habit'),
          ),
        ],
      ),
    );
  }
}