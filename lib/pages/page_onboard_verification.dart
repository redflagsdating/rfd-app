import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/pages/page_home.dart';
import 'package:red_flags/widgets/onboarding/onboard_app_bar.dart';
import 'package:red_flags/widgets/onboarding/onboard_verification_display_name.dart';
import 'package:red_flags/widgets/onboarding/onboard_verification_full_name.dart';
import 'package:red_flags/widgets/page_slide_transition_switcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

const maxSteps = 3;

/// Onboarding stage 1 Account verification Scaffold
class PageOnboardVerification extends StatefulWidget {
  final int initStep;
  final String? initFirstName;
  final String? initLastName;
  final String? initDisplayName;
  const PageOnboardVerification({
    super.key,
    required this.initStep,
    this.initFirstName,
    this.initLastName,
    this.initDisplayName,
  });

  @override
  State<PageOnboardVerification> createState() =>
      _PageOnboardVerificationState();
}

class _PageOnboardVerificationState extends State<PageOnboardVerification> {
  int _step = 0;
  bool _reverse = false;
  bool _loading = false;

  final _form = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _displayNameCtrl = TextEditingController();

  void _setLoading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  void _nextStep([bool? reverse]) {
    setState(() {
      if (reverse == true && _step > 0) {
        _reverse = true;
        _step--;
      } else if (reverse != true && _step < maxSteps) {
        _reverse = false;
        _step++;
      }
    });
  }

  @override
  void didChangeDependencies() {
    _step = widget.initStep;
    _firstNameCtrl.text = widget.initFirstName ?? "";
    _lastNameCtrl.text = widget.initLastName ?? "";
    _displayNameCtrl.text = widget.initDisplayName ?? "";

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = _loading == true;
    final localStorage = Provider.of<SharedPreferences>(context);

    return Scaffold(
      appBar: OnboardAppBar(
          theme: theme,
          step: _step,
          maxSteps: maxSteps,
          onBack: isLoading
              ? null
              : () {
                  if (_step == 0) {
                    Navigator.of(context).pop();
                  } else if (_step > 0) {
                    _nextStep(true);
                  }
                },
          onSkip: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const PageHome()),
            );
          }),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: isLoading
            ? null
            : () async {
                if (!_form.currentState!.validate()) {
                  return;
                }

                _setLoading(true);

                final uid = FirebaseAuth.instance.currentUser!.uid;
                final firstName =
                    localStorage.getString(UserFields.firstName.name);
                final lastName =
                    localStorage.getString(UserFields.lastName.name);
                final displayName =
                    localStorage.getString(UserFields.displayName.name);

                switch (_step) {
                  case 0:
                    if (firstName != _firstNameCtrl.text ||
                        lastName != _lastNameCtrl.text) {
                      localStorage.setString(
                        UserFields.firstName.name,
                        _firstNameCtrl.text,
                      );
                      localStorage.setString(
                        UserFields.lastName.name,
                        _lastNameCtrl.text,
                      );

                      await usersRef.doc(uid).update({
                        UserFields.firstName.name: _firstNameCtrl.text,
                        UserFields.lastName.name: _lastNameCtrl.text,
                      });
                    }
                    break;
                  case 1:
                    if (displayName != _displayNameCtrl.text) {
                      localStorage.setString(
                        UserFields.displayName.name,
                        _displayNameCtrl.text,
                      );

                      await usersRef.doc(uid).update({
                        UserFields.displayName.name: _displayNameCtrl.text,
                      });
                    }
                    break;
                  default:
                }

                _setLoading(false);
                _nextStep();
              },
        child: const Icon(Icons.arrow_forward_ios_rounded),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 36,
        ),
        child: Form(
          key: _form,
          child: PageSlideTransitionSwitcher(
            reverse: _reverse,
            duration: const Duration(milliseconds: 500),
            child: _step == 0
                ? OnboardVerificationFullName(
                    enabled: !isLoading,
                    firstNameCtrl: _firstNameCtrl,
                    lastNameCtrl: _lastNameCtrl,
                  )
                : _step == 1
                    ? OnboardVerificationDisplayName(
                        enabled: !isLoading,
                        displayNameCtrl: _displayNameCtrl,
                      )
                    // TODO
                    : _step == 2
                        ? const Text("KYC")
                        : const Text("Unknown"),
          ),
        ),
      ),
    );
  }
}
