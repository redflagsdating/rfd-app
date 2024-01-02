import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/user_provider.dart';

class BadgeKycStatus extends StatefulWidget {
  const BadgeKycStatus({
    super.key,
    required this.child,
    this.offset,
    this.alignment,
  });

  final Widget child;
  final Offset? offset;
  final AlignmentGeometry? alignment;

  @override
  State<BadgeKycStatus> createState() => _BadgeKycStatusState();
}

class _BadgeKycStatusState extends State<BadgeKycStatus> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);

    return ListenableBuilder(
      listenable: userProvider,
      builder: (context, _) {
        final verifySubmitted = userProvider.getVerifySubmittedCache();
        return Badge(
          largeSize: 32,
          offset: widget.offset,
          backgroundColor: theme.colorScheme.onSecondary.withOpacity(0.8),
          alignment: widget.alignment,
          label: verifySubmitted != true
              ? const Icon(
                  Icons.person_search,
                  color: Colors.black26,
                )
              : FutureBuilder(
                  future: userProvider.getVerified(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data == true
                          ? Icon(
                              Icons.verified,
                              color: Colors.green.shade400,
                            )
                          : snapshot.data == false
                              ? Icon(
                                  Icons.error,
                                  color: theme.colorScheme.error,
                                )
                              : Icon(
                                  Icons.access_time_filled_rounded,
                                  color: theme.colorScheme.tertiary,
                                );
                    }

                    return Icon(
                      Icons.circle_outlined,
                      color: theme.colorScheme.onSecondary.withOpacity(0.8),
                    );
                  },
                ),
          child: widget.child,
        );
      },
    );
  }
}
