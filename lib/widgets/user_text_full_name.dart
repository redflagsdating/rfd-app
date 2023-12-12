import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/user_provider.dart';

class UserTextFullName extends StatefulWidget {
  const UserTextFullName({super.key, this.style});
  final TextStyle? style;

  @override
  State<UserTextFullName> createState() => _UserTextFullNameState();
}

class _UserTextFullNameState extends State<UserTextFullName> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return ListenableBuilder(
      listenable: userProvider,
      builder: (context, _) {
        final firstName = userProvider.getFirstNameCache();
        final lastName = userProvider.getLastNameCache();

        return Text(
          '$firstName $lastName',
          style: widget.style,
        );
      },
    );
  }
}
