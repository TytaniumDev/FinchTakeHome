import 'package:birdo/core/theme/penguino_colors.dart';
import 'package:birdo/view/widgets/common/chunky_button.dart';
import 'package:flutter/material.dart';

/// Screen for naming the user during the NUX flow
class NuxUserNameScreen extends StatefulWidget {
  final Function(String) onNameSubmitted;
  final Function() onNext;
  final Function() onBack;

  const NuxUserNameScreen({
    super.key,
    required this.onNameSubmitted,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<NuxUserNameScreen> createState() => _NuxUserNameScreenState();
}

class _NuxUserNameScreenState extends State<NuxUserNameScreen> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isNameValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _validateName() {
    setState(() {
      _isNameValid = _nameController.text.trim().isNotEmpty;
    });
  }

  void _submitName() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      widget.onNameSubmitted(name);
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.lerp(PenguinoColors.gooseBlue5, Colors.white, 0.5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Almost there!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: PenguinoColors.gooseBlue7,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Now, tell us your name',
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Container(
                    height: 120,
                    width: 120,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: PenguinoColors.gooseBlue3,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Your Name',
                      hintText: 'Enter your name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submitName(),
                  ),
                  const SizedBox(height: 24),
                  // Wrap buttons in a container with minimum height
                  Container(
                    constraints: const BoxConstraints(minHeight: 60),
                    child: Row(
                      children: [
                        Expanded(
                          child: ChunkyButton(
                            text: 'Back',
                            icon: Icons.arrow_back,
                            type: ButtonType.secondary,
                            onPressed: widget.onBack,
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ChunkyButton(
                            text: 'Complete',
                            icon: Icons.check,
                            type: ButtonType.primary,
                            onPressed: _isNameValid ? _submitName : null,
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
