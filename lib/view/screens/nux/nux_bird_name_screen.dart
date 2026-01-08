import 'package:birdo/core/theme/penguino_colors.dart';
import 'package:birdo/view/widgets/common/chunky_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Screen for naming the bird during the NUX flow
class NuxBirdNameScreen extends StatefulWidget {
  final Function(String) onNameSubmitted;

  final Function() onNext;

  const NuxBirdNameScreen({
    super.key,
    required this.onNameSubmitted,
    required this.onNext,
  });

  @override
  State<NuxBirdNameScreen> createState() => _NuxBirdNameScreenState();
}

class _NuxBirdNameScreenState extends State<NuxBirdNameScreen> {
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
    debugPrint('NuxBirdNameScreen: Submitting name');
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      debugPrint('NuxBirdNameScreen: Name validated: $name');
      widget.onNameSubmitted(name);
      debugPrint('NuxBirdNameScreen: Name submitted, calling onNext');
      widget.onNext();
      debugPrint('NuxBirdNameScreen: onNext called');
    } else {
      debugPrint('NuxBirdNameScreen: Form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.lerp(PenguinoColors.gooseBlue5, Colors.white, 0.5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Welcome to Birdo Tasks!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: PenguinoColors.gooseBlue7,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Text(
                  'First, let\'s name your bird companion!',
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Container(
                  height: 150,
                  width: 150,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'lib/assets/stages/egg.svg',
                    height: 100,
                    width: 100,
                    placeholderBuilder:
                        (context) => const Icon(
                          Icons.egg_alt,
                          size: 100,
                          color: PenguinoColors.gooseBlue3,
                        ),
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Bird Name',
                    hintText: 'Enter a name for your bird',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name for your bird';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submitName(),
                ),
                const SizedBox(height: 24),
                ChunkyButton(
                  text: 'Next',
                  icon: Icons.arrow_forward,
                  type: ButtonType.primary,
                  onPressed: _isNameValid ? _submitName : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
